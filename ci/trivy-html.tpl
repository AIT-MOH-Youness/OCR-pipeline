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
        <span class="tag"><b id="mTargets">0</b>&nbsp;Cibles</span>
        <span class="tag"><b id="mTotal">0</b>&nbsp;Vulnérabilités</span>
        <button class="btn hidePrint" onclick="window.print()">Imprimer</button>
      </div>
    </header>

    <div class="controls card hidePrint">
      <div class="left">
        <button class="btn active" data-sev="ALL">Tout</button>
        <button class="btn" data-sev="CRITICAL"><span class="dot critical"></span>Critical</button>
        <button class="btn" data-sev="HIGH"><span class="dot high"></span>High</button>
        <button class="btn" data-sev="MEDIUM"><span class="dot medium"></span>Medium</button>
        <button class="btn" data-sev="LOW"><span class="dot low"></span>Low</button>

        <div class="search">
          <svg viewBox="0 0 24 24" fill="none">
            <path d="M21 21l-4.3-4.3" stroke-width="2" stroke-linecap="round"/>
            <path d="M10.8 18.2a7.4 7.4 0 1 1 0-14.8a7.4 7.4 0 0 1 0 14.8z" stroke-width="2"/>
          </svg>
          <input id="q" type="search" placeholder="Rechercher: CVE, package, version, fix…" autocomplete="off">
        </div>
      </div>

      <div class="right">
        <button class="btn" id="expandAll">Tout replier</button>
      </div>
    </div>

    <section class="summary card">
      <div class="metric total">
        <div class="label">Total vulnérabilités</div>
        <div class="value" id="mTotal2">0</div>
      </div>
      <div class="metric critical">
        <div class="label">Critical</div>
        <div class="value" id="mCritical">0</div>
      </div>
      <div class="metric high">
        <div class="label">High</div>
        <div class="value" id="mHigh">0</div>
      </div>
      <div class="metric medium">
        <div class="label">Medium</div>
        <div class="value" id="mMedium">0</div>
      </div>
      <div class="metric low">
        <div class="label">Low</div>
        <div class="value" id="mLow">0</div>
      </div>
      <div class="metric">
        <div class="label">Filtre / Recherche</div>
        <div class="value" id="mVisible">0</div>
      </div>
    </section>

    {{- range $ti, $t := . }}
    <section class="target card" data-target>
      <div class="targetHead">
        <div class="targetLeft">
          <div style="width:10px;height:10px;border-radius:999px;background:rgba(37,99,235,.25)"></div>
          <div style="min-width:0">
            <div class="targetTitle">{{ $t.Target }}</div>
            <div class="targetMeta">{{ $t.Type }}</div>
          </div>
        </div>

        <div class="targetActions">
          <span class="chip"><span class="dot critical"></span><b data-chip="CRITICAL">0</b> Critical</span>
          <span class="chip"><span class="dot high"></span><b data-chip="HIGH">0</b> High</span>
          <span class="chip"><span class="dot medium"></span><b data-chip="MEDIUM">0</b> Medium</span>
          <span class="chip"><span class="dot low"></span><b data-chip="LOW">0</b> Low</span>
          <span class="chip"><b data-chip="TOTAL">0</b> Total</span>
          <button class="toggle hidePrint" data-toggle>Replier</button>
        </div>
      </div>

      {{- if not $t.Vulnerabilities }}
      <div class="noVuln">
        <div class="ok">✓</div>
        <div>OK — aucune vulnérabilité détectée.</div>
      </div>
      {{- else }}
      <div class="tableWrap" data-wrap>
        <table data-table>
          <thead>
            <tr>
              <th data-sort="Severity">Sévérité <span class="sort">↕</span></th>
              <th data-sort="VulnerabilityID">ID <span class="sort">↕</span></th>
              <th data-sort="PkgName">Paquet <span class="sort">↕</span></th>
              <th data-sort="InstalledVersion">Installée <span class="sort">↕</span></th>
              <th data-sort="FixedVersion">Correctif <span class="sort">↕</span></th>
            </tr>
          </thead>
          <tbody>
            {{- range $vi, $v := $t.Vulnerabilities }}
            <tr class="click" data-row
                data-severity="{{ $v.Severity }}"
                data-search="{{ $v.VulnerabilityID }} {{ $v.PkgName }} {{ $v.InstalledVersion }} {{ $v.FixedVersion }}">
              <td><span class="badge badge-{{ $v.Severity }}">{{ $v.Severity }}</span></td>
              <td>
                {{- if $v.PrimaryURL -}}
                  <a class="cve" href="{{ $v.PrimaryURL }}" target="_blank" rel="noreferrer">{{ $v.VulnerabilityID }}</a>
                {{- else -}}
                  <span class="cve">{{ $v.VulnerabilityID }}</span>
                {{- end -}}
              </td>
              <td><strong>{{ $v.PkgName }}</strong></td>
              <td><code>{{ $v.InstalledVersion }}</code></td>
              <td>
                {{- if $v.FixedVersion -}}
                  <span style="color:var(--low);font-weight:800">{{ $v.FixedVersion }}</span>
                {{- else -}}
                  <span style="color:var(--muted);font-style:italic">Non disponible</span>
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

    <div class="footer card">
      <span>Tri: clique sur les en-têtes · Filtre: boutons sévérité · Recherche instantanée</span>
      <span class="hidePrint">Astuce: <b>/</b> focus recherche · <b>Esc</b> reset</span>
    </div>
  </div>

  <script>
    (function(){
      const severityOrder = { CRITICAL:4, HIGH:3, MEDIUM:2, LOW:1, UNKNOWN:0 };
      const btns = [...document.querySelectorAll('.btn[data-sev]')];
      const q = document.getElementById('q');
      const rows = [...document.querySelectorAll('tr[data-row]')];
      const targets = [...document.querySelectorAll('[data-target]')];
      const expandAll = document.getElementById('expandAll');

      let active = 'ALL';
      let allExpanded = true;

      function setText(id, v){ const el=document.getElementById(id); if(el) el.textContent = String(v); }

      // Open CVE on row click (if link exists)
      rows.forEach(r=>{
        r.addEventListener('click', ()=>{
          const a = r.querySelector('a.cve');
          if(a) window.open(a.href, '_blank', 'noopener,noreferrer');
        });
      });

      // Sort tables
      document.querySelectorAll('table[data-table]').forEach(table=>{
        const tbody = table.querySelector('tbody');
        const ths = [...table.querySelectorAll('th[data-sort]')];
        let key=null, dir=1;

        function getVal(tr, k){
          const tds = tr.querySelectorAll('td');
          if(k==='Severity') return tr.getAttribute('data-severity') || '';
          if(k==='VulnerabilityID') return (tds[1]?.innerText||'').trim();
          if(k==='PkgName') return (tds[2]?.innerText||'').trim();
          if(k==='InstalledVersion') return (tds[3]?.innerText||'').trim();
          if(k==='FixedVersion') return (tds[4]?.innerText||'').trim();
          return '';
        }

        ths.forEach(th=>{
          th.addEventListener('click', ()=>{
            const k = th.getAttribute('data-sort');
            if(key===k) dir*=-1; else { key=k; dir=1; }

            const rs = [...tbody.querySelectorAll('tr[data-row]')];
            rs.sort((a,b)=>{
              const av = getVal(a,k), bv = getVal(b,k);
              if(k==='Severity') return (severityOrder[av]-severityOrder[bv]) * dir;
              return String(av).localeCompare(String(bv), 'fr', {numeric:true, sensitivity:'base'}) * dir;
            });
            rs.forEach(r=>tbody.appendChild(r));
            updateMetrics();
          });
        });
      });

      // Target collapse buttons
      document.querySelectorAll('[data-toggle]').forEach(btn=>{
        btn.addEventListener('click', ()=>{
          const card = btn.closest('[data-target]');
          const wrap = card.querySelector('[data-wrap]');
          if(!wrap) return;
          const hidden = wrap.style.display === 'none';
          wrap.style.display = hidden ? '' : 'none';
          btn.textContent = hidden ? 'Replier' : 'Déplier';
        });
      });

      // Expand all
      if(expandAll){
        expandAll.addEventListener('click', ()=>{
          allExpanded = !allExpanded;
          document.querySelectorAll('[data-wrap]').forEach(w=> w.style.display = allExpanded ? '' : 'none');
          document.querySelectorAll('[data-toggle]').forEach(b=> b.textContent = allExpanded ? 'Replier' : 'Déplier');
          expandAll.textContent = allExpanded ? 'Tout replier' : 'Tout déplier';
        });
      }

      // Filtering & search
      function apply(){
        const term = (q.value||'').toLowerCase().trim();

        rows.forEach(r=>{
          const sev = r.getAttribute('data-severity') || '';
          const hay = (r.getAttribute('data-search')||'').toLowerCase();
          const okSev = (active==='ALL') || (sev===active);
          const okQ = !term || hay.includes(term);
          r.style.display = (okSev && okQ) ? '' : 'none';
        });

        // Hide targets with no visible rows (but keep no-vuln cards)
        targets.forEach(t=>{
          const tRows = [...t.querySelectorAll('tr[data-row]')];
          if(!tRows.length){ t.style.display=''; return; }
          t.style.display = tRows.some(r=>r.style.display!=='none') ? '' : 'none';
        });

        updateMetrics();
      }

      btns.forEach(b=>{
        b.addEventListener('click', ()=>{
          btns.forEach(x=>x.classList.remove('active'));
          b.classList.add('active');
          active = b.getAttribute('data-sev');
          apply();
        });
      });

      q.addEventListener('input', apply);

      // Keyboard shortcuts
      document.addEventListener('keydown', (e)=>{
        if(e.key==='/' && document.activeElement!==q){
          e.preventDefault(); q.focus();
        }
        if(e.key==='Escape'){
          q.value='';
          active='ALL';
          btns.forEach(x=>x.classList.remove('active'));
          (btns.find(x=>x.getAttribute('data-sev')==='ALL')||btns[0])?.classList.add('active');
          apply();
        }
      });

      // Metrics (global + per-target chips)
      function updateMetrics(){
        let total=0,c=0,h=0,m=0,l=0,visible=0;

        const visibleRows = rows.filter(r=>r.style.display!=='none');
        visible = visibleRows.length;

        // total across all (unfiltered) for header
        rows.forEach(r=>{
          total++;
          const s=r.getAttribute('data-severity');
          if(s==='CRITICAL') c++;
          else if(s==='HIGH') h++;
          else if(s==='MEDIUM') m++;
          else if(s==='LOW') l++;
        });

        setText('mTotal', total);
        setText('mTotal2', total);
        setText('mCritical', c);
        setText('mHigh', h);
        setText('mMedium', m);
        setText('mLow', l);

        const visibleTargets = targets.filter(t=>t.style.display!=='none').length;
        setText('mTargets', visibleTargets);
        setText('mVisible', visible);

        // per-target chips (based on visible rows, so chips follow filters/search)
        targets.forEach(t=>{
          const tRows = [...t.querySelectorAll('tr[data-row]')].filter(r=>r.style.display!=='none');
          const counts={CRITICAL:0,HIGH:0,MEDIUM:0,LOW:0,TOTAL:0};
          tRows.forEach(r=>{
            counts.TOTAL++;
            const s=r.getAttribute('data-severity');
            if(counts[s]!=null) counts[s]++;
          });
          t.querySelectorAll('[data-chip]').forEach(el=>{
            const k=el.getAttribute('data-chip');
            el.textContent = counts[k] ?? 0;
          });
        });
      }

      // init
      apply();
    })();
  </script>
</body>
</html>
