const express = require('express');
const { sql, getPool } = require('../db');

const router = express.Router();

function parseDate(value) {
  return value ? new Date(`${value}T00:00:00`) : null;
}

function parseSqlTime(value) {
  if (!value) return null;

  const parts = value.split(':');
  const hours = parseInt(parts[0], 10);
  const minutes = parseInt(parts[1], 10);
  const seconds = parts[2] ? parseInt(parts[2], 10) : 0;

  return new Date(Date.UTC(1970, 0, 1, hours, minutes, seconds));
}

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_cita_consultar');

    res.json({
      success: true,
      message: 'Citas consultadas correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar citas:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar citas',
      details: error.message
    });
  }
});

router.post('/', async (req, res) => {
  const { id_cita, id_mascota, fecha_cita, hora, motivo } = req.body;

  try {
    const pool = await getPool();

    await pool.request()
      .input('id_cita', sql.VarChar(10), id_cita)
      .input('id_mascota', sql.VarChar(10), id_mascota)
      .input('fecha_cita', sql.Date, parseDate(fecha_cita))
      .input('hora', sql.Time, parseSqlTime(hora))
      .input('motivo', sql.VarChar(150), motivo || null)
      .execute('usp_cita_insertar');

    res.status(201).json({
      success: true,
      message: 'Cita registrada correctamente',
      data: {
        id_cita,
        id_mascota
      }
    });
  } catch (error) {
    console.error('Error al registrar cita:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar cita',
      details: error.message
    });
  }
});

module.exports = router;
