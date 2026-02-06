<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Dashboard Sécurité - Trivy</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

  <style>
    :root{
      --critical:#dc2626;
      --high:#ea580c;
      --medium:#ca8a04;
      --low:#16a34a;

      --bg0:#0b1220;
      --bg1:#0f172a;
      --card:rgba(255,255,255,.06);
      --card2:rgba(255,255,255,.08);
      --border:rgba(148,163,184,.20);
      --text:#e5e7eb;
      --muted:#94a3b8;
      --accent:#60a5fa;
      --shadow: 0 20px 40px rgba(0,0,0,.35);
      --radius:16px;
      --radius-sm:12px;
    }

    *{box-sizing:border-box}
    html,body{height:100%}
    body{
      font-family:'Inter',sans-serif;
      margin:0;
      background:
        radial-gradient(900px 500px at 20% -10%, rgba(96,165,250,.25), transparent 60%),
        radial-gradient(700px 450px at 90% 10%, rgba(34,197,94,.14), transparent 55%),
        radial-gradient(900px 600px at 50% 110%, rgba(234,88,12,.14), transparent 55%),
        linear-gradient(180deg, var(--bg0), var(--bg1));
      color:var(--text);
      padding:28px 18px 50px;
    }
    a{color:inherit}
    .container{max-width:1200px;margin:0 auto}
    .glass{
      background:linear-gradient(180deg, rgba(255,255,255,.08), rgba(255,255,255,.05));
      border:1px solid var(--border);
      border-radius:var(--radius);
      box-shadow:var(--shadow);
      backdrop-filter: blur(10px);
    }

    /* Header */
    header{
      display:flex; align-items:center; justify-content:space-between;
      gap:16px; padding:18px 18px 16px;
      position:sticky; top:10px; z-index:10;
    }
    .brand{
      display:flex; align-items:center; gap:12px;
      min-width: 0;
    }
    .brand .icon{
      width:44px;height:44px;border-radius:14px;
      display:grid;place-items:center;
      background:linear-gradient(135deg, rgba(96,165,250,.25), rgba(255,255,255,.06));
      border:1px solid var(--border);
    }
    .brand h1{
      margin:0; font-size:16px; font-weight:800; letter-spacing:.2px;
      white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
    }
    .timestamp{font-size:12px;color:var(--muted);margin-top:2px}
    .logo{
      display:flex;align-items:center;gap:10px;
      opacity:.95;
    }
    .logo img{height:34px; filter: drop-shadow(0 6px 14px rgba(0,0,0,.25));}

    /* Controls */
    .controls{
      margin-top:14px;
      padding:14px 16px;
      display:flex; flex-wrap:wrap; gap:10px;
      align-items:center; justify-content:space-between;
    }
    .controls-left,.controls-right{display:flex; flex-wrap:wrap; gap:10px; align-items:center}
    .pill{
      display:inline-flex; align-items:center; gap:8px;
      padding:10px 12px;
      border-radius:999px;
      border:1px solid var(--border);
      background:rgba(255,255,255,.04);
      color:var(--muted);
      font-size:12px;
    }
    .pill strong{color:var(--text)}
    .btn{
      cursor:pointer;
      border:1px solid var(--border);
      background:rgba(255,255,255,.04);
      color:var(--text);
      padding:10px 12px;
      border-radius:999px;
      font-size:12px;
      display:inline-flex; align-items:center; gap:8px;
      transition:.15s ease;
    }
    .btn:hover{transform:translateY(-1px); background:rgba(255,255,255,.07)}
    .btn.active{
      border-color:rgba(96,165,250,.55);
      box-shadow:0 0 0 4px rgba(96,165,250,.12);
    }
    .search{
      position:relative;
    }
    .search input{
      width:min(360px, 74vw);
      padding:10px 12px 10px 36px;
      border-radius:999px;
      border:1px solid var(--border);
      outline:none;
      background:rgba(0,0,0,.12);
      color:var(--text);
      font-size:12px;
    }
    .search i{
      position:absolute; left:12px; top:50%; transform:translateY(-50%);
      color:var(--muted); font-size:13px;
    }
    .hint{
      color:var(--muted); font-size:12px; display:flex; gap:8px; align-items:center;
    }
    kbd{
      font-family:inherit;
      border:1px solid var(--border);
      background:rgba(255,255,255,.04);
      border-bottom-color:rgba(255,255,255,.12);
      border-radius:8px;
      padding:2px 6px;
      font-size:11px;
      color:var(--text);
    }

    /* Summary grid */
    .summary{
      margin-top:14px;
      padding:14px 16px;
      display:grid;
      grid-template-columns: repeat(6, minmax(0, 1fr));
      gap:10px;
    }
    .metric{
      padding:12px 12px;
      border-radius:14px;
      border:1px solid var(--border);
      background:rgba(255,255,255,.04);
      min-height:72px;
    }
    .metric .label{font-size:11px;color:var(--muted);display:flex;gap:8px;align-items:center}
    .metric .value{margin-top:6px;font-size:18px;font-weight:800;letter-spacing:.2px}
    .metric.critical .value{color:var(--critical)}
    .metric.high .value{color:var(--high)}
    .metric.medium .value{color:var(--medium)}
    .metric.low .value{color:var(--low)}
    .metric.total .value{color:var(--accent)}
    @media (max-width: 960px){
      .summary{grid-template-columns: repeat(3, minmax(0,1fr));}
    }
    @media (max-width: 520px){
      .summary{grid-template-columns: repeat(2, minmax(0,1fr));}
    }

    /* Target cards */
    .target-card{ margin-top:16px; overflow:hidden; }
    .target-header{
      padding:14px 16px;
      display:flex; align-items:center; justify-content:space-between; gap:12px;
      border-bottom:1px solid var(--border);
      background:linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.03));
    }
    .target-left{display:flex;align-items:center;gap:10px; min-width:0;}
    .target-title{font-weight:700;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .target-meta{color:var(--muted);font-size:12px}
    .chips{display:flex; gap:8px; flex-wrap:wrap; justify-content:flex-end}
    .chip{
      display:inline-flex;align-items:center;gap:8px;
      padding:8px 10px;
      border-radius:999px;
      background:rgba(255,255,255,.04);
      border:1px solid var(--border);
      font-size:12px;
      color:var(--muted);
      user-select:none;
    }
    .chip b{color:var(--text)}
    .chip .dot{width:8px;height:8px;border-radius:99px;display:inline-block}
    .dot.critical{background:var(--critical)}
    .dot.high{background:var(--high)}
    .dot.medium{background:var(--medium)}
    .dot.low{background:var(--low)}

    .no-vuln{
      padding:26px 16px;
      display:flex;align-items:center;justify-content:center;gap:10px;
      color:var(--muted);
    }
    .no-vuln i{color:var(--low); font-size:18px}

    /* Table */
    .table-wrap{width:100%; overflow:auto;}
    table{width:100%; border-collapse:separate; border-spacing:0}
    thead th{
      position:sticky; top:0;
      background:rgba(3,7,18,.55);
      backdrop-filter: blur(8px);
      border-bottom:1px solid var(--border);
      text-align:left;
      padding:12px 14px;
      font-size:11px;
      letter-spacing:.08em;
      text-transform:uppercase;
      color:var(--muted);
      cursor:pointer;
      user-select:none;
      white-space:nowrap;
    }
    thead th .sort{
      margin-left:8px; opacity:.6; font-size:11px;
    }
    tbody td{
      padding:12px 14px;
      border-bottom:1px solid rgba(148,163,184,.14);
      font-size:13px;
      vertical-align:middle;
      white-space:nowrap;
    }
    tbody tr{
      transition:.12s ease;
      background:transparent;
    }
    tbody tr:hover{
      background:rgba(255,255,255,.04);
    }
    tbody tr.clickable{cursor:pointer}
    code{
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
      padding:3px 6px;
      border-radius:8px;
      border:1px solid rgba(148,163,184,.18);
      background:rgba(0,0,0,.20);
      color:rgba(226,232,240,.95);
      font-size:12px;
    }

    /* Badges */
    .badge{
      display:inline-flex;align-items:center;gap:8px;
      padding:6px 10px;
      border-radius:999px;
      font-size:11px;
      font-weight:800;
      letter-spacing:.04em;
      text-transform:uppercase;
      border:1px solid rgba(255,255,255,.10);
    }
    .badge i{font-size:12px}
    .badge-CRITICAL{background:rgba(220,38,38,.15); color:#fecaca; border-color:rgba(220,38,38,.35)}
    .badge-HIGH{background:rgba(234,88,12,.14); color:#fed7aa; border-color:rgba(234,88,12,.32)}
    .badge-MEDIUM{background:rgba(202,138,4,.16); color:#fde68a; border-color:rgba(202,138,4,.30)}
    .badge-LOW{background:rgba(22,163,74,.14); color:#bbf7d0; border-color:rgba(22,163,74,.28)}

    .vuln-id{
      color:#93c5fd;
      text-decoration:none;
      font-weight:700;
    }
    .vuln-id:hover{text-decoration:underline}
    .muted{color:var(--muted)}
    .fix-ok{color:#86efac; font-weight:700}
    .fix-na{color:var(--muted); font-style:italic}

    /* Footer note */
    .footer{
      margin-top:18px;
      color:var(--muted);
      font-size:12px;
      display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap;
      padding:14px 16px;
    }

    /* Print */
    @media print{
      body{background:#fff;color:#111827;padding:0}
      header, .controls, .footer {position:static; box-shadow:none; backdrop-filter:none}
      .glass{background:#fff; border:1px solid #e5e7eb; box-shadow:none}
      thead th{background:#f3f4f6;color:#374151}
      code{background:#f3f4f6;border-color:#e5e7eb;color:#111827}
      .vuln-id{color:#1d4ed8}
      .btn,.search,.hint{display:none !important}
    }
  </style>
</head>

<body>
  <div class="container">

    <header class="glass">
      <div class="brand">
        <div class="icon"><i class="fa-solid fa-shield-halved"></i></div>
        <div style="min-width:0">
          <h1>Rapport de Sécurité – Trivy (Image Docker)</h1>
          <div class="timestamp">Généré le : {{ now | date "02/01/2006 à 15:04" }}</div>
        </div>
      </div>
      <div class="logo">
        <img src="https://raw.githubusercontent.com/aquasecurity/trivy/main/docs/images/logo.png" alt="Trivy Logo">
      </div>
    </header>

    <div class="controls glass" role="region" aria-label="Contrôles">
      <div class="controls-left">
        <button class="btn active" data-sev="ALL"><i class="fa-solid fa-layer-group"></i> Tout</button>
        <button class="btn" data-sev="CRITICAL"><span class="dot critical"></span> Critical</button>
        <button class="btn" data-sev="HIGH"><span class="dot high"></span> High</button>
        <button class="btn" data-sev="MEDIUM"><span class="dot medium"></span> Medium</button>
        <button class="btn" data-sev="LOW"><span class="dot low"></span> Low</button>

        <div class="search">
          <i class="fa-solid fa-magnifying-glass"></i>
          <input id="searchInput" type="search" placeholder="Rechercher: CVE, package, version, fix…" autocomplete="off"/>
        </div>
      </div>

      <div class="controls-right">
        <div class="hint"><i class="fa-regular fa-keyboard"></i> <span><kbd>/</kbd> focus recherche · <kbd>Esc</kbd> reset</span></div>
        <button class="btn" id="btnExpand"><i class="fa-solid fa-up-right-and-down-left-from-center"></i> Tout déplier</button>
        <button class="btn" onclick="window.print()"><i class="fa-solid fa-print"></i> Imprimer</button>
      </div>
    </div>

    <section class="summary glass" aria-label="Résumé global">
      <div class="metric total">
        <div class="label"><i class="fa-solid fa-bug"></i> Total vulnérabilités</div>
        <div class="value" id="mTotal">0</div>
      </div>
      <div class="metric critical">
        <div class="label"><i class="fa-solid fa-triangle-exclamation"></i> Critical</div>
        <div class="value" id="mCritical">0</div>
      </div>
      <div class="metric high">
        <div class="label"><i class="fa-solid fa-fire"></i> High</div>
        <div class="value" id="mHigh">0</div>
      </div>
      <div class="metric medium">
        <div class="label"><i class="fa-solid fa-circle-minus"></i> Medium</div>
        <div class="value" id="mMedium">0</div>
      </div>
      <div class="metric low">
        <div class="label"><i class="fa-solid fa-leaf"></i> Low</div>
        <div class="value" id="mLow">0</div>
      </div>
      <div class="metric">
        <div class="label"><i class="fa-solid fa-box"></i> Cibles</div>
        <div class="value" id="mTargets">0</div>
      </div>
    </section>

    {{- range $ti, $t := . }}
    <section class="target-card glass" data-target>
      <div class="target-header">
        <div class="target-left">
          <i class="fa-solid fa-box-open"></i>
          <div style="min-width:0">
            <div class="target-title">{{ $t.Target }}</div>
            <div class="target-meta">{{ $t.Type }}</div>
          </div>
        </div>

        <div class="chips" aria-label="Statistiques cible">
          <span class="chip"><span class="dot critical"></span><b data-chip="CRITICAL">0</b><span>Critical</span></span>
          <span class="chip"><span class="dot high"></span><b data-chip="HIGH">0</b><span>High</span></span>
          <span class="chip"><span class="dot medium"></span><b data-chip="MEDIUM">0</b><span>Medium</span></span>
          <span class="chip"><span class="dot low"></span><b data-chip="LOW">0</b><span>Low</span></span>
          <span class="chip"><i class="fa-solid fa-bug"></i><b data-chip="TOTAL">0</b><span>Total</span></span>
        </div>
      </div>

      {{- if not $t.Vulnerabilities }}
      <div class="no-vuln">
        <i class="fa-solid fa-circle-check"></i>
        <span>OK — aucune vulnérabilité détectée.</span>
      </div>
      {{- else }}
      <div class="table-wrap">
        <table data-table>
          <thead>
            <tr>
              <th data-sort="Severity">Sévérité <span class="sort">↕</span></th>
              <th data-sort="VulnerabilityID">ID Vulnérabilité <span class="sort">↕</span></th>
              <th data-sort="PkgName">Paquet / Librairie <span class="sort">↕</span></th>
              <th data-sort="InstalledVersion">Installée <span class="sort">↕</span></th>
              <th data-sort="FixedVersion">Correctif <span class="sort">↕</span></th>
            </tr>
          </thead>
          <tbody>
            {{- range $vi, $v := $t.Vulnerabilities }}
            <tr class="clickable" data-row
                data-severity="{{ $v.Severity }}"
                data-search="{{ $v.VulnerabilityID }} {{ $v.PkgName }} {{ $v.InstalledVersion }} {{ $v.FixedVersion }}">
              <td>
                <span class="badge badge-{{ $v.Severity }}">
                  {{- if eq $v.Severity "CRITICAL" -}}<i class="fa-solid fa-triangle-exclamation"></i>{{- end -}}
                  {{- if eq $v.Severity "HIGH" -}}<i class="fa-solid fa-fire"></i>{{- end -}}
                  {{- if eq $v.Severity "MEDIUM" -}}<i class="fa-solid fa-circle-minus"></i>{{- end -}}
                  {{- if eq $v.Severity "LOW" -}}<i class="fa-solid fa-leaf"></i>{{- end -}}
                  {{ $v.Severity }}
                </span>
              </td>
              <td>
                {{- if $v.PrimaryURL -}}
                  <a class="vuln-id" href="{{ $v.PrimaryURL }}" target="_blank" rel="noreferrer">{{ $v.VulnerabilityID }}</a>
                {{- else -}}
                  <span class="vuln-id">{{ $v.VulnerabilityID }}</span>
                {{- end -}}
              </td>
              <td><strong>{{ $v.PkgName }}</strong></td>
              <td><code>{{ $v.InstalledVersion }}</code></td>
              <td>
                {{- if $v.FixedVersion -}}
                  <span class="fix-ok">{{ $v.FixedVersion }}</span>
                {{- else -}}
                  <span class="fix-na">Non disponible</span>
                {{- end -}}
              </td>
            </tr>
            {{- end }}
          </tbody>
        </table>
      </div>
      {{- end }}
    </section>
    {{- end }}

    <div class="footer glass">
      <span><i class="fa-solid fa-circle-info"></i> Astuce: clique une ligne pour ouvrir la CVE (si URL dispo) · tri en cliquant les en-têtes</span>
      <span class="muted">Template HTML (Trivy) — style dashboard</span>
    </div>
  </div>

  <script>
    (function(){
      const severityOrder = { CRITICAL: 4, HIGH: 3, MEDIUM: 2, LOW: 1, UNKNOWN: 0 };

      const btns = Array.from(document.querySelectorAll('.btn[data-sev]'));
      const searchInput = document.getElementById('searchInput');
      const btnExpand = document.getElementById('btnExpand');

      const allTargets = Array.from(document.querySelectorAll('[data-target]'));
      const allRows = Array.from(document.querySelectorAll('tr[data-row]'));

      let activeSev = 'ALL';
      let expanded = true;

      // Row click => open CVE link if present
      allRows.forEach(tr => {
        tr.addEventListener('click', (e) => {
          const link = tr.querySelector('a.vuln-id');
          if (link) window.open(link.href, '_blank', 'noopener,noreferrer');
        });
      });

      // Sorting tables
      document.querySelectorAll('table[data-table]').forEach(table => {
        const thead = table.querySelector('thead');
        const tbody = table.querySelector('tbody');
        const headers = Array.from(thead.querySelectorAll('th[data-sort]'));

        let sortKey = null;
        let sortDir = 1; // 1 asc, -1 desc

        headers.forEach(th => {
          th.addEventListener('click', () => {
            const key = th.getAttribute('data-sort');
            if (sortKey === key) sortDir *= -1;
            else { sortKey = key; sortDir = 1; }

            const rows = Array.from(tbody.querySelectorAll('tr[data-row]'));
            rows.sort((a,b) => {
              const av = getCellValue(a, key);
              const bv = getCellValue(b, key);

              if (key === 'Severity'){
                return (severityOrder[av] - severityOrder[bv]) * sortDir;
              }
              // string compare
              return String(av).localeCompare(String(bv), 'fr', {numeric:true, sensitivity:'base'}) * sortDir;
            });

            rows.forEach(r => tbody.appendChild(r));
            updateMetrics(); // metrics after sort/filter/search
          });
        });
      });

      function getCellValue(tr, key){
        // based on column order
        const tds = tr.querySelectorAll('td');
        switch(key){
          case 'Severity': return tr.getAttribute('data-severity') || '';
          case 'VulnerabilityID': return (tds[1]?.innerText || '').trim();
          case 'PkgName': return (tds[2]?.innerText || '').trim();
          case 'InstalledVersion': return (tds[3]?.innerText || '').trim();
          case 'FixedVersion': return (tds[4]?.innerText || '').trim();
          default: return '';
        }
      }

      // Filtering by severity
      btns.forEach(b => {
        b.addEventListener('click', () => {
          btns.forEach(x => x.classList.remove('active'));
          b.classList.add('active');
          activeSev = b.getAttribute('data-sev');
          applyFilters();
        });
      });

      // Search filter
      function normalize(s){ return (s||'').toLowerCase(); }
      function applyFilters(){
        const q = normalize(searchInput.value);

        allRows.forEach(tr => {
          const sev = tr.getAttribute('data-severity') || '';
          const hay = normalize(tr.getAttribute('data-search') || '');
          const matchSev = (activeSev === 'ALL') || (sev === activeSev);
          const matchQ = !q || hay.includes(q);
          tr.style.display = (matchSev && matchQ) ? '' : 'none';
        });

        // hide target cards with no visible rows (but keep "no vuln" cards)
        allTargets.forEach(card => {
          const rows = Array.from(card.querySelectorAll('tr[data-row]'));
          if (!rows.length) { card.style.display = ''; return; }
          const anyVisible = rows.some(r => r.style.display !== 'none');
          card.style.display = anyVisible ? '' : 'none';
        });

        updateMetrics();
      }

      searchInput.addEventListener('input', applyFilters);

      // Keyboard shortcuts
      document.addEventListener('keydown', (e) => {
        if (e.key === '/' && document.activeElement !== searchInput) {
          e.preventDefault();
          searchInput.focus();
        }
        if (e.key === 'Escape') {
          searchInput.value = '';
          activeSev = 'ALL';
          btns.forEach(x => x.classList.remove('active'));
          const allBtn = btns.find(x => x.getAttribute('data-sev') === 'ALL');
          if (allBtn) allBtn.classList.add('active');
          applyFilters();
        }
      });

      // Expand / collapse all cards (table visibility)
      btnExpand?.addEventListener('click', () => {
        expanded = !expanded;
        document.querySelectorAll('.table-wrap').forEach(w => w.style.display = expanded ? '' : 'none');
        btnExpand.classList.toggle('active', !expanded);
        btnExpand.innerHTML = expanded
          ? '<i class="fa-solid fa-up-right-and-down-left-from-center"></i> Tout déplier'
          : '<i class="fa-solid fa-down-left-and-up-right-to-center"></i> Tout replier';
      });

      // Metrics
      function setText(id, v){ const el=document.getElementById(id); if(el) el.textContent = String(v); }

      function updateMetrics(){
        let total=0, c=0, h=0, m=0, l=0;
        const visibleRows = allRows.filter(r => r.style.display !== 'none');
        visibleRows.forEach(r => {
          total++;
          const sev = r.getAttribute('data-severity');
          if (sev === 'CRITICAL') c++;
          else if (sev === 'HIGH') h++;
          else if (sev === 'MEDIUM') m++;
          else if (sev === 'LOW') l++;
        });

        setText('mTotal', total);
        setText('mCritical', c);
        setText('mHigh', h);
        setText('mMedium', m);
        setText('mLow', l);

        const visibleTargets = allTargets.filter(t => t.style.display !== 'none').length;
        setText('mTargets', visibleTargets);

        // Per-target chips
        allTargets.forEach(card => {
          const rows = Array.from(card.querySelectorAll('tr[data-row]')).filter(r => r.style.display !== 'none');
          const counts = {CRITICAL:0,HIGH:0,MEDIUM:0,LOW:0,TOTAL:0};
          rows.forEach(r => {
            counts.TOTAL++;
            const s = r.getAttribute('data-severity');
            if (counts[s] !== undefined) counts[s]++;
          });
          card.querySelectorAll('[data-chip]').forEach(b => {
            const k = b.getAttribute('data-chip');
            b.textContent = counts[k] ?? 0;
          });
        });
      }

      // Init
      applyFilters();
    })();
  </script>
</body>
</html>
