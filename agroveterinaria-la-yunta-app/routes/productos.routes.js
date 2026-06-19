const express = require('express');
const { sql, getPool } = require('../db');

const router = express.Router();

function parseDate(value) {
  return value ? new Date(`${value}T00:00:00`) : null;
}

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_producto_consultar');

    res.json({
      success: true,
      message: 'Productos consultados correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar productos:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar productos',
      details: error.message
    });
  }
});

router.post('/', async (req, res) => {
  const { id_producto, nombre, tipo, precio, fecha_registro } = req.body;

  try {
    const pool = await getPool();

    await pool.request()
      .input('id_producto', sql.VarChar(10), id_producto)
      .input('nombre', sql.VarChar(60), nombre)
      .input('tipo', sql.VarChar(30), tipo)
      .input('precio', sql.Int, Number(precio))
      .input('fecha_registro', sql.Date, parseDate(fecha_registro))
      .execute('usp_producto_insertar');

    res.status(201).json({
      success: true,
      message: 'Producto registrado correctamente',
      data: {
        id_producto
      }
    });
  } catch (error) {
    console.error('Error al registrar producto:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar producto',
      details: error.message
    });
  }
});

module.exports = router;
