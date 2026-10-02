/** A domain id declared by one certification in src/certifications.ts. */
export type Domain = string;

export interface Option {
  id: string;
  text: string;
}

export interface CliExample {
  description: string;
  command: string;
  /** Mocked stdout for the command, shaped like the real API response. */
  sampleOutput?: string;
}

export interface Question {
  id: string;
  domain: Domain;
  text: string;
  options: Option[];
  correctOptionIds: string[];
  /**
   * Whether this question accepts one or two correct selections. Always explicit: correctOptionIds
   * is a pool of acceptable answers (at least 2 for single, 4 for multi) that is larger than what
   * is ever shown at once, so its length can't tell the two apart — see scoring.ts.
   */
  answerType: "single" | "multi";
  explanation: string;
  /** Per-option explanation, keyed by Option.id, covering why each option is right or wrong. */
  optionRationale?: Record<string, string>;
  referenceUrl?: string;
  referenceLabel?: string;
  /** Deep link to the specific AWS Console page for the concept being tested. */
  consoleUrl?: string;
  consoleLabel?: string;
  /** Explicit YouTube video for this question; when absent, one is resolved from the curated catalog. */
  videoUrl?: string;
  videoLabel?: string;
  /** Mermaid diagram definition, rendered only when present. */
  diagram?: string;
  cliExample?: CliExample;
}

export type Mode = "full-exam" | "practice";

export interface DomainBreakdownEntry {
  domain: Domain;
  correct: number;
  total: number;
}

export interface PerQuestionResult {
  question: Question;
  selectedOptionIds: string[];
  isCorrect: boolean;
}

export interface SessionResult {
  correctCount: number;
  totalCount: number;
  scaledScore: number;
  passed: boolean;
  domainBreakdown: DomainBreakdownEntry[];
  perQuestion: PerQuestionResult[];
}
