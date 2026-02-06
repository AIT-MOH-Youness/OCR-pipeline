<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Sécurité - Trivy</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --critical: #dc2626;
            --high: #ea580c;
            --medium: #ca8a04;
            --low: #16a34a;
            --bg-body: #f8fafc;
            --bg-card: #ffffff;
            --text-main: #1e293b;
        }

        body { 
            font-family: 'Inter', sans-serif; 
            background-color: var(--bg-body); 
            color: var(--text-main);
            margin: 0; padding: 40px;
        }

        .container { max-width: 1100px; margin: 0 auto; }

        header { 
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 30px; border-bottom: 2px solid #e2e8f0; padding-bottom: 20px;
        }

        h1 { margin: 0; font-size: 24px; font-weight: 700; color: #0f172a; }

        .timestamp { font-size: 14px; color: #64748b; }

        /* Style des cartes de cibles */
        .target-card {
            background: var(--bg-card);
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            margin-bottom: 30px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }

        .target-header {
            background: #f1f5f9;
            padding: 15px 25px;
            border-bottom: 1px solid #e2e8f0;
            display: flex; align-items: center; gap: 10px;
        }

        .target-title { font-weight: 600; font-size: 16px; color: #334155; }

        /* Tableaux stylés */
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th { 
            padding: 12px 25px; background: #f8fafc; 
            font-size: 12px; text-transform: uppercase; color: #64748b;
        }
        td { padding: 15px 25px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
        
        tr:hover { background-color: #f8fafc; transition: 0.2s; }

        /* Badges de sévérité */
        .badge {
            padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;
            text-transform: uppercase; display: inline-flex; align-items: center; gap: 5px;
        }
        .badge-CRITICAL { background: #fee2e2; color: var(--critical); border: 1px solid #fecaca; }
        .badge-HIGH { background: #ffedd5; color: var(--high); border: 1px solid #fed7aa; }
        .badge-MEDIUM { background: #fef9c3; color: var(--medium); border: 1px solid #fef08a; }
        .badge-LOW { background: #dcfce7; color: var(--low); border: 1px solid #bbf7d0; }

        .vuln-id { color: #2563eb; font-weight: 600; text-decoration: none; }
        .vuln-id:hover { text-decoration: underline; }

        .no-vuln { padding: 40px; text-align: center; color: #94a3b8; }
        .no-vuln i { font-size: 48px; margin-bottom: 10px; display: block; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1><i class="fa-solid fa-shield-halved"></i> Rapport de Sécurité Image Docker</h1>
                <div class="timestamp">Généré le : {{ now | date "02/01/2006 à 15:04" }}</div>
            </div>
            <img src="https://raw.githubusercontent.com/aquasecurity/trivy/main/docs/images/logo.png" height="40" alt="Trivy Logo">
        </header>

        {{- range . }}
        <div class="target-card">
            <div class="target-header">
                <i class="fa-solid fa-box-open"></i>
                <span class="target-title">{{ .Target }}</span>
                <span style="font-size: 12px; color: #94a3b8;">({{ .Type }})</span>
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