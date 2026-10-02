import { Question } from "../../types.js";
import { cloudConceptsQuestions } from "./cloud-concepts.js";
import { securityAndComplianceQuestions } from "./security-and-compliance.js";
import { cloudTechnologyAndServicesQuestions } from "./technology-and-services.js";
import { billingPricingAndSupportQuestions } from "./billing-pricing-and-support.js";

export const clfQuestions: Question[] = [
  ...cloudConceptsQuestions,
  ...securityAndComplianceQuestions,
  ...cloudTechnologyAndServicesQuestions,
  ...billingPricingAndSupportQuestions,
];
