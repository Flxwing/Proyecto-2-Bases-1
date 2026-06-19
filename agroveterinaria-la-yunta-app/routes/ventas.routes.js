const express = require('express');
const { getPool } = require('../db');

const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_venta_consultar');

    res.json({
      success: true,
      message: 'Ventas consultadas correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar ventas:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar ventas',
      details: error.message
    });
  }
});

module.exports = router;
