# Good Morning Package Reference

This directory contains the Home Assistant package for the Good Morning routine.

The package is intentionally modular: `package.yaml` owns the package-level configuration, while each script lives in its own file under `scripts/`.

## Directory layout

```text
good_morning/
├── README.md
├── package.yaml
└── scripts/
    ├── air_quality_report.yaml
    ├── allergy_report.yaml
    ├── current_date.yaml
    ├── current_time.yaml
    ├── good_morning.yaml
    ├── rain_forecast.yaml
    ├── speak.yaml
    ├── temperature_report.yaml
    ├── test.yaml
    └── turn_on_tv.yaml
```

## Package entrypoint

`package.yaml` defines package-level helpers and loads all scripts:

```yaml
input_select:
  good_morning_tts_target:
    name: Good Morning TTS Target
    icon: mdi:speaker
    options:
      - media_player.desk_echo_pop
      - last_called
    initial: media_player.desk_echo_pop

script: !include_dir_merge_named scripts
```

Because `script` uses `!include_dir_merge_named`, each file under `scripts/` must start directly with the script entity ID.

Correct:

```yaml
morning_current_time:
  alias: Morning - Current Time
  sequence:
    ...
```

Incorrect:

```yaml
script:
  morning_current_time:
    alias: Morning - Current Time
    sequence:
      ...
```

Also incorrect:

```yaml
alias: Morning - Current Time
sequence:
  ...
```

## Package-owned helper

The package defines:

```text
input_select.good_morning_tts_target
```

Default options:

```text
media_player.desk_echo_pop
last_called
```

Use this helper to change where Good Morning speech is sent without editing every script.

If you previously created this helper through the Home Assistant UI, delete the UI-created helper before enabling the YAML-managed helper. Defining the same helper twice can create conflicts or duplicate entity IDs.

## Package-owned scripts

```text
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

## Script summary

### `script.good_morning`

Main Good Morning routine.

Typical sequence:

```text
script.set_everywhere_to_volume_5
script.morning_current_time
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_current_date
script.morning_turn_on_tv
```

`script.set_everywhere_to_volume_5` is an external dependency and should be customized or removed if it does not exist in your Home Assistant instance.

### `script.good_morning_speak`

Central speech wrapper.

This script accepts:

```text
message
target
```

`message` is required.

`target` is optional. If omitted, the script reads:

```text
input_select.good_morning_tts_target
```

Supported target modes:

```text
media_player.some_echo_or_speaker
last_called
```

If the target is `last_called`, the script calls:

```text
notify.alexa_media_last_called
```

Otherwise, it calls:

```text
notify.alexa_media
```

with the selected media player as the target.

### `script.good_morning_test`

Smoke test script.

It should speak a short confirmation message through `script.good_morning_speak`.

Use this after installation or deployment to confirm the package is loaded and speech output works.

### `script.morning_current_time`

Announces the current time using Home Assistant's local timezone.

Example output:

```text
Good morning. It is 6 oh 5 A M.
```

### `script.morning_current_date`

Announces today's date.

Example output:

```text
Today is Saturday, April 25th, 2026.
```

### `script.morning_allergy_report`

Reads:

```text
sensor.allergy_index_today
```

Interprets the IQVIA allergy index using the documented range:

```text
0.0 - 2.4   Low
2.5 - 4.8   Low/Medium
4.9 - 7.2   Medium
7.3 - 9.6   Medium/High
9.7 - 12.0  High
```

Then speaks a short allergy report.

### `script.morning_air_quality_report`

Reads AirNow AQI entities:

```text
sensor.airnow_air_quality_index
sensor.airnow_pm10
sensor.airnow_pm2_5
sensor.airnow_ozone
```

It reports the overall AQI category and compares pollutant-specific AQI values to identify the likely dominant contributor.

AQI interpretation:

```text
0 - 50      Good
51 - 100    Moderate
101 - 150   Unhealthy for sensitive groups
151 - 200   Unhealthy
201 - 300   Very unhealthy
301+        Hazardous
```

### `script.morning_rain_forecast`

Uses:

```text
weather.pirateweather
```

Calls:

```text
weather.get_forecasts
```

with:

```text
type: daily
```

Then reports today's precipitation probability and precipitation amount if available.

### `script.morning_temperature_report`

Uses:

```text
weather.pirateweather
```

Reports:

```text
current temperature
apparent temperature, when meaningfully different
today's forecast high
today's forecast low
```

### `script.morning_turn_on_tv`

Customization point for TV, media player, or morning dashboard startup behavior.

This script is expected to be environment-specific.

## External dependencies

### Alexa Media Player

Required for current speech output:

```text
notify.alexa_media
notify.alexa_media_last_called
```

Also expects at least one real media player target, for example:

```text
media_player.desk_echo_pop
```

If you do not use Alexa Media Player, replace `script.good_morning_speak` with your preferred TTS transport.

### Pirate Weather

Required for:

```text
script.morning_rain_forecast
script.morning_temperature_report
```

Expected entity:

```text
weather.pirateweather
```

You can replace this with another `weather.*` entity if it supports `weather.get_forecasts` and exposes the needed forecast fields.

### AirNow

Required for:

```text
script.morning_air_quality_report
```

Expected entities:

```text
sensor.airnow_air_quality_index
sensor.airnow_pm10
sensor.airnow_pm2_5
sensor.airnow_ozone
```

### IQVIA

Required for:

```text
script.morning_allergy_report
```

Expected entity:

```text
sensor.allergy_index_today
```

### Volume script

The main routine currently references:

```text
script.set_everywhere_to_volume_5
```

This is not defined by this package.

Either create that script separately, remove the action from `script.good_morning`, or replace it with your own speaker-volume behavior.

## Installation

Copy this folder to:

```text
/config/packages/good_morning/
```

Enable it from Home Assistant's `configuration.yaml`:

```yaml
homeassistant:
  packages:
    good_morning: !include packages/good_morning/package.yaml
