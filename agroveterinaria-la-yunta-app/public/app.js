const sections = document.querySelectorAll('.panel');
const navButtons = document.querySelectorAll('.nav-button');
const loadButtons = document.querySelectorAll('.load-button');
const reportButtons = document.querySelectorAll('.report-button');
const dataForms = document.querySelectorAll('.data-form');
const toast = document.getElementById('toast');
const serverStatus = document.getElementById('serverStatus');
const selectClienteMascota = document.getElementById('selectClienteMascota');
const selectMascotaCita = document.getElementById('selectMascotaCita');

const counters = {
  clientes: document.getElementById('countClientes'),
  mascotas: document.getElementById('countMascotas'),
  productos: document.getElementById('countProductos'),
  citas: document.getElementById('countCitas')
};

function showToast(message, type = 'info') {
  toast.textContent = message;
  toast.classList.remove('info', 'success', 'error');
  toast.classList.add(type);
  toast.classList.add('visible');

  setTimeout(() => {
    toast.classList.remove('visible');
    toast.classList.remove('info', 'success', 'error');
  }, 3200);
}

function formatDate(value) {
  if (typeof value === 'string') {
    const dateOnly = value.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (dateOnly) {
      const [, year, month, day] = dateOnly;
      return new Date(Number(year), Number(month) - 1, Number(day)).toLocaleDateString('es-CR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    }
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;

  return date.toLocaleDateString('es-CR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  });
}

function formatTime(value) {
  if (value instanceof Date) {
    return value.toLocaleTimeString('es-CR', {
      hour: '2-digit',
      minute: '2-digit'
    });
  }

  if (typeof value === 'string') {
    const timeOnly = value.match(/^(\d{2}):(\d{2})(?::\d{2}(?:\.\d+)?)?$/);
    if (timeOnly) return `${timeOnly[1]}:${timeOnly[2]}`;

    const timeFromDate = value.match(/T(\d{2}):(\d{2})/);
    if (timeFromDate) return `${timeFromDate[1]}:${timeFromDate[2]}`;

    const date = new Date(value);
    if (!Number.isNaN(date.getTime())) {
      return date.toLocaleTimeString('es-CR', {
        hour: '2-digit',
        minute: '2-digit'
      });
    }
  }

  return value;
}

function formatValue(fieldName, value) {
  if (value === null || value === undefined) return '';

  const normalizedField = fieldName.toLowerCase();

  if (normalizedField === 'hora') {
    return formatTime(value);
  }

  if (normalizedField.includes('fecha')) {
    return formatDate(value);
  }

  return value;
}

function renderTable(panel, data) {
  const tableHead = panel.querySelector('thead');
  const tableBody = panel.querySelector('tbody');
  tableHead.innerHTML = '';
  tableBody.innerHTML = '';

  if (!Array.isArray(data) || data.length === 0) {
    tableBody.innerHTML = '<tr><td class="empty-state">No hay registros para mostrar.</td></tr>';
    return;
  }

  const columns = Object.keys(data[0]);
  const headerRow = document.createElement('tr');

  columns.forEach((column) => {
    const th = document.createElement('th');
    th.textContent = column;
    headerRow.appendChild(th);
  });

  tableHead.appendChild(headerRow);

  data.forEach((row) => {
    const tr = document.createElement('tr');

    columns.forEach((column) => {
      const td = document.createElement('td');
      td.textContent = formatValue(column, row[column]);
      tr.appendChild(td);
    });

    tableBody.appendChild(tr);
  });
}

async function fetchData(endpoint) {
  const response = await fetch(endpoint);
  const payload = await response.json();

  if (!response.ok) {
    throw new Error(payload.details || payload.error || 'No se pudo cargar la informacion');
  }

  if (payload && Object.prototype.hasOwnProperty.call(payload, 'success')) {
    if (payload.success === false) {
      throw new Error(payload.details || payload.error || 'La operacion no se pudo completar');
    }

    return payload.data ?? payload;
  }

  return payload;
}

async function postData(endpoint, body) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
  });

  const payload = await response.json();

  if (!response.ok || payload.success === false) {
    throw new Error(payload.details || payload.error || 'La operacion no se pudo completar');
  }

  return payload;
}

async function loadPanelData(panel, showMessages = true) {
  const endpoint = panel.dataset.endpoint;

  if (!endpoint) return;

  try {
    if (showMessages) showToast('Cargando informacion...');
    const data = await fetchData(endpoint);
    renderTable(panel, data);
    if (showMessages) showToast(`Datos cargados: ${data.length} registros`, 'success');
  } catch (error) {
    showToast(error.message, 'error');
  }
}

function showSection(sectionId) {
  sections.forEach((section) => {
    section.classList.toggle('visible', section.id === sectionId);
  });

  navButtons.forEach((button) => {
    button.classList.toggle('active', button.dataset.section === sectionId);
  });
}

async function loadReport(endpoint, showMessages = true) {
  const panel = document.getElementById('reportes');

  try {
    if (showMessages) showToast('Cargando reporte...');
    const data = await fetchData(endpoint);
    renderTable(panel, data);
    if (showMessages) showToast(`Reporte cargado: ${data.length} registros`, 'success');
  } catch (error) {
    showToast(error.message, 'error');
  }
}

async function loadSectionData(sectionId) {
  if (sectionId === 'ventas' || sectionId === 'transacciones') {
    await loadReferenceSelects();
  }

  if (sectionId === 'reportes') {
    await loadReport('/api/reportes/ventas-detalle', false);
    return;
  }

  const panel = document.getElementById(sectionId);
  if (panel && panel.dataset.endpoint) {
    await loadPanelData(panel, false);
  }
}

async function checkServer() {
  try {
    const health = await fetchData('/api/health');
    const database = health.base_datos || health.base_actual || 'BD conectada';
    const server = health.servidor || health.servidor_sql || 'SQL Server';
    serverStatus.textContent = `${database} - ${server}`;
  } catch (error) {
    serverStatus.textContent = 'Servidor sin conexion';
    showToast(error.message, 'error');
  }
}

async function updateSummary(showMessages = true) {
  const endpoints = {
    clientes: '/api/clientes',
    mascotas: '/api/mascotas',
    productos: '/api/productos',
    citas: '/api/citas'
  };

  try {
    const entries = await Promise.all(
      Object.entries(endpoints).map(async ([key, endpoint]) => {
        const data = await fetchData(endpoint);
        return [key, data.length];
      })
    );

    entries.forEach(([key, count]) => {
      counters[key].textContent = count;
    });

    if (showMessages) showToast('Resumen actualizado', 'success');
  } catch (error) {
    showToast(error.message, 'error');
  }
}

function getFormData(form) {
  const formData = new FormData(form);
  const values = {};

  formData.forEach((value, key) => {
    values[key] = value;
  });

  return values;
}

function fillSelect(select, rows, getValue, getLabel, placeholder) {
  if (!select) return;

  const currentValue = select.value;
  select.innerHTML = '';

  const emptyOption = document.createElement('option');
  emptyOption.value = '';
  emptyOption.textContent = placeholder;
  select.appendChild(emptyOption);

  rows.forEach((row) => {
    const option = document.createElement('option');
    option.value = getValue(row);
    option.textContent = getLabel(row);
    select.appendChild(option);
  });

  if (currentValue) {
    select.value = currentValue;
  }
}

function fillSelectGroup(selector, rows, getValue, getLabel, placeholder) {
  document.querySelectorAll(selector).forEach((select) => {
    fillSelect(select, rows, getValue, getLabel, placeholder);
  });
}

async function loadReferenceSelects() {
  try {
    const [clientes, mascotas, productos, usuarios, ventas] = await Promise.all([
      fetchData('/api/clientes'),
      fetchData('/api/mascotas'),
      fetchData('/api/productos'),
      fetchData('/api/usuarios'),
      fetchData('/api/ventas')
    ]);

    fillSelectGroup(
      '.select-clientes',
      clientes,
      (cliente) => cliente.id_cliente,
      (cliente) => `${cliente.id_cliente} - ${cliente.nombre} ${cliente.apellido1 || ''}`.trim(),
      'Seleccione un cliente...'
    );

    fillSelect(
      selectClienteMascota,
      clientes,
      (cliente) => cliente.id_cliente,
      (cliente) => `${cliente.id_cliente} - ${cliente.nombre} ${cliente.apellido1 || ''}`.trim(),
      'Seleccione un cliente...'
    );

    fillSelectGroup(
      '.select-mascotas',
      mascotas,
      (mascota) => mascota.id_mascota,
      (mascota) => `${mascota.id_mascota} - ${mascota.nombre_mascota || mascota.nombre || 'Mascota'}`,
      'Seleccione una mascota...'
    );

    fillSelect(
      selectMascotaCita,
      mascotas,
      (mascota) => mascota.id_mascota,
      (mascota) => `${mascota.id_mascota} - ${mascota.nombre_mascota || mascota.nombre || 'Mascota'}`,
      'Seleccione una mascota...'
    );

    fillSelectGroup(
      '.select-productos',
      productos,
      (producto) => producto.id_producto,
      (producto) => `${producto.id_producto} - ${producto.nombre}`,
      'Seleccione un producto...'
    );

    fillSelectGroup(
      '.select-usuarios',
      usuarios,
      (usuario) => usuario.id_usuario,
      (usuario) => `${usuario.id_usuario} - ${usuario.nombre} ${usuario.apellido1 || ''}`.trim(),
      'Seleccione un usuario...'
    );

    fillSelectGroup(
      '.select-ventas',
      ventas,
      (venta) => venta.id_venta,
      (venta) => `${venta.id_venta} - Total ${venta.total ?? 0}`,
      'Seleccione una venta...'
    );
  } catch (error) {
    showToast(`No se pudieron cargar las listas: ${error.message}`, 'error');
  }
}

navButtons.forEach((button) => {
  button.addEventListener('click', () => {
    const sectionId = button.dataset.section;
    showSection(sectionId);
    loadSectionData(sectionId);
  });
});

loadButtons.forEach((button) => {
  button.addEventListener('click', () => {
    loadPanelData(button.closest('.panel'));
  });
});

reportButtons.forEach((button) => {
  button.addEventListener('click', async () => {
    await loadReport(button.dataset.endpoint);
  });
});

dataForms.forEach((form) => {
  form.addEventListener('submit', async (event) => {
    event.preventDefault();

    try {
      const payload = getFormData(form);
      const result = await postData(form.dataset.endpoint, payload);
      form.reset();

      const panelId = form.dataset.reloadPanel;
      const panel = panelId ? document.getElementById(panelId) : null;
      if (panel) {
        await loadPanelData(panel, false);
      }

      await updateSummary(false);

      if (form.dataset.refreshSelects === 'true') {
        await loadReferenceSelects();
      }

      showToast(result.message || 'Operacion realizada correctamente', 'success');
    } catch (error) {
      showToast(error.message, 'error');
    }
  });
});

document.getElementById('loadAllButton').addEventListener('click', updateSummary);

checkServer();
updateSummary();
loadReferenceSelects();
