# Agent Instructions

This repository contains Home Assistant configuration packages.

## Priorities

- Prefer boring, reliable, reversible changes.
- Keep YAML clean and readable.
- Avoid UI-generated scene/entity attribute bloat.
- Prefer explicit helpers for tunable values.
- Preserve existing entity IDs unless explicitly asked to rename them.
- Avoid broad architectural changes unless requested.
- Do not invent features, entities, files, or scripts that are not present in the repository.

## Formatting Conventions

- Do not impose an 80-character line limit.
- Prefer readable, natural line lengths over legacy terminal-width wrapping.
- Use a soft maximum line length of 160 characters for code, YAML, Markdown, shell scripts, and documentation unless a tool or file format requires something stricter.
- Do not reflow existing prose, comments, YAML strings, or documentation solely to satisfy an 80-character convention.
- Preserve descriptive names, labels, entity IDs, file paths, URLs, and commands even when they make lines longer.
- Wrap long lines only when it improves readability, reduces ambiguity, or is required by syntax or tooling.
- For Markdown prose, prefer one sentence or logical clause per line only when it improves diff readability; otherwise use normal paragraphs.

## Home Assistant Conventions

- Package files live under `home-assistant/packages/`.
- The Good Morning package lives under `home-assistant/packages/good_morning/`.
- Prefer split includes over monolithic YAML when it improves reviewability.
- TTS target selection should use `input_select.good_morning_tts_target`.
- Use scripts for reusable intents.
- Use timers and helpers for configurable behavior.
- Prefer descriptive entity names, script names, and file names over terse names.

## Documentation Conventions

- Keep the root `README.md` friendly, high-level, and portfolio-readable.
- Keep package-level README files technical, specific, and useful for modification.
- Avoid duplicating detailed technical instructions between the root README and package README files.
- Use relative links between documentation files.
- Preserve accurate file paths, entity IDs, helper names, and script names.
- Do not claim the package supports behavior that is not implemented in the repository.
- Do not wrap Markdown prose at 80 characters. Use natural paragraph flow unless wrapping improves clarity.

## Validation

Before claiming a code or configuration change is complete, run:

```bash
yamllint home-assistant
```

For documentation-only changes, do not run Home Assistant deployment steps unless explicitly instructed.

## Deployment

- Do not deploy automatically unless explicitly instructed.
- Do not reload Home Assistant unless explicitly instructed.
- Do not modify deployment scripts unless the task explicitly asks for that.
