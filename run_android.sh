#!/bin/bash
# Workaround: Gradle/Java on some Macs route downloads through a broken SOCKS proxy (VPN apps).
# Usage: ./run_android.sh

set -euo pipefail

export JAVA_TOOL_OPTIONS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort= -Dhttp.proxyHost= -Dhttps.proxyHost="
export GRADLE_OPTS="-Djava.net.useSystemProxies=false -DsocksProxyHost= -DsocksProxyPort= -Dhttp.proxyHost= -Dhttps.proxyHost="

cd "$(dirname "$0")"
flutter run "$@"