```

If your `configuration.yaml` already has a top-level `homeassistant:` section, merge the `packages:` block into the existing section. Do not create a duplicate `homeassistant:` key.

Then run:

```text
Developer Tools > YAML > Check configuration
Developer Tools > YAML > Reload all YAML configuration
```

## Verification

After reload, verify these exist in Developer Tools > States:

```text
input_select.good_morning_tts_target
script.good_morning
script.good_morning_speak
script.good_morning_test
```

Run:

```text
script.good_morning_test
```

Then run individual report scripts as needed:

```text
script.morning_current_time
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_current_date
```

Finally, run:

```text
script.good_morning
```

## Common mistakes

### The package loads only some scripts

If some scripts appear but others do not, check that each file under `scripts/` starts with the script entity ID.

Correct:

```yaml
morning_air_quality_report:
  alias: Morning - Air Quality Report
```

Incorrect:

```yaml
alias: Morning - Air Quality Report
```

### Duplicate helper entity

If `input_select.good_morning_tts_target_2` appears, you probably had a UI-created helper with the same name/entity ID.

Delete the UI helper or remove the YAML helper, then reload.

### `notify.alexa_media_last_called` does not work as a target

`notify.alexa_media_last_called` is not a media player target. It is a separate notify action.

That is why `script.good_morning_speak` treats `last_called` as a special target mode.

### Weather provider does not include precipitation probability

Not every weather integration exposes the same daily forecast fields.

If the rain report says the provider did not include a rain probability, use a different weather entity or adjust `script.morning_rain_forecast` to match your provider's forecast fields.

## Maintenance notes

This package intentionally keeps each report script small and separate.

That gives cleaner Git diffs and makes it easier to modify one announcement without touching the others.

The central abstraction is:

```text
report scripts generate text
script.good_morning_speak delivers speech
```

If you later move away from Alexa Media Player, update `script.good_morning_speak` instead of rewriting every report script.
