<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Rapport Sécurité - Trivy</title>

  <style>
    :root{
      --critical:#b91c1c;
      --high:#c2410c;
      --medium:#a16207;
      --low:#15803d;

      --bg:#f6f8fc;
      --card:#ffffff;
      --text:#0f172a;
      --muted:#64748b;
      --border:#e2e8f0;

      --shadow: 0 10px 25px rgba(2,8,23,.08);
      --radius: 14px;
      --radius-sm: 10px;
      --accent:#2563eb;
      --accent2:#7c3aed;
    }

    *{box-sizing:border-box}
    body{
      margin:0;
      background:
        radial-gradient(900px 400px at 10% -10%, rgba(37,99,235,.15), transparent 60%),
        radial-gradient(800px 380px at 90% -10%, rgba(124,58,237,.12), transparent 55%),
        var(--bg);
      color:var(--text);
      font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji", "Segoe UI Emoji";
      padding: 28px 18px 60px;
    }

    .container{max-width:1180px;margin:0 auto}
    .card{
      background:var(--card);
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow);
    }

    /* Header */
    header{
      padding:18px 18px 16px;
      display:flex; align-items:center; justify-content:space-between; gap:16px;
      position:sticky; top:10px; z-index:5;
    }
    .brand{display:flex; align-items:center; gap:12px; min-width:0;}
    .logoMark{
      width:44px;height:44px;border-radius:14px;
      background:linear-gradient(135deg, rgba(37,99,235,.15), rgba(124,58,237,.12));
      border:1px solid var(--border);
      display:grid;place-items:center;
    }
    .titleWrap{min-width:0}
    h1{margin:0;font-size:16px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .ts{margin-top:2px;font-size:12px;color:var(--muted)}
    .rightWrap{display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:flex-end}
    .tag{
      display:inline-flex;align-items:center;gap:8px;
      padding:8px 10px;border-radius:999px;
      border:1px solid var(--border);
      background:#fff;
      font-size:12px;color:var(--muted)
    }

    /* Controls */
    .controls{
      margin-top:14px;
      padding:12px 14px;
      display:flex; gap:10px; flex-wrap:wrap;
      align-items:center; justify-content:space-between;
    }
    .left, .right{display:flex; gap:10px; flex-wrap:wrap; align-items:center}
    .btn{
      border:1px solid var(--border);
      background:#fff;
      padding:10px 12px;
      border-radius:999px;
      font-size:12px;
      color:var(--text);
      cursor:pointer;
      display:inline-flex;align-items:center;gap:8px;
      transition:.12s ease;
      user-select:none;
    }
    .btn:hover{transform:translateY(-1px)}
    .btn.active{border-color:rgba(37,99,235,.45); box-shadow:0 0 0 4px rgba(37,99,235,.12)}
    .dot{width:10px;height:10px;border-radius:999px;display:inline-block}
    .dot.critical{background:var(--critical)}
    .dot.high{background:var(--high)}
    .dot.medium{background:var(--medium)}
    .dot.low{background:var(--low)}

    .search{
      position:relative;
    }
    .search input{
      width:min(360px, 82vw);
      padding:10px 12px 10px 36px;
      border-radius:999px;
      border:1px solid var(--border);
      outline:none;
      background:#fff;
      font-size:12px;
    }
    .search svg{
      position:absolute; left:12px; top:50%;
      transform:translateY(-50%);
      width:14px;height:14px;
      stroke:var(--muted);
    }

    /* Summary */
    .summary{
      margin-top:14px;
      padding:14px;
      display:grid;
      grid-template-columns: repeat(6, minmax(0,1fr));
      gap:10px;
    }
    .metric{
      border:1px solid var(--border);
      border-radius:14px;
      padding:12px 12px;
      background:linear-gradient(180deg, #fff, #fbfdff);
      min-height:74px;
    }
    .metric .label{font-size:11px;color:var(--muted);display:flex;align-items:center;gap:8px}
    .metric .value{margin-top:6px;font-size:20px;font-weight:900;letter-spacing:.2px}
    .metric.total .value{color:var(--accent)}
    .metric.critical .value{color:var(--critical)}
    .metric.high .value{color:var(--high)}
    .metric.medium .value{color:var(--medium)}
    .metric.low .value{color:var(--low)}
    @media (max-width: 980px){ .summary{grid-template-columns: repeat(3, minmax(0,1fr));} }
    @media (max-width: 520px){ .summary{grid-template-columns: repeat(2, minmax(0,1fr));} }

    /* Target */
    .target{margin-top:16px; overflow:hidden;}
    .targetHead{
      padding:14px 16px;
      display:flex; align-items:center; justify-content:space-between; gap:10px;
      border-bottom:1px solid var(--border);
      background:linear-gradient(90deg, rgba(37,99,235,.06), rgba(124,58,237,.05));
    }
    .targetLeft{display:flex;align-items:center;gap:10px; min-width:0}
    .targetTitle{font-weight:800;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .targetMeta{font-size:12px;color:var(--muted)}
    .targetActions{display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end}

    .chip{
      display:inline-flex;align-items:center;gap:8px;
      padding:8px 10px;border-radius:999px;
      border:1px solid var(--border);
      background:#fff;
      font-size:12px;color:var(--muted);
      user-select:none;
    }
    .chip b{color:var(--text)}

    .toggle{
      border:1px solid var(--border);
      background:#fff;
      padding:8px 10px;
      border-radius:999px;
      font-size:12px;
      cursor:pointer;
      display:inline-flex;align-items:center;gap:8px;
    }

    /* Table */
    .tableWrap{width:100%; overflow:auto;}
    table{width:100%; border-collapse:separate; border-spacing:0;}
    thead th{
      position:sticky; top:0;
      background:#f8fafc;
      border-bottom:1px solid var(--border);
      padding:12px 14px;
      font-size:11px;
      letter-spacing:.08em;
      text-transform:uppercase;
      color:var(--muted);
      white-space:nowrap;
      cursor:pointer;
      user-select:none;
    }
    thead th .sort{margin-left:8px;opacity:.7}
    tbody td{
      padding:12px 14px;
      border-bottom:1px solid #f1f5f9;
      font-size:13px;
      white-space:nowrap;
      vertical-align:middle;
    }
    tbody tr:hover{background:#f8fafc}
    tbody tr.click{cursor:pointer}

    code{
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono","Courier New", monospace;
      padding:3px 6px;border-radius:8px;
      border:1px solid #e5e7eb;
      background:#f8fafc;
      font-size:12px;
    }

    .badge{
      display:inline-flex;align-items:center;gap:8px;
      padding:6px 10px;
      border-radius:999px;
      font-size:11px;
      font-weight:900;
      letter-spacing:.04em;
      text-transform:uppercase;
      border:1px solid var(--border);
      background:#fff;
    }
    .badge-CRITICAL{border-color:rgba(185,28,28,.25); color:var(--critical); background:rgba(185,28,28,.06)}
    .badge-HIGH{border-color:rgba(194,65,12,.25); color:var(--high); background:rgba(194,65,12,.06)}
    .badge-MEDIUM{border-color:rgba(161,98,7,.25); color:var(--medium); background:rgba(161,98,7,.08)}
    .badge-LOW{border-color:rgba(21,128,61,.25); color:var(--low); background:rgba(21,128,61,.06)}

    .cve{
      color:var(--accent);
      font-weight:800;
      text-decoration:none;
    }
    .cve:hover{text-decoration:underline}

    .noVuln{
      padding:22px 16px;
      color:var(--muted);
      display:flex; align-items:center; gap:10px;
    }
    .ok{
      width:26px;height:26px;border-radius:999px;
      background:rgba(21,128,61,.12);
      border:1px solid rgba(21,128,61,.25);
      display:grid;place-items:center;
      color:var(--low);
      font-weight:900;
    }

    .footer{
      margin-top:18px;
      padding:12px 14px;
      color:var(--muted);
      font-size:12px;
      display:flex; justify-content:space-between; gap:10px; flex-wrap:wrap;
    }

    @media print{
      header{position:static}
      .controls, .footer .hidePrint{display:none !important}
      body{background:#fff; padding:0}
      .card{box-shadow:none}
      thead th{background:#f3f4f6}
    }
  </style>
</head>

<body>
  <div class="container">

    <header class="card">
      <div class="brand">
        <div class="logoMark" aria-hidden="true">
          <!-- simple shield icon (inline, no CDN) -->
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
            <path d="M12 2l8 4v6c0 5-3.2 9.4-8 10-4.8-.6-8-5-8-10V6l8-4z"
                  stroke="#2563eb" stroke-width="2" stroke-linejoin="round"/>
            <path d="M12 6v14" stroke="#7c3aed" stroke-width="2" stroke-linecap="round" opacity=".65"/>
          </svg>
        </div>
        <div class="titleWrap">
          <h1>Rapport de Sécurité – Trivy (Image Docker)</h1>
          <div class="ts">Généré le : {{ now | date "02/01/2006 à 15:04" }}</div>
        </div>
      </div>

      <div class="rightWrap">
        <br />
      </div>
    </header>

        {{- range . }}
        <div class="target-card">
            <div class="target-header">
                <i class="fa-solid fa-box-open"></i>
                <span class="target-title">{{ .Target }}</span>
                <span style="font-size: 12px; color: #94a3b8;">({{ .Type }})</span>
            </div>

            <div class="target-header">
              <br />
              <br />
              <br />
            </div>

            {{- if not .Vulnerabilities }}
            <div class="no-vuln">
                <i class="fa-solid fa-circle-check" style="color: var(--low);"></i>
                Félicitations ! Aucune vulnérabilité détectée.
            </div>
            {{- else }}
            <table>
                <thead>
                    <tr>
                        <th>Sévérité</th>
                        <th>ID Vulnérabilité</th>
                        <th>Paquet / Librairie</th>
                        <th>Installée</th>
                        <th>Correctif</th>
                    </tr>
                </thead>
                <tbody>
                    {{- range .Vulnerabilities }}
                    <tr>
                        <td>
                            <span class="badge badge-{{ .Severity }}">
                                <i class="fa-solid fa-triangle-exclamation"></i> {{ .Severity }}
                            </span>
                        </td>
                        <td><a class="vuln-id" href="{{ .PrimaryURL }}" target="_blank">{{ .VulnerabilityID }}</a></td>
                        <td><strong>{{ .PkgName }}</strong></td>
                        <td><code>{{ .InstalledVersion }}</code></td>
                        <td>
                            {{- if .FixedVersion }}
                            <span style="color: var(--low); font-weight: 600;">{{ .FixedVersion }}</span>
                            {{- else }}
                            <span style="color: #94a3b8; font-style: italic;">Non disponible</span>
                            {{- end }}
                        </td>
                    </tr>
                    {{- end }}
                </tbody>
            </table>
            {{- end }}
        </div>
        {{- end }}
    </div>
</body>
</html>