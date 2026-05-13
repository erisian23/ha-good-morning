#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="home-assistant/packages/good_morning"
INPUT_SELECTS_DIR="${PACKAGE_DIR}/input_selects"
SCRIPTS_DIR="${PACKAGE_DIR}/scripts"

required_files=(
  "${PACKAGE_DIR}/package.yaml"
  "${INPUT_SELECTS_DIR}/tts_target.yaml"
  "${SCRIPTS_DIR}/speak.yaml"
  "${SCRIPTS_DIR}/speak_test.yaml"
  "${SCRIPTS_DIR}/speak_test_all.yaml"
  "${SCRIPTS_DIR}/good_morning.yaml"
  "${SCRIPTS_DIR}/current_time.yaml"
  "${SCRIPTS_DIR}/current_date.yaml"
  "${SCRIPTS_DIR}/allergy_report.yaml"
  "${SCRIPTS_DIR}/air_quality_report.yaml"
  "${SCRIPTS_DIR}/rain_forecast.yaml"
  "${SCRIPTS_DIR}/temperature_report.yaml"
  "${SCRIPTS_DIR}/turn_on_tv.yaml"
)

required_input_select_files_and_ids=(
  "${INPUT_SELECTS_DIR}/tts_target.yaml:good_morning_tts_target"
)

required_script_files_and_ids=(
  "${SCRIPTS_DIR}/speak.yaml:good_morning_speak"
  "${SCRIPTS_DIR}/speak_test.yaml:good_morning_speak_test"
  "${SCRIPTS_DIR}/speak_test_all.yaml:good_morning_speak_test_all"
  "${SCRIPTS_DIR}/good_morning.yaml:good_morning"
  "${SCRIPTS_DIR}/current_time.yaml:morning_current_time"
  "${SCRIPTS_DIR}/current_date.yaml:morning_current_date"
  "${SCRIPTS_DIR}/allergy_report.yaml:morning_allergy_report"
  "${SCRIPTS_DIR}/air_quality_report.yaml:morning_air_quality_report"
  "${SCRIPTS_DIR}/rain_forecast.yaml:morning_rain_forecast"
  "${SCRIPTS_DIR}/temperature_report.yaml:morning_temperature_report"
  "${SCRIPTS_DIR}/turn_on_tv.yaml:morning_turn_on_tv"
)

echo "Checking required files..."
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: Missing file: $file" >&2
    exit 1
  fi
done

echo "Checking package input_select include..."
if ! grep -Fxq 'input_select: !include_dir_merge_named input_selects' "${PACKAGE_DIR}/package.yaml"; then
  echo "ERROR: package.yaml must contain: input_select: !include_dir_merge_named input_selects" >&2
  exit 1
fi

echo "Checking package script include..."
if ! grep -Fxq 'script: !include_dir_merge_named scripts' "${PACKAGE_DIR}/package.yaml"; then
  echo "ERROR: package.yaml must contain: script: !include_dir_merge_named scripts" >&2
  exit 1
fi

echo "Checking input_select IDs..."
for file_and_id in "${required_input_select_files_and_ids[@]}"; do
  file="${file_and_id%%:*}"
  input_select_id="${file_and_id##*:}"

  if ! grep -q "^${input_select_id}:" "$file"; then
    echo "ERROR: Missing input_select ID '${input_select_id}' in ${file}" >&2
    exit 1
  fi
done

echo "Checking script IDs..."
for file_and_id in "${required_script_files_and_ids[@]}"; do
  file="${file_and_id%%:*}"
  script_id="${file_and_id##*:}"

  if ! grep -q "^${script_id}:" "$file"; then
    echo "ERROR: Missing script ID '${script_id}' in ${file}" >&2
    exit 1
  fi
done

echo "Checking for incorrect nested top-level input_select: keys..."
if grep -R -n '^input_select:' "${INPUT_SELECTS_DIR}"; then
  echo "ERROR: Do not put top-level input_select: inside files under input_selects/." >&2
  exit 1
fi

echo "Checking for incorrect nested top-level script: keys..."
if grep -R -n '^script:' "${SCRIPTS_DIR}"; then
  echo "ERROR: Do not put top-level script: inside files under scripts/." >&2
  exit 1
fi

echo "Package shape looks good."
