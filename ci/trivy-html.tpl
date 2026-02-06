{{- $report := . -}}
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>Trivy Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 18px; }
    h1 { margin: 0 0 6px 0; }
    .meta { color: #555; margin-bottom: 14px; }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    th, td { border: 1px solid #ddd; padding: 8px; vertical-align: top; }
    th { background: #f5f5f5; text-align: left; }
    .sev-CRITICAL { font-weight: bold; color: #b00020; }
    .sev-HIGH { font-weight: bold; color: #c06000; }
    .sev-MEDIUM { color: #7a5a00; }
    .sev-LOW { color: #2d6a2d; }
    .badge { display:inline-block; padding:2px 8px; border-radius:10px; background:#eee; font-size:12px; }
    .target { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 12px; color:#444;}
  </style>
</head>
<body>
  <h1>Trivy Vulnerability Report</h1>
  <div class="meta">
    Generated at: <span class="badge">{{ now }}</span>
  </div>

  {{- range $r := $report.Results }}
    <h2>Target: <span class="target">{{ $r.Target }}</span> <span class="badge">{{ $r.Type }}</span></h2>
    {{- if not $r.Vulnerabilities }}
      <p>No vulnerabilities found for this target.</p>
    {{- else }}
      <table>
        <thead>
          <tr>
            <th>Severity</th>
            <th>Vuln ID</th>
            <th>Package</th>
            <th>Installed</th>
            <th>Fixed</th>
            <th>Title</th>
          </tr>
        </thead>
        <tbody>
          {{- range $v := $r.Vulnerabilities }}
          <tr>
            <td class="sev-{{ $v.Severity }}">{{ $v.Severity }}</td>
            <td>{{ $v.VulnerabilityID }}</td>
            <td>{{ $v.PkgName }}</td>
            <td>{{ $v.InstalledVersion }}</td>
            <td>{{ $v.FixedVersion }}</td>
            <td>{{ $v.Title }}</td>
          </tr>
          {{- end }}
        </tbody>
      </table>
    {{- end }}
  {{- end }}
</body>
</html>
