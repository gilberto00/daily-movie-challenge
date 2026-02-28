#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

LOCAL_JAVA_HOME="/Users/gilbertorosa/.local/jdk/jdk-21.0.10+7/Contents/Home"
if [[ -d "$LOCAL_JAVA_HOME" ]]; then
  export JAVA_HOME="$LOCAL_JAVA_HOME"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

export PATH="$HOME/.maestro/bin:$PATH"

if ! command -v maestro >/dev/null 2>&1; then
  echo "Maestro nao encontrado no PATH."
  exit 1
fi

mkdir -p .maestro/debug .maestro/artifacts

echo "Running automated scroll validation (5x)..."
for i in 1 2 3 4 5; do
  echo "RUN_$i"
  maestro test ".maestro/result_scroll.yaml" \
    --debug-output ".maestro/debug" \
    --test-output-dir ".maestro/artifacts" \
    --format junit \
    --output ".maestro/result_scroll_report_$i.xml"
done

echo "Done. Reports:"
ls -1 .maestro/result_scroll_report_*.xml
