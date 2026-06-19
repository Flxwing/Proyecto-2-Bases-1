const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { getPool } = require('./db');

const clientesRoutes = require('./routes/clientes.routes');
const mascotasRoutes = require('./routes/mascotas.routes');
const productosRoutes = require('./routes/productos.routes');
const inventarioRoutes = require('./routes/inventario.routes');
const ventasRoutes = require('./routes/ventas.routes');
const citasRoutes = require('./routes/citas.routes');
const reportesRoutes = require('./routes/reportes.routes');
const transaccionesRoutes = require('./routes/transacciones.routes');
const usuariosRoutes = require('./routes/usuarios.routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

app.get('/api/health', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT
        DB_NAME() AS base_datos,
        @@SERVERNAME AS servidor
    `);

    res.json({
      success: true,
      ok: true,
      message: 'Servidor y base de datos conectados',
      data: result.recordset[0]
    });
  } catch (error) {
    console.error('Error al verificar servidor:', error);
    res.status(500).json({
      success: false,
      ok: false,
      error: 'Servidor activo, pero no se pudo conectar a SQL Server',
      details: error.message
    });
  }
});

app.use('/api/clientes', clientesRoutes);
app.use('/api/mascotas', mascotasRoutes);
app.use('/api/productos', productosRoutes);
app.use('/api/inventario', inventarioRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/citas', citasRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/transacciones', transaccionesRoutes);
app.use('/api/usuarios', usuariosRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Ruta no encontrada'
  });
});

app.listen(PORT, () => {
  console.log(`Servidor ejecutandose en http://localhost:${PORT}`);
});
