# HA Good Morning

A modular Home Assistant package that replaces selected Alexa Good Morning routine skill calls with local, inspectable Home Assistant scripts.

This project started as a practical Alexa-replacement experiment: keep the parts of a morning routine that are genuinely useful, but move the logic into Home Assistant so the behavior is visible, version-controlled, testable, and easier to evolve.

## What it does

The package provides a Good Morning routine made from small, focused scripts:

- Announces the current time
- Reports the daily allergy index
- Reports outdoor air quality and the likely dominant pollutant
- Reports the chance of rain for the day
- Reports current temperature and today's forecast high/low
- Announces today's date
- Optionally runs a TV or morning display startup script
- Sends all spoken output through a centralized TTS wrapper

The main routine is:

```text
script.good_morning
```

All speech output is routed through:

```text
script.good_morning_speak
```

That means the individual report scripts only need to generate text. They do not need to know which speaker, Echo, Assist satellite, or future TTS transport will say it.

## Why this exists

Alexa routines can be useful, but some Alexa skill calls are opaque. For example, an Alexa routine may call an internal skill operation such as a pollen report, air quality report, or rain forecast. Those calls are difficult to inspect, version, customize, or replace.

This package turns those pieces into Home Assistant scripts that are:

- Local and inspectable
- Modular
- Git-friendly
- Easier to test
- Easier to customize
- Easier to deploy reproducibly

It is not trying to be a complete Alexa replacement. It is a small, practical subsystem for replacing the parts of a morning routine that are better expressed as Home Assistant automation logic.

## Architecture

```text
script.good_morning
  -> script.set_everywhere_to_volume_5          optional external dependency
  -> script.morning_current_time
  -> script.morning_allergy_report
  -> script.morning_air_quality_report
  -> script.morning_rain_forecast
  -> script.morning_temperature_report
  -> script.morning_current_date
  -> script.morning_turn_on_tv                  optional/custom behavior

All spoken output:
  -> script.good_morning_speak
     -> notify.alexa_media
     -> notify.alexa_media_last_called
```

The package is split into multiple files for clean diffs and easier maintenance:

```text
home-assistant/
  packages/
    good_morning/
      package.yaml
      README.md
      scripts/
        speak.yaml
        good_morning.yaml
        current_time.yaml
        current_date.yaml
        allergy_report.yaml
        air_quality_report.yaml
        rain_forecast.yaml
        temperature_report.yaml
        turn_on_tv.yaml
        test.yaml
```

The package entrypoint loads scripts with:

```yaml
script: !include_dir_merge_named scripts
```

## Package reference

The Home Assistant package lives in [`home-assistant/packages/good_morning/`](home-assistant/packages/good_morning/).

For detailed entity lists, dependencies, script behavior, and troubleshooting notes, see the [Good Morning package reference](home-assistant/packages/good_morning/README.md).

## Package-owned entities

This package creates or expects to own:

```text
input_select.good_morning_tts_target
script.good_morning
script.good_morning_speak
script.good_morning_test
script.morning_current_time
script.morning_current_date
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_turn_on_tv
```

## External dependencies

This package currently assumes the following Home Assistant integrations and entities exist. You can rename or replace them to match your own Home Assistant instance.

### Speech output

Alexa Media Player:

```text
media_player.bedroom_echo_dot
media_player.desk_echo_pop
notify.alexa_media_last_called
```

The default speaker target is managed by:

```text
input_select.good_morning_tts_target
```

Default options:

```text
media_player.desk_echo_pop
last_called
```

`last_called` uses Alexa Media Player's last-called device notification target.

### Weather

Pirate Weather:

```text
weather.pirateweather
```

Used by:

```text
script.morning_rain_forecast
script.morning_temperature_report
```

### Air quality

AirNow:

```text
sensor.airnow_air_quality_index
sensor.airnow_pm10
sensor.airnow_pm2_5
sensor.airnow_ozone
```

Used by:

```text
script.morning_air_quality_report
```

### Allergy

IQVIA:

```text
sensor.allergy_index_today
```

Used by:

```text
script.morning_allergy_report
```

### Volume

The main routine currently calls:

```text
script.set_everywhere_to_volume_5
```

This is intentionally treated as an external dependency. Either create your own volume script, remove this action from `script.good_morning`, or replace it with your preferred volume behavior.

### TV or display startup

The package includes:

```text
script.morning_turn_on_tv
```

This is expected to be customized for your own TV, media player, dashboard, or morning display behavior.

## Installation

Copy the package folder to your Home Assistant configuration directory:

```text
/config/packages/good_morning/
```

For this repository, the source folder is:

```text
home-assistant/packages/good_morning/
```

Enable packages in `configuration.yaml`:

```yaml
homeassistant:
  packages:
    good_morning: !include packages/good_morning/package.yaml
```

If you already have a `homeassistant:` section, merge the `packages:` block into the existing section. Do not create a second top-level `homeassistant:` key.

Then in Home Assistant:

```text
Developer Tools > YAML > Check configuration
Developer Tools > YAML > Reload all YAML configuration
```

After reload, verify these entities exist:

```text
script.good_morning
script.good_morning_speak
input_select.good_morning_tts_target
```

Run the smoke test:

```text
script.good_morning_test
```

## Customization

Most users should customize the following before using the package as-is:

- `input_select.good_morning_tts_target` options
- `media_player.desk_echo_pop`
- `weather.pirateweather`
- AirNow entity IDs
- IQVIA allergy entity ID
- `script.set_everywhere_to_volume_5`
- `script.morning_turn_on_tv`

The package is intentionally direct and readable. It favors explicit Home Assistant entity IDs over a heavy abstraction layer.

## Development workflow

This repository is designed to be edited in VS Code and validated before deployment.

Run package checks:

```bash
make check
```

The validation currently checks:

- Package folder shape
- Required script files
- Required script IDs
- Incorrect nested `script:` keys under the script include directory
- YAML linting through GitHub Actions

## Deployment model

The public repo contains only the reusable Home Assistant package and validation logic.

A private deployment repo can clone this public repo, copy only:

```text
home-assistant/packages/good_morning/
```

to:

```text
/config/packages/good_morning/
```

then run:

```text
ha core check
```

and call Home Assistant's `homeassistant.reload_all` service.

A deployment flow can also back up the existing package folder and roll back automatically if `ha core check` fails.

This keeps the public repo safe to share while keeping private URLs, tokens, SSH configuration, and deployment credentials out of the public project.

## Repository layout

```text
.
├── .github/
│   └── workflows/
│       └── validate.yml
├── home-assistant/
│   ├── README.md
│   └── packages/
│       └── good_morning/
│           ├── README.md
│           ├── package.yaml
│           └── scripts/
├── scripts/
│   └── check-package-shape.sh
├── .gitignore
├── .yamllint.yml
├── Makefile
└── README.md
```

## Design notes

The central design choice is to separate message generation from speech delivery.

Report scripts build messages:

```text
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
```

The speech wrapper handles delivery:

```text
script.good_morning_speak
```

That makes it easier to change output transports later. For example, the current implementation uses Alexa Media Player, but the reports could later be routed through Home Assistant Assist, Music Assistant, Wyoming satellites, or another TTS path by changing the speech wrapper instead of every report script.

## Status

This is a working personal Home Assistant package. It is shared as an example of a modular, Git-managed Home Assistant routine rather than as a plug-and-play integration.

The scripts are intentionally simple YAML and Jinja so they can be inspected, copied, modified, and adapted.
