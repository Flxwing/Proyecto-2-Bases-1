const express = require('express');
const { sql, getPool } = require('../db');

const router = express.Router();

function parseDate(value) {
  return value ? new Date(`${value}T00:00:00`) : null;
}

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_mascotas_consultar');

    res.json({
      success: true,
      message: 'Mascotas consultadas correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar mascotas:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar mascotas',
      details: error.message
    });
  }
});

router.post('/', async (req, res) => {
  const { id_mascota, id_cliente, nombre, especie, peso, genero, fecha_nacimiento } = req.body;

  try {
    const pool = await getPool();

    await pool.request()
      .input('id_mascota', sql.VarChar(10), id_mascota)
      .input('id_cliente', sql.VarChar(10), id_cliente)
      .input('nombre', sql.VarChar(40), nombre)
      .input('especie', sql.VarChar(30), especie)
      .input('peso', sql.Int, peso === '' || peso === undefined ? null : Number(peso))
      .input('genero', sql.VarChar(10), genero || null)
      .input('fecha_nacimiento', sql.Date, parseDate(fecha_nacimiento))
      .execute('usp_mascotas_insertar');

    res.status(201).json({
      success: true,
      message: 'Mascota registrada correctamente',
      data: {
        id_mascota,
        id_cliente
      }
    });
  } catch (error) {
    console.error('Error al registrar mascota:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar mascota',
      details: error.message
    });
  }
});

module.exports = router;
