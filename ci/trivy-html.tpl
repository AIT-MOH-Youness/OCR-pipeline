{{- range . }}
    <h2>Target: <span class="target">{{ .Target }}</span> <span class="badge">{{ .Class }}</span></h2>
    {{- if not .Vulnerabilities }}
      <p>No vulnerabilities found for this target.</p>
    {{- else }}
      <table>
        <thead>
          <tr>
            <th>Severity</th>
            <th>ID</th>
            <th>Package</th>
            <th>Installed</th>
            <th>Fixed</th>
          </tr>
        </thead>
        <tbody>
          {{- range .Vulnerabilities }}
          <tr>
            <td class="sev-{{ .Severity }}">{{ .Severity }}</td>
            <td><a href="{{ .PrimaryURL }}">{{ .VulnerabilityID }}</a></td>
            <td>{{ .PkgName }}</td>
            <td>{{ .InstalledVersion }}</td>
            <td>{{ .FixedVersion }}</td>
          </tr>
          {{- end }}
        </tbody>
      </table>
    {{- end }}
  {{- end }}