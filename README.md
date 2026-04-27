# HA Good Morning

A modular Home Assistant package that turns a personal "Good Morning" routine into local, inspectable, version-controlled automation.

This project started as a practical replacement for selected Alexa routine skill calls.
The goal is not to rebuild Alexa.
It is to move the useful morning announcements into Home Assistant where the behavior is visible, testable, customizable, and easy to review in Git.

## What It Does

The Good Morning routine is composed from small Home Assistant scripts that can:

- Announce the current time and date
- Report the daily allergy index
- Report outdoor air quality
- Report the day's chance of rain and expected precipitation
- Report current temperature and the forecast high and low
- Run a customizable TV or morning display startup step
- Route spoken output through one central speech wrapper

The main routine is `script.good_morning`.
Each report script focuses on one piece of information, and all spoken output flows through `script.good_morning_speak`.

## Why It Is Useful

Alexa routines are convenient, but their built-in skill calls can be difficult to inspect, version, customize, or test.
This package replaces those opaque pieces with plain Home Assistant YAML and Jinja.

The result is intentionally boring in the best way:

- Local Home Assistant logic instead of hidden routine behavior
- Small scripts with clear responsibilities
- A single speech delivery abstraction
- Git-friendly diffs
- CI validation for package shape and YAML syntax
- A reusable structure that can be adapted to another Home Assistant instance

## Design At A Glance

```text
script.good_morning
  -> morning report scripts
  -> optional TV/display startup script

report scripts
  -> build spoken messages
  -> call script.good_morning_speak

script.good_morning_speak
  -> chooses the configured TTS target
  -> sends speech through Alexa Media Player notify services
```

The central design choice is to separate message generation from speech delivery.
If the speech transport changes later, the report scripts should not need to change.

## Package Reference

The Home Assistant package lives in [`home-assistant/packages/good_morning/`](home-assistant/packages/good_morning/).

For installation steps, entity IDs, dependencies, script behavior, customization notes, and troubleshooting, see the
[Good Morning package reference](home-assistant/packages/good_morning/README.md).

## Repository Layout

```text
.
|-- .github/
|   `-- workflows/
|       `-- validate.yml
|-- home-assistant/
|   `-- packages/
|       `-- good_morning/
|           |-- README.md
|           |-- package.yaml
|           `-- scripts/
|-- scripts/
|   `-- check-package-shape.sh
|-- .gitignore
|-- .yamllint.yml
|-- Makefile
`-- README.md
```

## Validation

From the repository root:

```bash
make check
```

The local check verifies the expected package files, required script IDs, the package include shape, and common include-directory mistakes.
GitHub Actions also runs `yamllint` against the Good Morning package.

## Deployment Model

This public repository contains the reusable Home Assistant package and validation logic.
It does not contain private Home Assistant URLs, credentials, SSH configuration, or deployment secrets.

In a real deployment, a private repository or local workflow can copy:

```text
home-assistant/packages/good_morning/
```

to:

```text
/config/packages/good_morning/
```

and then run the normal Home Assistant configuration checks and reload steps.

## Status

This is a working personal Home Assistant package shared as a practical example of a modular, Git-managed automation routine.
It is designed to be read, modified, and adapted rather than installed as a one-click integration.
