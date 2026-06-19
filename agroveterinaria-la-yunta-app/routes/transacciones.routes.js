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

router.post('/venta-completa', async (req, res) => {
  const {
    id_venta,
    id_usuario,
    id_producto,
    cantidad,
    id_pago,
    metodo_pago,
    estado_pago
  } = req.body;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id_venta', sql.VarChar(10), id_venta)
      .input('id_usuario', sql.VarChar(10), id_usuario)
      .input('id_producto', sql.VarChar(10), id_producto)
      .input('cantidad', sql.Int, Number(cantidad))
      .input('id_pago', sql.VarChar(10), id_pago)
      .input('metodo_pago', sql.VarChar(10), metodo_pago)
      .input('estado_pago', sql.VarChar(15), estado_pago || 'Aprobado')
      .execute('usp_transaccion_registrar_venta_completa');

    res.status(201).json({
      success: true,
      message: 'Venta completa registrada correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al registrar venta completa:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar venta completa',
      details: error.message
    });
  }
});

router.post('/pedido-completo', async (req, res) => {
  const { id_pedido, id_cliente, id_producto, tipo_entrega, estado } = req.body;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id_pedido', sql.VarChar(10), id_pedido)
      .input('id_cliente', sql.VarChar(10), id_cliente)
      .input('id_producto', sql.VarChar(10), id_producto)
      .input('tipo_entrega', sql.VarChar(15), tipo_entrega)
      .input('estado', sql.VarChar(15), estado || 'Pendiente')
      .execute('usp_transaccion_registrar_pedido_completo');

    res.status(201).json({
      success: true,
      message: 'Pedido completo registrado correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al registrar pedido completo:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar pedido completo',
      details: error.message
    });
  }
});

router.post('/producto-inventario', async (req, res) => {
  const {
    id_producto,
    nombre,
    tipo,
    precio,
    id_inventario,
    fecha_inventario,
    stock_actual,
    ubicacion,
    fecha_registro
  } = req.body;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id_producto', sql.VarChar(10), id_producto)
      .input('nombre', sql.VarChar(60), nombre)
      .input('tipo', sql.VarChar(30), tipo)
      .input('precio', sql.Int, Number(precio))
      .input('id_inventario', sql.VarChar(10), id_inventario)
      .input('fecha_inventario', sql.Date, parseDate(fecha_inventario))
      .input('stock_actual', sql.Int, Number(stock_actual))
      .input('ubicacion', sql.VarChar(50), ubicacion || null)
      .input('fecha_registro', sql.Date, parseDate(fecha_registro))
      .execute('usp_transaccion_registrar_producto_con_inventario');

    res.status(201).json({
      success: true,
      message: 'Producto con inventario registrado correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al registrar producto con inventario:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar producto con inventario',
      details: error.message
    });
  }
});

router.post('/cita-procedimiento', async (req, res) => {
  const {
    id_cita,
    id_mascota,
    fecha_cita,
    hora,
    motivo,
    id_procedimiento,
    id_usuario,
    descripcion,
    fecha_procedimiento
  } = req.body;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id_cita', sql.VarChar(10), id_cita)
      .input('id_mascota', sql.VarChar(10), id_mascota)
      .input('fecha_cita', sql.Date, parseDate(fecha_cita))
      .input('hora', sql.Time, parseSqlTime(hora))
      .input('motivo', sql.VarChar(150), motivo || null)
      .input('id_procedimiento', sql.VarChar(10), id_procedimiento)
      .input('id_usuario', sql.VarChar(10), id_usuario)
      .input('descripcion', sql.VarChar(150), descripcion)
      .input('fecha_procedimiento', sql.Date, parseDate(fecha_procedimiento))
      .execute('usp_transaccion_registrar_cita_con_procedimiento');

    res.status(201).json({
      success: true,
      message: 'Cita con procedimiento registrada correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al registrar cita con procedimiento:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar cita con procedimiento',
      details: error.message
    });
  }
});

router.post('/procesar-pago', async (req, res) => {
  const { id_pago, id_venta, monto, metodo_pago, fecha_pago } = req.body;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('id_pago', sql.VarChar(10), id_pago)
      .input('id_venta', sql.VarChar(10), id_venta)
      .input('monto', sql.Int, Number(monto))
      .input('metodo_pago', sql.VarChar(10), metodo_pago)
      .input('fecha_pago', sql.Date, parseDate(fecha_pago))
      .execute('usp_transaccion_procesar_pago_venta');

    res.status(201).json({
      success: true,
      message: 'Pago procesado correctamente',
      data: result.recordset
    });
  } catch (error) {
    console.error('Error al procesar pago:', error);
    res.status(500).json({
      success: false,
      error: 'Error al procesar pago',
      details: error.message
    });
  }
});

module.exports = router;
