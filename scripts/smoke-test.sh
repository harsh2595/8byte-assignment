#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-${APP_URL:-}}"
RETRIES="${SMOKE_RETRIES:-12}"
SLEEP_SECONDS="${SMOKE_SLEEP_SECONDS:-5}"

if [[ -z "${BASE_URL}" ]]; then
  echo "Usage: bash scripts/smoke-test.sh <base-url>"
  echo "Or set APP_URL=<base-url>."
  exit 2
fi

BASE_URL="${BASE_URL%/}"

check_endpoint() {
  local path="$1"
  local expected_text="$2"
  local url="${BASE_URL}${path}"

  echo "Checking ${url}"

  for attempt in $(seq 1 "${RETRIES}"); do
    if response="$(curl -fsS --max-time 10 "${url}")"; then
      if [[ "${response}" == *"${expected_text}"* ]]; then
        echo "OK ${path}"
        return 0
      fi

      echo "Unexpected response from ${path}: ${response}"
    else
      echo "Attempt ${attempt}/${RETRIES} failed for ${path}"
    fi

    sleep "${SLEEP_SECONDS}"
  done

  echo "Smoke test failed for ${path}"
  return 1
}

check_endpoint "/health" "\"status\":\"ok\""
check_endpoint "/ready" "\"status\":\"ready\""

echo "Smoke test passed for ${BASE_URL}"
