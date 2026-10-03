#!/usr/bin/env bash
# Lab 05, Step 4 - audit evidence, and what each source can and cannot establish.
#
# Read-only. Nothing here is created, changed, or deleted.
#
# Three sources, deliberately:
#   1. CloudTrail event history for this lab's own API calls
#   2. the TLS chain of an AWS endpoint, read with openssl (no AWS call at all)
#   3. ACM, listed read-only, if this account/region has any certificates
#
set -euo pipefail

PREFIX="soa-c03-lab05"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
SECRET_NAME="${PREFIX}/api-credential"
PARAM_NAME="${PREFIX}/db-password"

export AWS_REGION="$REGION"

if [[ -z "${AWS_PROFILE:-}" ]]; then
  echo "ERROR: set AWS_PROFILE to the authorized profile before running." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required by this script and was not found on PATH." >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="${PREFIX}-${ACCOUNT_ID}-${REGION}"

END_TIME="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
if ! START_TIME="$(date -u -v-24H '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null)"; then
  START_TIME="$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')"
fi

# Print one CloudTrail lookup, shaped to answer "what can this prove".
show_lookup() {
  local label="$1" attrkey="$2" attrvalue="$3"
  printf '\n-- %s (AttributeKey=%s)\n' "$label" "$attrkey"
  local raw
  if ! raw="$(aws cloudtrail lookup-events \
      --lookup-attributes "AttributeKey=${attrkey},AttributeValue=${attrvalue}" \
      --start-time "$START_TIME" --end-time "$END_TIME" \
      --max-items 50 --output json 2>/dev/null)"; then
    echo "   LOOKUP FAILED (denied, or the attribute value is not indexed)"
    return 0
  fi
  if [[ -z "$raw" ]]; then
    echo "   LOOKUP RETURNED NOTHING (denied, or the attribute value is not indexed)"
    return 0
  fi
  printf '%s' "$raw" | jq -r '
        if (.Events // []) | length == 0 then
          "   NO EVENTS FOUND for this attribute in the last 24h"
        else
          ( "   " + ((.Events | length) | tostring) + " event(s)" ),
          ( .Events[]
            | (.CloudTrailEvent | fromjson)
            | "     time=\(.eventTime) event=\(.eventName) source=\(.eventSource) result=\(.errorCode // .errorMessage // "ok")"
            , "     userIdentity.type=\(.userIdentity.type // "n/a") principal=\(.userIdentity.principalId // "n/a") sessionIssuer=\(.userIdentity.sessionContext.sessionIssuer.principalId // "none") accessKey=\(.userIdentity.accessKeyId // "n/a")"
            , "     sourceIPAddress=\(.sourceIPAddress // "n/a") userAgent=\((.userAgent // "n/a")[0:60])"
            , "     requestParameterKeys=\(((.requestParameters // {}) | keys) | join(","))"
            , "     responseElementKeys=\(((.responseElements // {}) | keys) | join(","))"
            , "     resources=\((.resources // []) | map((.resourceType // "?") + ":" + (.resourceName // "")) | join(","))"
          )
        end'
}

echo "== 1. CloudTrail event history for this lab =="
echo "window: $START_TIME .. $END_TIME"
echo
echo "These four lookups are the same query with a different filter. Run them"
echo "only after 01-create.sh and 02/03 have run at least once."

show_lookup "the bucket" ResourceName "$BUCKET"
show_lookup "the SecureString" ResourceName "$PARAM_NAME"
show_lookup "the secret" ResourceName "$SECRET_NAME"
show_lookup "reading the secret value" EventName GetSecretValue

cat <<'GUIDE'
  What a found event establishes: at this timestamp, this principal identity
  called this API against this resource, and this is the outcome.

  What it does not establish: that the value was correct, that the caller was a
  human, that the person behind an assumed role meant to do it, or that no other
  copy of the value exists. userIdentity.type tells you the credential type.
  sessionIssuer is how you follow an assumed role or SSO session back to its
  issuer; without it you have a role name, not a person.

  Note that requestParameterKeys lists key names only. That is deliberate: run
  the same lookup yourself and check whether any field contains the secret
  string, then record yes or no. Do not paste the value into your notes.
GUIDE

echo
echo "== 2. Does an S3 object write show up here? =="
show_lookup "PutObject" EventName PutObject
show_lookup "GetObject" EventName GetObject

cat <<'GUIDE'
  If those two come back empty while Step 1 recorded them, you have just observed
  the boundary between management events and data events. S3 object-level calls
  are data events; they are not in event history unless data events are enabled
  for the trail or the bucket. So "CloudTrail shows no GetObject" does not mean
  "nobody read the object" - it means the trail was not configured to record it.
  Confirm that against the trail configuration before you rely on either claim.
GUIDE

# --------------------------------------------------------- 3. TLS, no AWS call
echo
echo "== 3. Encryption in transit: reading a real TLS chain =="
if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl not found on PATH; skipping this part."
else
  ENDPOINT="s3.${REGION}.amazonaws.com"
  echo "handshake with ${ENDPOINT}:443"
  echo | openssl s_client -connect "${ENDPOINT}:443" -servername "$ENDPOINT" 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates 2>/dev/null \
    || echo "  handshake or parse failed; record that and check your egress path"
  echo
  echo "protocol negotiated:"
  echo | openssl s_client -connect "${ENDPOINT}:443" -servername "$ENDPOINT" 2>/dev/null \
    | grep -i '^    Protocol\|^    Cipher' | head -4 || true
fi

cat <<'GUIDE'
  Every aws command in this lab has been crossing this same kind of TLS
  connection to its endpoint, and nothing in the CLI exposed the fact.

  Read this carefully before drawing a conclusion: this is Amazon's own endpoint
  certificate, not a certificate you own, and its expiry is not your operational
  problem. It demonstrates the handshake and the chain, not your certificate
  lifecycle. For your own certificate expiry, that is ACM, below.
GUIDE

# ------------------------------------------------------------------- 4. ACM
echo
echo "== 4. ACM, read-only, for certificate expiry monitoring =="
CERTS="$(aws acm list-certificates --output json 2>/dev/null || echo '{}')"
CERT_COUNT="$(printf '%s' "$CERTS" | jq -r '(.CertificateSummaryList // []) | length')"
echo "certificates in ${REGION}: ${CERT_COUNT}"
if [[ "$CERT_COUNT" == "0" ]]; then
  cat <<'GUIDE'
    Nothing to inspect. This lab creates no certificate on purpose: ACM issuance
    needs a domain whose DNS you can control, and the sandbox has none. Read the
    ACM fields below as the shape you would look at, not as observed data:

      describe-certificate.Certificate.NotAfter          expiry instant
      describe-certificate.Certificate.NotBefore         validity start
      describe-certificate.Certificate.RenewalEligibility  RENEWAL_ELIGIBLE
      describe-certificate.Certificate.RenewalSummary     why not, when not
      describe-certificate.Certificate.Status             ISSUED / EXPIRED / ...
      describe-certificate.Certificate.InUseBy[]         what depends on it
      describe-certificate.Certificate.Type               AMAZON_ISSUED vs IMPORTED

    And for monitoring rather than inspection, AWS Config has managed rules for
    this; ACM_CERTIFICATE_EXPIRY_CHECK is the identifier to confirm on the
    official managed-rules list before you pass it to Step 5. This script does
    not assume it exists.
GUIDE
else
  aws acm list-certificates \
    --query 'CertificateSummaryList[].{DomainName:DomainName,Status:Status,InUse:InUse,NotAfter:NotAfter,Type:Type}' \
    --output table
  FIRST_ARN="$(printf '%s' "$CERTS" | jq -r '.CertificateSummaryList[0].CertificateArn')"
  echo
  echo "detail for the first certificate:"
  aws acm describe-certificate --certificate-arn "$FIRST_ARN" \
    --query 'Certificate.{NotBefore:NotBefore,NotAfter:NotAfter,Status:Status,RenewalEligibility:RenewalEligibility,RenewalSummary:RenewalSummary,InUseByCount:(.InUseBy|length),Validation:(.DomainValidationOptions[].ValidationStatus)}' \
    --output json 2>/dev/null | jq . || echo "  (describe failed)"
cat <<'GUIDE'
  Copy the NotAfter value into your notes, not the domain name.
  RenewalEligibility answers whether ACM can renew this certificate at all,
  which is a different question from whether it is close to expiry.
GUIDE
fi

echo
echo "== 5. Still read-only: nothing in this script created a resource =="
cat <<'GUIDE'
  An audit source that you changed in order to observe it is no longer evidence
  about the state you meant to inspect. Recording that boundary is part of the
  finding, not a limitation of the lab.
GUIDE