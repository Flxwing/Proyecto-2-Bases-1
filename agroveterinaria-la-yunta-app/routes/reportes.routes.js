const express = require('express');
const { getPool } = require('../db');

const router = express.Router();

async function consultarVista(res, nombreVista, nombreReporte) {
  try {
    const pool = await getPool();

    const result = await pool.request().query(`
      SELECT * 
      FROM dbo.${nombreVista}
    `);

    res.json({
      success: true,
      message: `${nombreReporte} consultado correctamente`,
      data: result.recordset
    });
  } catch (error) {
    console.error(`Error al consultar ${nombreReporte}:`, error.message);

    res.status(500).json({
      success: false,
      error: `Error al consultar ${nombreReporte}`,
      details: error.message
    });
  }
}

/* Ruta de diagnóstico para saber si la app ve las vistas */
router.get('/debug/vistas', async (req, res) => {
  try {
    const pool = await getPool();

    const result = await pool.request().query(`
      SELECT 
        DB_NAME() AS base_actual,
        name AS vista
      FROM sys.views
      ORDER BY name;
    `);

    res.json({
      success: true,
      message: 'Vistas diagnosticadas correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al diagnosticar vistas:', error.message);

    res.status(500).json({
      success: false,
      error: 'Error al diagnosticar vistas',
      details: error.message
    });
  }
});

router.get('/ventas-detalle', async (req, res) => {
  await consultarVista(res, 'vw_ventas_detalle', 'reporte de ventas detalle');
});

router.get('/citas-mascotas-clientes', async (req, res) => {
  await consultarVista(res, 'vw_citas_mascotas_clientes', 'reporte de citas, mascotas y clientes');
});

router.get('/inventario-productos', async (req, res) => {
  await consultarVista(res, 'vw_inventario_productos', 'reporte de inventario y productos');
});

module.exports = router;
