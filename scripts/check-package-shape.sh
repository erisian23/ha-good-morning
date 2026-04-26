#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="home-assistant/packages/good_morning"
SCRIPTS_DIR="${PACKAGE_DIR}/scripts"

required_files=(
  "${PACKAGE_DIR}/package.yaml"
  "${SCRIPTS_DIR}/speak.yaml"
  "${SCRIPTS_DIR}/good_morning.yaml"
  "${SCRIPTS_DIR}/current_time.yaml"
  "${SCRIPTS_DIR}/current_date.yaml"
  "${SCRIPTS_DIR}/allergy_report.yaml"
  "${SCRIPTS_DIR}/air_quality_report.yaml"
  "${SCRIPTS_DIR}/rain_forecast.yaml"
  "${SCRIPTS_DIR}/temperature_report.yaml"
  "${SCRIPTS_DIR}/turn_on_tv.yaml"
)

required_script_ids=(
  "good_morning_speak"
  "good_morning"
  "morning_current_time"
  "morning_current_date"
  "morning_allergy_report"
  "morning_air_quality_report"
  "morning_rain_forecast"
  "morning_temperature_report"
  "morning_turn_on_tv"
)

echo "Checking required files..."
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "ERROR: Missing file: $file" >&2
    exit 1
  fi
done

echo "Checking package include..."
if ! grep -q '^script: !include_dir_merge_named scripts' "${PACKAGE_DIR}/package.yaml"; then
  echo "ERROR: package.yaml must contain: script: !include_dir_merge_named scripts" >&2
  exit 1
fi

echo "Checking script IDs..."
for script_id in "${required_script_ids[@]}"; do
  if ! grep -R -q "^${script_id}:" "${SCRIPTS_DIR}"; then
    echo "ERROR: Missing script ID: ${script_id}" >&2
    exit 1
  fi
done

echo "Checking for incorrect nested top-level script: keys..."
if grep -R -n '^script:' "${SCRIPTS_DIR}"; then
  echo "ERROR: Do not put top-level script: inside files under scripts/." >&2
  exit 1
fi

echo "Package shape looks good."
