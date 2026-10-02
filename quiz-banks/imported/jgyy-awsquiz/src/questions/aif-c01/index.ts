import { Question } from "../../types.js";
import { aiMlFundamentalsQuestions } from "./ai-ml-fundamentals.js";
import { genaiFundamentalsQuestions } from "./genai-fundamentals.js";
import { foundationModelApplicationsQuestions } from "./foundation-model-applications.js";
import { responsibleAiQuestions } from "./responsible-ai.js";
import { aiSecurityGovernanceQuestions } from "./ai-security-governance.js";

export const aifQuestions: Question[] = [
  ...aiMlFundamentalsQuestions,
  ...genaiFundamentalsQuestions,
  ...foundationModelApplicationsQuestions,
  ...responsibleAiQuestions,
  ...aiSecurityGovernanceQuestions,
];
