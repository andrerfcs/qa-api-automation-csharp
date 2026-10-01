let dashboardData;
let lastFocusedElement;

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
    const meta = document.createElement("div");
    meta.className = "feature-meta";
    [feature.file, statusLabel(feature.status)].forEach((value) => {
      const item = document.createElement("span");
      item.textContent = value;
      meta.appendChild(item);
    });
    const title = document.createElement("h3");
    title.textContent = feature.name;
    const counts = document.createElement("div");
    counts.className = "feature-counts";
    const metrics = [
      [feature.total ?? feature.scenarios.length, "Cenários"],
      [feature.executed ?? "-", "Execuções"],
      [feature.passed ?? "-", "Aprovados"],
      [feature.failed ?? "-", "Falhas"],
      [feature.skipped ?? "-", "Ignorados"],
      [successRate === "-" ? "-" : `${successRate}%`, "Sucesso", "success-count"]
    ];
    metrics.forEach(([value, label, className]) => {
      const item = document.createElement("div");
      if (className) item.className = className;
      const metricValue = document.createElement("strong");
      metricValue.textContent = value;
      const metricLabel = document.createElement("span");
      metricLabel.textContent = label;
      item.append(metricValue, metricLabel);
      counts.appendChild(item);
    });
    card.append(meta, title, counts);
    container.appendChild(card);
  });
};

const renderInventoryCoverage = () => {
  const features = dashboardData.automation.features;
  const catalogued = features.reduce((total, feature) => total + feature.scenarios.length, 0);
  const declared = features.reduce((total, feature) => total + (feature.total ?? feature.scenarios.length), 0);
  const percentage = declared ? Math.min(100, Math.round((catalogued / declared) * 100)) : 0;
  const progress = document.getElementById("coverage-progress");

  setText("coverage-value", `${catalogued} de ${declared} · ${percentage}%`);
  setText("coverage-note", `${features.length} Features catalogadas; execuções são contabilizadas separadamente.`);
  progress.setAttribute("aria-valuenow", percentage);
  progress.setAttribute("aria-valuetext", `${catalogued} de ${declared} cenários catalogados, ${percentage}%`);
  document.getElementById("coverage-fill").style.width = `${percentage}%`;
};

const renderScenarios = () => {
  const feature = document.getElementById("feature-filter").value;
  const search = document.getElementById("scenario-search").value.trim().toLowerCase();
  const filtered = allScenarios().filter((scenario) => (!feature || scenario.feature === feature) && (!search || scenario.name.toLowerCase().includes(search)));
  const tbody = document.getElementById("scenarios");
  tbody.replaceChildren();
  setText("scenario-count", `${filtered.length} de ${allScenarios().length} cenário(s)`);
  if (!filtered.length) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    cell.className = "empty";
    cell.colSpan = 5;
    cell.textContent = "Nenhum cenário corresponde aos filtros.";
    row.appendChild(cell);
    tbody.appendChild(row);
    return;
  }
  filtered.forEach((scenario, index) => {
    const row = document.createElement("tr");
    const methodCell = document.createElement("td");
    const method = document.createElement("span");
    method.className = "method";
    method.textContent = scenario.method || "-";
    methodCell.appendChild(method);
    const nameCell = document.createElement("td");
    nameCell.title = scenario.name;
    nameCell.textContent = scenario.name;
    const routeCell = document.createElement("td");
    routeCell.title = scenario.route || "-";
    const route = document.createElement("span");
    route.className = "route";
    route.textContent = scenario.route || "-";
    routeCell.appendChild(route);
    const featureCell = document.createElement("td");
    featureCell.textContent = scenario.feature;
    const detailsCell = document.createElement("td");
    const detailsButton = document.createElement("button");
    detailsButton.className = "details-button";
    detailsButton.type = "button";
    detailsButton.dataset.scenarioIndex = index;
    detailsButton.setAttribute("aria-label", `Ver detalhes de ${scenario.name}`);
    detailsButton.title = "Ver detalhes";
    detailsButton.textContent = "\u{1F441}";
    detailsButton.addEventListener("click", () => openModal(scenario));
    detailsCell.appendChild(detailsButton);
    row.append(methodCell, nameCell, routeCell, featureCell, detailsCell);
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
    const header = document.getElementById("modal-example-head");
    const headerRow = document.createElement("tr");
    examples.headers.forEach((headerText) => {
      const headerCell = document.createElement("th");
      headerCell.scope = "col";
      headerCell.textContent = headerText;
      headerRow.appendChild(headerCell);
    });
    header.replaceChildren(headerRow);
    const body = document.getElementById("modal-example-body");
    body.replaceChildren();
    examples.rows.forEach((example) => {
      const row = document.createElement("tr");
      examples.headers.forEach((headerText) => {
        const cell = document.createElement("td");
        cell.textContent = example[headerText] ?? "";
        row.appendChild(cell);
      });
      body.appendChild(row);
    });
  }
  lastFocusedElement = document.activeElement;
  document.getElementById("scenario-modal").hidden = false;
  document.getElementById("modal-close").focus();
};

const closeModal = () => {
  const modal = document.getElementById("scenario-modal");
  if (modal.hidden) return;
  modal.hidden = true;
  if (lastFocusedElement instanceof HTMLElement) lastFocusedElement.focus();
};

const populateFilters = () => {
  const select = document.getElementById("feature-filter");
  dashboardData.automation.features.forEach((feature) => { const option = document.createElement("option"); option.value = feature.name; option.textContent = feature.name; select.appendChild(option); });
};

const render = (data) => {
  dashboardData = data;
  setText("total", data.summary.total); setText("passed", data.summary.passed); setText("failed", data.summary.failed); setText("skipped", data.summary.skipped); setText("success-rate", `${data.summary.successRate}%`);
  setText("last-run", formatDate(data.execution.lastRun)); setText("execution-status", `Status da última execução: ${statusLabel(data.execution.status)}`);
  populateFilters(); renderFeatures(); renderInventoryCoverage(); renderScenarios();
};

document.getElementById("feature-filter").addEventListener("change", renderScenarios);
document.getElementById("scenario-search").addEventListener("input", renderScenarios);
document.getElementById("clear-filters").addEventListener("click", () => { document.getElementById("feature-filter").value = ""; document.getElementById("scenario-search").value = ""; renderScenarios(); });
document.getElementById("modal-close").addEventListener("click", closeModal);
document.getElementById("scenario-modal").addEventListener("click", (event) => { if (event.target.id === "scenario-modal") closeModal(); });
document.addEventListener("keydown", (event) => { if (event.key === "Escape") closeModal(); });

fetch("data/results.json", { cache: "no-store" }).then((response) => { if (!response.ok) throw new Error(`HTTP ${response.status}`); return response.json(); }).then(render).catch((error) => {
  setText("last-run", "Não foi possível carregar os resultados");
  const errorMessage = document.createElement("div");
  errorMessage.className = "panel error";
  errorMessage.textContent = error.message;
  document.getElementById("features").replaceChildren(errorMessage);
});
