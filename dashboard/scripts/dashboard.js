let dashboardData;

const formatDate = (value) => value ? new Intl.DateTimeFormat("pt-BR", { dateStyle: "short", timeStyle: "medium" }).format(new Date(value)) : "-";
const setText = (id, value) => { document.getElementById(id).textContent = value; };
const allScenarios = () => dashboardData.automation.features.flatMap((feature) => feature.scenarios.map((scenario) => ({ ...scenario, feature: feature.name })));

const statusLabel = (status) => ({ Passed: "Aprovado", Failed: "Falhou", Skipped: "Ignorado" }[status] || status || "-");

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
  const search = document.getElementById("scenario-search").value.trim().toLowerCase();
  const filtered = allScenarios().filter((scenario) => (!feature || scenario.feature === feature) && (!search || scenario.name.toLowerCase().includes(search)));
  const tbody = document.getElementById("scenarios");
  tbody.replaceChildren();
  setText("scenario-count", `${filtered.length} de ${allScenarios().length} cenário(s)`);
  if (!filtered.length) { const row = document.createElement("tr"); row.innerHTML = '<td class="empty" colspan="5">Nenhum cenário corresponde aos filtros.</td>'; tbody.appendChild(row); return; }
  filtered.forEach((scenario, index) => {
    const row = document.createElement("tr");
    row.innerHTML = `<td><span class="method">${scenario.method || "-"}</span></td><td title="${scenario.name}">${scenario.name}</td><td title="${scenario.route || "-"}"><span class="route">${scenario.route || "-"}</span></td><td>${scenario.feature}</td><td><button class="details-button" type="button" data-scenario-index="${index}" aria-label="Ver detalhes de ${scenario.name}" title="Ver detalhes">&#128065;</button></td>`;
    row.querySelector(".details-button").addEventListener("click", () => openModal(scenario));
    tbody.appendChild(row);
  });
};

const openModal = (scenario) => {
  setText("modal-title", scenario.name); setText("modal-feature", scenario.feature); setText("modal-method", scenario.method || "-"); setText("modal-route", scenario.route || "-");
  const steps = document.getElementById("modal-steps"); steps.replaceChildren();
  (scenario.steps || []).forEach((step) => { const item = document.createElement("li"); const keyword = document.createElement("strong"); keyword.className = "step-keyword"; keyword.textContent = step.keyword; item.append(keyword, document.createTextNode(step.text)); steps.appendChild(item); });
  const examplesContainer = document.getElementById("modal-examples-container");
  const examples = scenario.examples;
  examplesContainer.hidden = !examples;
  if (examples) {
    document.getElementById("modal-example-head").innerHTML = `<tr>${examples.headers.map((header) => `<th>${header}</th>`).join("")}</tr>`;
    document.getElementById("modal-example-body").innerHTML = examples.rows.map((row) => `<tr>${examples.headers.map((header) => `<td>${row[header] ?? ""}</td>`).join("")}</tr>`).join("");
  }
  document.getElementById("scenario-modal").hidden = false;
};

const closeModal = () => { document.getElementById("scenario-modal").hidden = true; };

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
document.getElementById("scenario-search").addEventListener("input", renderScenarios);
document.getElementById("clear-filters").addEventListener("click", () => { document.getElementById("feature-filter").value = ""; document.getElementById("scenario-search").value = ""; renderScenarios(); });
document.getElementById("modal-close").addEventListener("click", closeModal);
document.getElementById("scenario-modal").addEventListener("click", (event) => { if (event.target.id === "scenario-modal") closeModal(); });
document.addEventListener("keydown", (event) => { if (event.key === "Escape") closeModal(); });

fetch("data/results.json", { cache: "no-store" }).then((response) => { if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); }).then(render).catch((error) => { setText("last-run", "Não foi possível carregar os resultados"); document.getElementById("features").innerHTML = `<div class="panel error">${error.message}</div>`; });
