#!/bin/bash
# Bootstrap Gradle distribution via curl when Java/Gradle wrapper times out (SOCKS proxy issue).
# Run once if `flutter run` fails with: java.net.ConnectException: Operation timed out

set -euo pipefail

GRADLE_VERSION="8.14"
GRADLE_ZIP="gradle-${GRADLE_VERSION}-all.zip"
GRADLE_URL="https://services.gradle.org/distributions/${GRADLE_ZIP}"
GRADLE_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

echo "Downloading ${GRADLE_ZIP} via curl..."
TMP_ZIP="$(mktemp)"
curl -L --fail --retry 3 -o "$TMP_ZIP" "$GRADLE_URL"

# Trigger wrapper to create the hash directory
export JAVA_TOOL_OPTIONS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort="
export GRADLE_OPTS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR/android"
./gradlew --version >/dev/null 2>&1 || true

HASH_DIR="$(ls -d "${GRADLE_HOME}/wrapper/dists/${GRADLE_ZIP%.zip}"/*/ 2>/dev/null | head -1 || true)"

if [ -z "$HASH_DIR" ]; then
  echo "Could not determine Gradle cache directory. Try running ./gradlew --version once, then re-run this script."
  exit 1
fi

echo "Installing into: $HASH_DIR"
cp "$TMP_ZIP" "${HASH_DIR}/${GRADLE_ZIP}"
touch "${HASH_DIR}/${GRADLE_ZIP}.ok"
unzip -q -o "${HASH_DIR}/${GRADLE_ZIP}" -d "$HASH_DIR"
rm -f "$TMP_ZIP"

echo "Gradle ${GRADLE_VERSION} installed. Now run: ./run_android.sh"
