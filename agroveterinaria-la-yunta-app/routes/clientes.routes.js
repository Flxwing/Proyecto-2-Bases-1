const express = require('express');
const { sql, getPool } = require('../db');

const router = express.Router();

function parseDate(value) {
  return value ? new Date(`${value}T00:00:00`) : null;
}

router.get('/', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().execute('usp_clientes_consultar');

    res.json({
      success: true,
      message: 'Clientes consultados correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al consultar clientes:', error);
    res.status(500).json({
      success: false,
      error: 'Error al consultar clientes',
      details: error.message
    });
  }
});

router.post('/completo', async (req, res) => {
  const {
    cedula,
    nombre,
    apellido1,
    apellido2,
    fecha_nacimiento,
    direccion,
    id_cliente
  } = req.body;

  let transaction;

  try {
    const pool = await getPool();
    transaction = new sql.Transaction(pool);
    await transaction.begin();

    await new sql.Request(transaction)
      .input('cedula', sql.VarChar(11), cedula)
      .input('nombre', sql.VarChar(60), nombre)
      .input('apellido1', sql.VarChar(40), apellido1)
      .input('apellido2', sql.VarChar(40), apellido2 || null)
      .input('fecha_nacimiento', sql.Date, parseDate(fecha_nacimiento))
      .input('direccion', sql.VarChar(120), direccion || null)
      .execute('usp_personas_insertar');

    await new sql.Request(transaction)
      .input('cedula', sql.VarChar(11), cedula)
      .input('id_cliente', sql.VarChar(10), id_cliente)
      .execute('usp_clientes_insertar');

    await transaction.commit();

    res.status(201).json({
      success: true,
      message: 'Cliente completo registrado correctamente',
      data: {
        cedula,
        id_cliente
      }
    });
  } catch (error) {
    if (transaction) {
      try {
        await transaction.rollback();
      } catch (rollbackError) {
        console.error('Error al revertir registro de cliente:', rollbackError);
      }
    }

    console.error('Error al registrar cliente completo:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar cliente completo',
      details: error.message
    });
  }
});

module.exports = router;
