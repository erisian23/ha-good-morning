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
