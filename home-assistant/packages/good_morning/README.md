# Good Morning Package Reference

Technical reference for the Good Morning Home Assistant package.

For the high-level project overview, see the [root README](../../../README.md).

## Directory Layout

```text
good_morning/
|-- README.md
|-- package.yaml
`-- scripts/
    |-- air_quality_report.yaml
    |-- allergy_report.yaml
    |-- current_date.yaml
    |-- current_time.yaml
    |-- good_morning.yaml
    |-- rain_forecast.yaml
    |-- speak.yaml
    |-- speak_test.yaml
    |-- speak_test_all.yaml
    |-- temperature_report.yaml
    `-- turn_on_tv.yaml
```

`package.yaml` owns package-level configuration. Each script lives in its own file under `scripts/` so changes stay small and reviewable.

## Package Entrypoint

`package.yaml` defines the TTS target helper and loads all scripts:

```yaml
input_select:
  good_morning_tts_target:
    name: Good Morning TTS Target
    icon: mdi:speaker
    options:
      - media_player.desk_echo_pop
      - media_player.bedroom_echo_dot
      - last_called
    initial: media_player.desk_echo_pop

script: !include_dir_merge_named scripts
```

Because `script` uses `!include_dir_merge_named`, files under `scripts/` must start directly with the script entity ID.

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

## Package-Owned Entities

Helper:

```text
input_select.good_morning_tts_target
```

Scripts:

```text
script.good_morning
script.good_morning_speak
script.good_morning_speak_test
script.good_morning_speak_test_all
script.morning_current_time
script.morning_current_date
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_turn_on_tv
```

If you previously created `input_select.good_morning_tts_target` through the Home Assistant UI,
delete the UI-created helper before enabling this YAML-managed helper.
Defining the same helper twice can create conflicts or duplicate entity IDs.

## External Dependencies

### Alexa Media Player

Required for the current speech output:

```text
notify.alexa_media
notify.alexa_media_last_called
```

The package also expects real media player targets in `input_select.good_morning_tts_target`, currently:

```text
media_player.desk_echo_pop
media_player.bedroom_echo_dot
```

`last_called` is a special helper option.
It sends speech through `notify.alexa_media_last_called` instead of treating that notify service as a media player entity.

If you do not use Alexa Media Player, replace `script.good_morning_speak` with your preferred TTS transport.
The report scripts call the wrapper instead of calling Alexa directly.

### Pirate Weather

Required by:

```text
script.morning_rain_forecast
script.morning_temperature_report
```

Expected entity:

```text
weather.pirateweather
```

You can replace this with another `weather.*` entity if it supports `weather.get_forecasts` with `type: daily` and provides the fields used by the scripts.

### AirNow

Required by:

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

Required by:

```text
script.morning_allergy_report
```

Expected entity:

```text
sensor.allergy_index_today
```

### Volume Script

The main routine can call:

```text
script.set_everywhere_to_volume_5
```

This script is not defined by this package.
`script.good_morning` checks whether the entity exists before calling it.
Create that script separately, remove the action, or replace it with your own speaker-volume behavior.

## Script Reference

### `script.good_morning`

Main Good Morning routine.

Sequence:

```text
script.set_everywhere_to_volume_5, if available
script.morning_current_time
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_current_date
script.morning_turn_on_tv, if available
```

### `script.good_morning_speak`

Central speech wrapper.

Accepted fields:

```text
message
target
```

`message` is required. `target` is optional. If `target` is omitted, the script reads:

```text
input_select.good_morning_tts_target
```

Supported target modes:

```text
media_player.some_echo_or_speaker
last_called
```

Blank messages and invalid targets stop the script with an error.

### `script.good_morning_speak_test`

Smoke test for the speech wrapper.

It sends a short confirmation message through `script.good_morning_speak`.
Use this after installation or deployment to confirm the package is loaded and TTS delivery works.

### `script.good_morning_speak_test_all`

Runs the morning report scripts in sequence with short delays between them:

```text
script.morning_current_time
script.morning_allergy_report
script.morning_air_quality_report
script.morning_rain_forecast
script.morning_temperature_report
script.morning_current_date
```

Use this to test the report scripts without running the TV/display startup step.

### `script.morning_current_time`

Announces the current time using Home Assistant's local timezone.

Example output:

```text
Good morning. It is 6 oh 5 A M.
```

### `script.morning_current_date`

Announces today's date with an ordinal day suffix.

Example output:

```text
Today is Saturday, April 25th, 2026.
```

### `script.morning_allergy_report`

Reads:

```text
sensor.allergy_index_today
```

Interprets the IQVIA allergy index using these ranges:

```text
0.0 - 2.4   Low
2.5 - 4.8   Low to medium
4.9 - 7.2   Medium
7.3 - 9.6   Medium to high
9.7+        High
```

If the sensor cannot be read as a number, the script says it could not get today's allergy index.

### `script.morning_air_quality_report`

Reads:

```text
sensor.airnow_air_quality_index
sensor.airnow_pm10
sensor.airnow_pm2_5
sensor.airnow_ozone
```

The spoken report includes the current outdoor AQI, its category, and a short health note when the AQI is above the good range.

AQI interpretation:

```text
0 - 50      Good
51 - 100    Moderate
101 - 150   Unhealthy for sensitive groups
151 - 200   Unhealthy
201 - 300   Very unhealthy
301+        Hazardous
```

If the overall AQI cannot be read, the script says it could not get the current outdoor air quality report.

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

The spoken report uses today's `precipitation_probability`.
If a positive `precipitation` amount is available, it also reports the expected precipitation amount using the weather entity's precipitation unit.

If no forecast is returned, the script says it could not get today's rain forecast.
If the provider omits precipitation probability, the script says the provider did not include a rain probability.

### `script.morning_temperature_report`

Uses:

```text
weather.pirateweather
```

Reads the weather entity's current temperature attributes and daily forecast.

The spoken report can include:

```text
current temperature
apparent temperature, when meaningfully different
today's forecast high
today's forecast low
```

If current temperature is unavailable, the script says it could not get the current temperature.

### `script.morning_turn_on_tv`

Environment-specific TV or morning display startup behavior.

Current actions:

```text
remote.turn_on remote.onn_4k_plus
delay 1 second
media_player.volume_set media_player.living_room_tv to 0.2
androidtv.adb_command to launch com.wbd.stream/com.wbd.beam.BeamActivity
```

Customize or remove this script if those entities, device IDs, or app package names do not match your Home Assistant instance.

## Installation

Copy this package folder to your Home Assistant configuration directory:

```text
/config/packages/good_morning/
```

Enable it from Home Assistant's `configuration.yaml`:

```yaml
homeassistant:
  packages:
    good_morning: !include packages/good_morning/package.yaml
```

If your `configuration.yaml` already has a top-level `homeassistant:` section, merge the `packages:` block into the existing section.
Do not create a duplicate `homeassistant:` key.

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
script.good_morning_speak_test
script.good_morning_speak_test_all
```

Run the speech smoke test:

```text
script.good_morning_speak_test
```

Run the report test:

```text
script.good_morning_speak_test_all
```

Then run the full routine:

```text
script.good_morning
```

## Customization Checklist

Most users should review these before using the package as-is:

- `input_select.good_morning_tts_target` options
- `media_player.desk_echo_pop`
- `media_player.bedroom_echo_dot`
- `weather.pirateweather`
- AirNow entity IDs
- IQVIA allergy entity ID
- `script.set_everywhere_to_volume_5`
- `script.morning_turn_on_tv`

The package favors explicit Home Assistant entity IDs over a heavier abstraction layer.
That makes the YAML easy to read, but it also means local entity names should be checked carefully.

## Validation

From the repository root:

```bash
make check
```

This verifies required package files, required script IDs, the package include, and incorrect nested `script:` keys under `scripts/`.

For YAML linting:

```bash
yamllint home-assistant
```

GitHub Actions runs the package shape check and `yamllint` for this package.

## Common Mistakes

### The package loads only some scripts

Check that each file under `scripts/` starts with the script entity ID.

Correct:

```yaml
morning_air_quality_report:
  alias: Morning - Air Quality Report
```

Incorrect:

```yaml
alias: Morning - Air Quality Report
```

### A duplicate helper entity appears

If `input_select.good_morning_tts_target_2` appears, you probably had a UI-created helper with the same name or entity ID.

Delete the UI helper or remove the YAML helper, then reload YAML.

### `notify.alexa_media_last_called` does not work as a target

`notify.alexa_media_last_called` is not a media player target. It is a separate notify action.

Use `last_called` as the value of `input_select.good_morning_tts_target`, or pass `target: last_called` to `script.good_morning_speak`.

### Weather provider does not include rain probability

Not every weather integration exposes the same daily forecast fields.

If the rain report says the provider did not include a rain probability, use a different weather entity or adjust `script.morning_rain_forecast`
to match your provider's forecast fields.

## Maintenance Notes

This package intentionally keeps each report script small and separate.

The key abstraction is:

```text
report scripts generate text
script.good_morning_speak delivers speech
```

If you later move away from Alexa Media Player, update `script.good_morning_speak` instead of rewriting every report script.
