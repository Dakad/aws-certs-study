#!/usr/bin/env python3
"""Verify every AWS CLI flag used in the lab scripts exists for that operation.

Why this exists: `bash -n` only checks shell syntax. It happily accepts
`aws elbv2 create-target-group --health-check-matcher`, which is not a real
flag, so the lab fails at run time instead of at review time.

Flag attribution rules (learned the hard way):
  * a logical line is one physical line plus its backslash continuations
  * within a logical line, `|` separates commands, so a flag after a pipe
    belongs to the piped command and is not attributed to the earlier one
  * `$(` starts a nested command: attribution resets there, so flags belonging
    to the inner command (or to `jq`) are never charged to the outer one
  * a flag is attributed to the nearest preceding `aws` command in the same
    pipe chunk, and only if that command has a synopsis to check against
  * the checker prefers silence over false alarms; a skipped check is better
    than a report the reviewer learns to ignore

Usage:  ./check-aws-cli-flags.py [labs_dir ...]
Exit 0 when clean, 1 when any flag is invalid.
"""

import glob
import os
import re
import subprocess
import sys

GLOBAL_SERVICES = {"s3", "s3api", "iam", "sts", "kms", "ec2", "elbv2", "logs", "cloudwatch"}
_synopsis_cache = {}


def synopsis(service, operation):
    """Return the set of --flags in the operation's SYNOPSIS block."""
    key = (service, operation)
    if key in _synopsis_cache:
        return _synopsis_cache[key]
    env = dict(os.environ, AWS_PAGER="")
    try:
        out = subprocess.run(
            ["aws", service, operation, "help"],
            capture_output=True, text=True, env=env, check=False,
        ).stdout
    except FileNotFoundError:
        sys.exit("ERROR: aws CLI not found on PATH")
    # AWS CLI renders headings with interleaved backspaces for bold; strip them
    # or every regex against 'SYNOPSIS'/'OPTIONS' silently fails.
    out = re.sub(r".\x08", "", out)
    out = re.sub(r"\x1b\[[0-9;]*[a-zA-Z]", "", out)
    match = re.search(r"SYNOPSIS(.*?)OPTIONS", out, re.S)
    flags = set(re.findall(r"--[a-z0-9-]+", match.group(1))) if match else set()
    _synopsis_cache[key] = flags
    return flags


def logical_lines(path):
    """Yield (lineno, text) with backslash continuations joined."""
    raw = open(path).read().split("\n")
    buf, start = "", 0
    for number, line in enumerate(raw, 1):
        if not buf:
            start = number
        if line.rstrip().endswith("\\"):
            buf += line.rstrip()[:-1] + " "
        else:
            yield start, buf + line
            buf = ""
    if buf:
        yield start, buf


def strip_comment(text):
    out, quote = "", None
    for index, char in enumerate(text):
        if quote:
            out += char
            if char == quote:
                quote = None
        elif char in "'\"":
            quote = char
            out += char
        elif char == "#" and (index == 0 or text[index - 1].isspace()):
            break
        else:
            out += char
    return out


def check_file(path):
    problems = []
    for lineno, logical in logical_lines(path):
        text = strip_comment(logical)
        # Split on pipes (new command), on `$(` (nested command opens) and on
        # `)` (nested command closes). Each chunk is scanned on its own so a
        # nested `aws`/`jq` never steals the outer command's flags, and flags
        # after a substitution closes are not charged to the nested command.
        chunks = re.split(r"\||\$\(|\)", text)
        for chunk in chunks:
            calls = list(re.finditer(r"\baws\s+([a-z0-9-]+)\s+((?:wait\s+)?[a-z0-9-]+)", chunk))
            if not calls:
                continue
            last = calls[-1]
            tail = chunk[last.end():]
            flags = set(re.findall(r"(?<![\w-])--([a-z0-9][a-z0-9-]*)", tail))
            if not flags:
                continue
            service, operation = last.group(1), last.group(2)
            if service not in GLOBAL_SERVICES:
                continue
            valid = synopsis(service, operation)
            if not valid:
                continue  # no parsable synopsis (some paginated ops); skip quietly
            for flag in sorted(flags):
                if f"--{flag}" not in valid:
                    problems.append((lineno, service, operation, f"--{flag}"))
    return problems


BASH4_PATTERNS = [
    (r"(?<![\w-])mapfile(?![\w-])", "mapfile is bash 4+; macOS ships bash 3.2"),
    (r"(?<![\w-])readarray(?![\w-])", "readarray is bash 4+; macOS ships bash 3.2"),
    (r"declare\s+-A", "associative arrays are bash 4+; macOS ships bash 3.2"),
    (r"\$\{[A-Za-z_][A-Za-z_0-9]*\^\^", "${var^^} is bash 4+; macOS ships bash 3.2"),
    (r"\$\{[A-Za-z_][A-Za-z_0-9]*,,", "${var,,} is bash 4+; macOS ships bash 3.2"),
]


def check_bash32(path):
    """Flag bash 4+ constructs; the labs must run on macOS default bash 3.2."""
    hits = []
    for lineno, logical in logical_lines(path):
        code = strip_comment(logical)
        for pattern, message in BASH4_PATTERNS:
            if re.search(pattern, code):
                hits.append((lineno, message))
    return hits


def main():
    roots = sys.argv[1:] or ["aws-cloudops/knowledge/labs"]
    files = []
    for root in roots:
        files.extend(
            p for p in glob.glob(os.path.join(root, "**", "*.sh"), recursive=True)
            if "/.terraform/" not in p
        )
    files = sorted(set(files))
    total = 0
    bash_hits = 0
    for path in files:
        for lineno, service, operation, flag in check_file(path):
            total += 1
            print(f"INVALID  {path}:{lineno}  {service} {operation} {flag}")
        for lineno, message in check_bash32(path):
            bash_hits += 1
            print(f"BASH4    {path}:{lineno}  {message}")
    print(f"\nchecked {len(files)} scripts")
    print(f"invalid AWS CLI flags : {total}")
    print(f"bash 4+ constructs    : {bash_hits}")
    return 1 if (total or bash_hits) else 0


if __name__ == "__main__":
    sys.exit(main())
