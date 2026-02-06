#!/usr/bin/env bash
set -euxo pipefail

: "${IMAGE_NAME:?IMAGE_NAME missing}"
: "${IMAGE_TAG:?IMAGE_TAG missing}"

mkdir -p reports/trivy

trivy image --scanners vuln --no-progress --severity HIGH,CRITICAL \
  --format json --output reports/trivy/trivy-image.json "${IMAGE_NAME}:${IMAGE_TAG}"

trivy image \
  --scanners vuln \
  --no-progress \
  --severity HIGH,CRITICAL \
  --format template \
  --template "@ci/trivy-html.tpl" \
  --output reports/trivy/trivy-image.html \
  "${IMAGE_NAME}:${IMAGE_TAG}" || true

trivy image --scanners vuln --no-progress --severity HIGH,CRITICAL \
  --format table --output reports/trivy/trivy-image.txt "${IMAGE_NAME}:${IMAGE_TAG}" || true

python3 - <<'PY'
import json, sys
p="reports/trivy/trivy-image.json"
d=json.load(open(p))
high=crit=0
for r in d.get("Results",[]):
    for v in (r.get("Vulnerabilities") or []):
        if v.get("Severity")=="HIGH": high+=1
        if v.get("Severity")=="CRITICAL": crit+=1
print(f"Findings: HIGH={high} CRITICAL={crit}")
sys.exit(22 if (high+crit)>0 else 0)
PY
