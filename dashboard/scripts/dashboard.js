let dashboardData;

const formatDate = (value) => value ? new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "medium" }).format(new Date(value)) : "-";
const setText = (id, value) => { document.getElementById(id).textContent = value; };
const allScenarios = () => dashboardData.automation.features.flatMap((feature) => feature.scenarios.map((scenario) => ({ ...scenario, feature: feature.name })));

const statusLabel = (status) => ({ Passed: "Aprovado", Failed: "Falhou", Skipped: "Ignorado", Inventory: "Inventário" }[status] || status || "Inventário");
const statusClass = (status) => `status status-${(status || "inventory").toLowerCase()}`;

const renderFeatures = () => {
  const container = document.getElementById("features");
  container.replaceChildren();
  dashboardData.automation.features.forEach((feature) => {
    const card = document.createElement("article");
    card.className = "panel feature-card";
    const successRate = feature.executed ? Math.round((feature.passed / feature.executed) * 100) : "-";
    card.innerHTML = `<div class="feature-meta"><span>${feature.file}</span><span>${statusLabel(feature.status)}</span></div><h3>${feature.name}</h3><div class="feature-counts"><div><strong>${feature.total ?? feature.scenarios.length}</strong><span>Cenários</span></div><div><strong>${feature.executed ?? "-"}</strong><span>Execuções</span></div><div><strong>${feature.passed ?? "-"}</strong><span>Aprovados</span></div><div><strong>${feature.failed ?? "-"}</strong><span>Falhas</span></div><div><strong>${feature.skipped ?? "-"}</strong><span>Ignorados</span></div><div><strong>${successRate}%</strong><span>Sucesso</span></div></div>`;
    container.appendChild(card);
  });
};

const renderScenarios = () => {
  const feature = document.getElementById("feature-filter").value;
  const status = document.getElementById("status-filter").value;
  const search = document.getElementById("scenario-search").value.trim().toLowerCase();
  const filtered = allScenarios().filter((scenario) => (!feature || scenario.feature === feature) && (!status || (scenario.status || "Inventory") === status) && (!search || scenario.name.toLowerCase().includes(search)));
  const tbody = document.getElementById("scenarios");
  tbody.replaceChildren();
  setText("scenario-count", `${filtered.length} de ${allScenarios().length} cenário(s)`);
  if (!filtered.length) { const row = document.createElement("tr"); row.innerHTML = '<td class="empty" colspan="3">Nenhum cenário corresponde aos filtros.</td>'; tbody.appendChild(row); return; }
  filtered.forEach((scenario) => {
    const row = document.createElement("tr");
    row.innerHTML = `<td>${scenario.name}</td><td>${scenario.feature}</td><td><span class="${statusClass(scenario.status)}">${statusLabel(scenario.status)}</span></td>`;
    tbody.appendChild(row);
  });
};

const populateFilters = () => {
  const select = document.getElementById("feature-filter");
  dashboardData.automation.features.forEach((feature) => { const option = document.createElement("option"); option.value = feature.name; option.textContent = feature.name; select.appendChild(option); });
};

const render = (data) => {
  dashboardData = data;
  setText("total", data.summary.total); setText("passed", data.summary.passed); setText("failed", data.summary.failed); setText("skipped", data.summary.skipped); setText("success-rate", `${data.summary.successRate}%`);
  setText("last-run", formatDate(data.execution.lastRun)); setText("execution-status", `Status da última execução: ${statusLabel(data.execution.status)}`);
  populateFilters(); renderFeatures(); renderScenarios();
};

document.getElementById("feature-filter").addEventListener("change", renderScenarios);
document.getElementById("status-filter").addEventListener("change", renderScenarios);
document.getElementById("scenario-search").addEventListener("input", renderScenarios);
document.getElementById("clear-filters").addEventListener("click", () => { document.getElementById("feature-filter").value = ""; document.getElementById("status-filter").value = ""; document.getElementById("scenario-search").value = ""; renderScenarios(); });

fetch("data/results.json", { cache: "no-store" }).then((response) => { if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); }).then(render).catch((error) => { setText("last-run", "Não foi possível carregar os resultados"); document.getElementById("features").innerHTML = `<div class="panel error">${error.message}</div>`; });
