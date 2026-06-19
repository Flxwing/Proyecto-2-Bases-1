const express = require('express');
const { getPool } = require('../db');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_producto_inventario_consultar');

    res.json({
      success: true,
      message: 'Inventario consultado correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar inventario:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar inventario',
      details: error.message
    });
  }
});

module.exports = router;
