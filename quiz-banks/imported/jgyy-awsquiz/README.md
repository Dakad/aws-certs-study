# Imported question banks from `jgyy/awsquiz`

This directory contains human-readable YAML question banks extracted from [`jgyy/awsquiz`](https://github.com/jgyy/awsquiz), using upstream revision [`444f946c970a976d9f2ffb663e35c32ff0dda655`](https://github.com/jgyy/awsquiz/commit/444f946c970a976d9f2ffb663e35c32ff0dda655) on 2026-10-02. Each YAML file records the source repository, revision, commit URL, license, and question count as top-level fields.

The source repository is licensed under MIT. Its complete `LICENSE` is preserved here; retain it with the imported material. Only question text, options, answer type, accepted correct-answer IDs, and the author's explanations/option rationales are included. The original TypeScript implementation, web app, build scripts, assets, and unrelated application code are not included.

## Included banks

- [`clf-c02.yaml`](clf-c02.yaml): 1,040 Cloud Practitioner (CLF-C02) questions.
- [`aif-c01.yaml`](aif-c01.yaml): 195 AI Practitioner (AIF-C01) questions.

`accepted_correct_option_ids` preserves the source's accepted answer pool. `answer_type` specifies whether a displayed question is single- or multi-select; for single-select questions the source can list more than one acceptable answer because the app draws from that pool.

These are not CloudOps Engineer Associate (SOA-C03) questions and are not included in SOA-C03 scores, domain coverage, or progress tracking. They are third-party practice material, not official AWS exam questions; verify answer-critical details against current AWS documentation.

The source is available at [github.com/jgyy/awsquiz](https://github.com/jgyy/awsquiz). This import is provided under the terms of the included MIT License.
