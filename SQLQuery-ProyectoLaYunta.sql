/* ============================================================
   INSTITUTO TECNOLÓGICO DE COSTA RICA
   CURSO: BASES DE DATOS
   SEGUNDO PROYECTO

   SISTEMA: AGROVETERINARIA LA YUNTA
   BASE DE DATOS: BD_AgroveterinariaLaYunta

   Contenido:
   Paso 0  - Creación o reinicio de base de datos
   Paso 1  - Tipos de datos personalizados
   Paso 2  - Reglas y asociación de reglas
   Paso 3  - Creación de tablas
   Paso 4  - Índices
   Paso 5  - Datos de prueba
   Paso 6  - Vistas
   Paso 7  - Triggers
   Paso 8  - Cursores
   Paso 9  - Consultas avanzadas
   Paso 10 - Procedimientos CRUD
   Paso 11 - Procedimientos con transacciones
   Paso 12 - Pruebas generales
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

SELECT 
    COUNT(*) AS cantidad_procedimientos
FROM sys.procedures;
GO

USE BD_AgroveterinariaLaYunta;
GO

SELECT 
    name AS procedimiento
FROM sys.procedures
ORDER BY name;
GO

USE BD_AgroveterinariaLaYunta;
GO

SELECT 
    name AS procedimiento_crud
FROM sys.procedures
WHERE name LIKE 'usp_%'
  AND name NOT LIKE 'usp_cursor%'
ORDER BY name;
GO


/* ============================================================
   PASO 0: CREACIÓN O REINICIO DE BASE DE DATOS

   ADVERTENCIA:
   El PASO 0 elimina y vuelve a crear la base de datos.
   Ejecutarlo solo si se desea reiniciar todo desde cero.
   ============================================================ */

USE master;
GO

IF DB_ID('BD_AgroveterinariaLaYunta') IS NOT NULL
BEGIN
    ALTER DATABASE BD_AgroveterinariaLaYunta 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE BD_AgroveterinariaLaYunta;
END
GO

CREATE DATABASE BD_AgroveterinariaLaYunta;
GO

USE BD_AgroveterinariaLaYunta;
GO


/* ============================================================
   PASO 1: TIPOS DE DATOS PERSONALIZADOS
   ============================================================ */

/* 
   Los tipos de datos personalizados permiten reutilizar dominios
   en varias tablas del sistema, como cédulas, teléfonos, montos,
   cantidades, estados y roles.
*/

CREATE TYPE T_CEDULA FROM VARCHAR(11);
GO

CREATE TYPE T_TELEFONO FROM VARCHAR(9);
GO

CREATE TYPE T_ID_INTERNO FROM VARCHAR(10);
GO

CREATE TYPE T_NOMBRE FROM VARCHAR(60);
GO

CREATE TYPE T_APELLIDO FROM VARCHAR(40);
GO

CREATE TYPE T_DIRECCION FROM VARCHAR(120);
GO

CREATE TYPE T_ROL_USUARIO FROM VARCHAR(25);
GO

CREATE TYPE T_CONTRASENA FROM VARCHAR(100);
GO

CREATE TYPE T_NOMBRE_MASCOTA FROM VARCHAR(40);
GO

CREATE TYPE T_ESPECIE FROM VARCHAR(30);
GO

CREATE TYPE T_GENERO_MASCOTA FROM VARCHAR(10);
GO

CREATE TYPE T_NOMBRE_PRODUCTO FROM VARCHAR(60);
GO

CREATE TYPE T_TIPO_PRODUCTO FROM VARCHAR(30);
GO

CREATE TYPE T_MONTO FROM INT;
GO

CREATE TYPE T_CANTIDAD FROM INT;
GO

CREATE TYPE T_STOCK FROM INT;
GO

CREATE TYPE T_TIPO_ENTREGA FROM VARCHAR(15);
GO

CREATE TYPE T_ESTADO_PEDIDO FROM VARCHAR(15);
GO

CREATE TYPE T_METODO_PAGO FROM VARCHAR(10);
GO

CREATE TYPE T_ESTADO_PAGO FROM VARCHAR(15);
GO

CREATE TYPE T_TEXTO_MEDIO FROM VARCHAR(150);
GO



/* ============================================================
   PASO 3: CREACIÓN DE TABLAS
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* =========================
   TABLA: PERSONAS
   ========================= */
CREATE TABLE personas (
    cedula T_CEDULA NOT NULL,
    nombre T_NOMBRE NOT NULL,
    apellido1 T_APELLIDO NOT NULL,
    apellido2 T_APELLIDO NULL,
    fecha_nacimiento DATE NOT NULL,
    direccion T_DIRECCION NULL,

    CONSTRAINT PK_personas PRIMARY KEY (cedula),

    CONSTRAINT CK_personas_cedula
        CHECK (cedula LIKE '[0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),

    CONSTRAINT CK_personas_fecha_nacimiento
        CHECK (fecha_nacimiento <= CAST(GETDATE() AS DATE))
);
GO

/* =========================
   TABLA: CLIENTES
   Especialización de persona
   ========================= */
CREATE TABLE clientes (
    cedula T_CEDULA NOT NULL,
    id_cliente T_ID_INTERNO NOT NULL,

    CONSTRAINT PK_clientes PRIMARY KEY (cedula),
    CONSTRAINT UQ_clientes_id_cliente UNIQUE (id_cliente),

    CONSTRAINT FK_clientes_personas
        FOREIGN KEY (cedula)
        REFERENCES personas(cedula)
);
GO

/* =========================
   TABLA: USUARIOS
   Especialización de persona
   ========================= */
CREATE TABLE usuarios (
    cedula T_CEDULA NOT NULL,
    id_usuario T_ID_INTERNO NOT NULL,
    rol T_ROL_USUARIO NOT NULL,
    contrasena T_CONTRASENA NOT NULL,

    CONSTRAINT PK_usuarios PRIMARY KEY (cedula),
    CONSTRAINT UQ_usuarios_id_usuario UNIQUE (id_usuario),

    CONSTRAINT FK_usuarios_personas
        FOREIGN KEY (cedula)
        REFERENCES personas(cedula),

    CONSTRAINT CK_usuarios_rol
        CHECK (rol IN (
            'gerente',
            'jefe_ventas',
            'asesor',
            'encargado_inventario',
            'asistente',
            'cajero'
        ))
);
GO

/* =========================
   TABLA: TELEFONOS_PERSONAS
   Atributo multivaluado
   ========================= */
CREATE TABLE telefonos_personas (
    cedula T_CEDULA NOT NULL,
    telefono T_TELEFONO NOT NULL,

    CONSTRAINT PK_telefonos_personas PRIMARY KEY (cedula, telefono),

    CONSTRAINT FK_telefonos_personas_personas
        FOREIGN KEY (cedula)
        REFERENCES personas(cedula),

    CONSTRAINT CK_telefonos_personas_telefono
        CHECK (telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
);
GO

/* =========================
   TABLA: MASCOTAS
   ========================= */
CREATE TABLE mascotas (
    id_mascota T_ID_INTERNO NOT NULL,
    id_cliente T_ID_INTERNO NOT NULL,
    nombre T_NOMBRE_MASCOTA NOT NULL,
    especie T_ESPECIE NOT NULL,
    peso INT NULL,
    genero T_GENERO_MASCOTA NULL,
    fecha_nacimiento DATE NULL,

    CONSTRAINT PK_mascotas PRIMARY KEY (id_mascota),

    CONSTRAINT FK_mascotas_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT CK_mascotas_peso
        CHECK (peso IS NULL OR peso >= 0),

    CONSTRAINT CK_mascotas_genero
        CHECK (genero IS NULL OR genero IN ('Macho', 'Hembra')),

    CONSTRAINT CK_mascotas_fecha_nacimiento
        CHECK (fecha_nacimiento IS NULL OR fecha_nacimiento <= CAST(GETDATE() AS DATE))
);
GO

/* =========================
   TABLA: PRODUCTO
   ========================= */
CREATE TABLE producto (
    id_producto T_ID_INTERNO NOT NULL,
    nombre T_NOMBRE_PRODUCTO NOT NULL,
    tipo T_TIPO_PRODUCTO NOT NULL,
    precio T_MONTO NOT NULL
        CONSTRAINT DF_producto_precio DEFAULT 0,
    fecha_registro DATE NOT NULL
        CONSTRAINT DF_producto_fecha_registro DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT PK_producto PRIMARY KEY (id_producto),

    CONSTRAINT CK_producto_tipo
        CHECK (tipo IN (
            'Veterinario',
            'Agroquimico',
            'Concentrado',
            'Herramienta',
            'Otro'
        )),

    CONSTRAINT CK_producto_precio
        CHECK (precio >= 0 AND precio <= 9999999)
);
GO

/* =========================
   TABLA: VENTA
   ========================= */
CREATE TABLE venta (
    id_venta T_ID_INTERNO NOT NULL,
    id_usuario T_ID_INTERNO NOT NULL,
    fecha_venta DATE NOT NULL
        CONSTRAINT DF_venta_fecha_venta DEFAULT CAST(GETDATE() AS DATE),
    total T_MONTO NOT NULL
        CONSTRAINT DF_venta_total DEFAULT 0,

    CONSTRAINT PK_venta PRIMARY KEY (id_venta),

    CONSTRAINT FK_venta_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario),

    CONSTRAINT CK_venta_total
        CHECK (total >= 0 AND total <= 9999999)
);
GO

/* =========================
   TABLA: PAGO
   ========================= */
CREATE TABLE pago (
    id_pago T_ID_INTERNO NOT NULL,
    id_venta T_ID_INTERNO NOT NULL,
    monto T_MONTO NOT NULL
        CONSTRAINT DF_pago_monto DEFAULT 0,
    metodo_pago T_METODO_PAGO NOT NULL,
    estado T_ESTADO_PAGO NOT NULL
        CONSTRAINT DF_pago_estado DEFAULT 'Pendiente',
    fecha_pago DATE NOT NULL
        CONSTRAINT DF_pago_fecha_pago DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT PK_pago PRIMARY KEY (id_pago),
    CONSTRAINT UQ_pago_id_venta UNIQUE (id_venta),

    CONSTRAINT FK_pago_venta
        FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta),

    CONSTRAINT CK_pago_monto
        CHECK (monto >= 0 AND monto <= 9999999),

    CONSTRAINT CK_pago_metodo
        CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'SINPE')),

    CONSTRAINT CK_pago_estado
        CHECK (estado IN ('Pendiente', 'Aprobado', 'Rechazado'))
);
GO

/* =========================
   TABLA: PEDIDO
   ========================= */
CREATE TABLE pedido (
    id_pedido T_ID_INTERNO NOT NULL,
    id_cliente T_ID_INTERNO NOT NULL,
    tipo_entrega T_TIPO_ENTREGA NOT NULL,
    estado T_ESTADO_PEDIDO NOT NULL
        CONSTRAINT DF_pedido_estado DEFAULT 'Pendiente',

    CONSTRAINT PK_pedido PRIMARY KEY (id_pedido),

    CONSTRAINT FK_pedido_clientes
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT CK_pedido_tipo_entrega
        CHECK (tipo_entrega IN ('Recoger', 'Domicilio')),

    CONSTRAINT CK_pedido_estado
        CHECK (estado IN ('Pendiente', 'Preparacion', 'Entregado', 'Cancelado'))
);
GO

/* =========================
   TABLA: CITA
   ========================= */
CREATE TABLE cita (
    id_cita T_ID_INTERNO NOT NULL,
    id_mascota T_ID_INTERNO NOT NULL,
    fecha_cita DATE NOT NULL,
    hora TIME NOT NULL,
    motivo T_TEXTO_MEDIO NULL,

    CONSTRAINT PK_cita PRIMARY KEY (id_cita),

    CONSTRAINT FK_cita_mascotas
        FOREIGN KEY (id_mascota)
        REFERENCES mascotas(id_mascota)
);
GO

/* =========================
   TABLA: PROCEDIMIENTO
   ========================= */
CREATE TABLE procedimiento (
    id_procedimiento T_ID_INTERNO NOT NULL,
    id_usuario T_ID_INTERNO NOT NULL,
    id_cita T_ID_INTERNO NOT NULL,
    descripcion T_TEXTO_MEDIO NOT NULL,
    fecha_procedimiento DATE NOT NULL
        CONSTRAINT DF_procedimiento_fecha DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT PK_procedimiento PRIMARY KEY (id_procedimiento),

    CONSTRAINT FK_procedimiento_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario),

    CONSTRAINT FK_procedimiento_cita
        FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
);
GO

/* =========================
   TABLA: INVENTARIO
   ========================= */
CREATE TABLE inventario (
    id_inventario T_ID_INTERNO NOT NULL,
    fecha_inventario DATE NOT NULL
        CONSTRAINT DF_inventario_fecha DEFAULT CAST(GETDATE() AS DATE),

    CONSTRAINT PK_inventario PRIMARY KEY (id_inventario)
);
GO

/* =========================
   TABLA: PRODUCTO_VENTA
   Relación N:M producto - venta
   ========================= */
CREATE TABLE producto_venta (
    id_producto T_ID_INTERNO NOT NULL,
    id_venta T_ID_INTERNO NOT NULL,
    cantidad T_CANTIDAD NOT NULL,
    subtotal T_MONTO NOT NULL
        CONSTRAINT DF_producto_venta_subtotal DEFAULT 0,

    CONSTRAINT PK_producto_venta PRIMARY KEY (id_producto, id_venta),

    CONSTRAINT FK_producto_venta_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT FK_producto_venta_venta
        FOREIGN KEY (id_venta)
        REFERENCES venta(id_venta),

    CONSTRAINT CK_producto_venta_cantidad
        CHECK (cantidad > 0 AND cantidad <= 100000),

    CONSTRAINT CK_producto_venta_subtotal
        CHECK (subtotal >= 0 AND subtotal <= 9999999)
);
GO

/* =========================
   TABLA: PRODUCTO_INVENTARIO
   Relación N:M producto - inventario
   ========================= */
CREATE TABLE producto_inventario (
    id_producto T_ID_INTERNO NOT NULL,
    id_inventario T_ID_INTERNO NOT NULL,
    stock_actual T_STOCK NOT NULL
        CONSTRAINT DF_producto_inventario_stock DEFAULT 0,
    ubicacion VARCHAR(50) NULL,

    CONSTRAINT PK_producto_inventario PRIMARY KEY (id_producto, id_inventario),

    CONSTRAINT FK_producto_inventario_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT FK_producto_inventario_inventario
        FOREIGN KEY (id_inventario)
        REFERENCES inventario(id_inventario),

    CONSTRAINT CK_producto_inventario_stock
        CHECK (stock_actual >= 0 AND stock_actual <= 100000)
);
GO

/* =========================
   TABLA: PRODUCTO_PEDIDO
   Relación N:M producto - pedido
   ========================= */
CREATE TABLE producto_pedido (
    id_producto T_ID_INTERNO NOT NULL,
    id_pedido T_ID_INTERNO NOT NULL,

    CONSTRAINT PK_producto_pedido PRIMARY KEY (id_producto, id_pedido),

    CONSTRAINT FK_producto_pedido_producto
        FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto),

    CONSTRAINT FK_producto_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
);
GO

/* ============================================================
   PASO 4: ÍNDICES
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* 
   Índice 1:
   Permite buscar rápidamente las mascotas asociadas a un cliente.
   Es útil para consultas del módulo de clientes, mascotas y citas.
*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_mascotas_id_cliente'
      AND object_id = OBJECT_ID('mascotas')
)
BEGIN
    CREATE INDEX IDX_mascotas_id_cliente
    ON mascotas(id_cliente);
END
GO

/* 
   Índice 2:
   Permite consultar ventas por usuario y fecha.
   Es útil para reportes de ventas, consultas por empleado
   y análisis de actividad comercial.
*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_venta_usuario_fecha'
      AND object_id = OBJECT_ID('venta')
)
BEGIN
    CREATE INDEX IDX_venta_usuario_fecha
    ON venta(id_usuario, fecha_venta);
END
GO

/* 
   Índice 3:
   Permite consultar citas por mascota y fecha.
   Es útil para revisar el historial veterinario de una mascota.
*/
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IDX_cita_mascota_fecha'
      AND object_id = OBJECT_ID('cita')
)
BEGIN
    CREATE INDEX IDX_cita_mascota_fecha
    ON cita(id_mascota, fecha_cita);
END
GO

/* ============================================================
   PASO 5: DATOS DE PRUEBA
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* =========================
   PERSONAS
   ========================= */
INSERT INTO personas (cedula, nombre, apellido1, apellido2, fecha_nacimiento, direccion)
VALUES
('1-1111-1111', 'Carlos', 'Mora', 'Soto', '1985-03-12', 'Ciudad Quesada'),
('2-2222-2222', 'Mariana', 'Lopez', 'Rojas', '1990-07-20', 'Florencia'),
('3-3333-3333', 'Andres', 'Vargas', 'Solano', '1995-11-05', 'La Fortuna'),
('4-4444-4444', 'Sofia', 'Ramirez', 'Castro', '1998-01-18', 'Muelle'),
('5-5555-5555', 'Jorge', 'Alpizar', 'Mendez', '1982-09-30', 'Pital'),
('6-6666-6666', 'Valeria', 'Campos', 'Arias', '2001-04-25', 'Aguas Zarcas');
GO

/* =========================
   CLIENTES
   ========================= */
INSERT INTO clientes (cedula, id_cliente)
VALUES
('3-3333-3333', 'CL001'),
('4-4444-4444', 'CL002'),
('5-5555-5555', 'CL003');
GO

/* =========================
   USUARIOS
   ========================= */
INSERT INTO usuarios (cedula, id_usuario, rol, contrasena)
VALUES
('1-1111-1111', 'US001', 'gerente', 'clave123'),
('2-2222-2222', 'US002', 'cajero', 'clave456'),
('6-6666-6666', 'US003', 'asesor', 'clave789');
GO

/* =========================
   TELEFONOS_PERSONAS
   ========================= */
INSERT INTO telefonos_personas (cedula, telefono)
VALUES
('1-1111-1111', '8888-1111'),
('2-2222-2222', '8888-2222'),
('3-3333-3333', '8888-3333'),
('4-4444-4444', '8888-4444'),
('5-5555-5555', '8888-5555'),
('6-6666-6666', '8888-6666');
GO

/* =========================
   MASCOTAS
   ========================= */
INSERT INTO mascotas (id_mascota, id_cliente, nombre, especie, peso, genero, fecha_nacimiento)
VALUES
('MA001', 'CL001', 'Firulais', 'Perro', 18, 'Macho', '2020-05-10'),
('MA002', 'CL001', 'Michi', 'Gato', 5, 'Hembra', '2021-08-15'),
('MA003', 'CL002', 'Rocky', 'Perro', 25, 'Macho', '2019-02-22'),
('MA004', 'CL003', 'Luna', 'Gato', 4, 'Hembra', '2022-12-01');
GO

/* =========================
   PRODUCTOS
   ========================= */
INSERT INTO producto (id_producto, nombre, tipo, precio, fecha_registro)
VALUES
('PR001', 'Vacuna Canina', 'Veterinario', 12500, '2026-04-09'),
('PR002', 'Concentrado Dog', 'Concentrado', 18000, '2026-04-09'),
('PR003', 'Desparasitante', 'Veterinario', 6500, '2026-04-10'),
('PR004', 'Fertilizante', 'Agroquimico', 22000, '2026-04-10'),
('PR005', 'Pala Jardin', 'Herramienta', 9500, '2026-04-11');
GO

/* =========================
   INVENTARIO
   ========================= */
INSERT INTO inventario (id_inventario, fecha_inventario)
VALUES
('IN001', '2026-04-09'),
('IN002', '2026-04-10');
GO

/* =========================
   PRODUCTO_INVENTARIO
   ========================= */
INSERT INTO producto_inventario (id_producto, id_inventario, stock_actual, ubicacion)
VALUES
('PR001', 'IN001', 40, 'Estante A'),
('PR002', 'IN001', 25, 'Bodega 1'),
('PR003', 'IN001', 60, 'Estante B'),
('PR004', 'IN002', 15, 'Bodega 2'),
('PR005', 'IN002', 10, 'Pasillo C');
GO

/* =========================
   VENTAS
   ========================= */
INSERT INTO venta (id_venta, id_usuario, fecha_venta, total)
VALUES
('VE001', 'US002', '2026-04-12', 30500),
('VE002', 'US002', '2026-04-13', 22000),
('VE003', 'US003', '2026-04-14', 25500);
GO

/* =========================
   PRODUCTO_VENTA
   ========================= */
INSERT INTO producto_venta (id_producto, id_venta, cantidad, subtotal)
VALUES
('PR001', 'VE001', 1, 12500),
('PR002', 'VE001', 1, 18000),
('PR004', 'VE002', 1, 22000),
('PR003', 'VE003', 1, 6500),
('PR005', 'VE003', 2, 19000);
GO

/* =========================
   PAGOS
   ========================= */
INSERT INTO pago (id_pago, id_venta, monto, metodo_pago, estado, fecha_pago)
VALUES
('PA001', 'VE001', 30500, 'Efectivo', 'Aprobado', '2026-04-12'),
('PA002', 'VE002', 22000, 'Tarjeta', 'Aprobado', '2026-04-13'),
('PA003', 'VE003', 25500, 'SINPE', 'Pendiente', '2026-04-14');
GO

/* =========================
   PEDIDOS
   ========================= */
INSERT INTO pedido (id_pedido, id_cliente, tipo_entrega, estado)
VALUES
('PE001', 'CL001', 'Domicilio', 'Pendiente'),
('PE002', 'CL002', 'Recoger', 'Preparacion'),
('PE003', 'CL003', 'Domicilio', 'Entregado');
GO

/* =========================
   PRODUCTO_PEDIDO
   ========================= */
INSERT INTO producto_pedido (id_producto, id_pedido)
VALUES
('PR001', 'PE001'),
('PR002', 'PE001'),
('PR003', 'PE002'),
('PR004', 'PE003');
GO

/* =========================
   CITAS
   ========================= */
INSERT INTO cita (id_cita, id_mascota, fecha_cita, hora, motivo)
VALUES
('CI001', 'MA001', '2026-04-15', '08:30', 'Consulta general'),
('CI002', 'MA002', '2026-04-16', '10:00', 'Vacunacion'),
('CI003', 'MA003', '2026-04-17', '14:30', 'Revision de piel'),
('CI004', 'MA004', '2026-04-18', '09:15', 'Control general');
GO

/* =========================
   PROCEDIMIENTOS
   ========================= */
INSERT INTO procedimiento (id_procedimiento, id_usuario, id_cita, descripcion, fecha_procedimiento)
VALUES
('PC001', 'US003', 'CI001', 'Revision fisica general', '2026-04-15'),
('PC002', 'US003', 'CI002', 'Aplicacion de vacuna', '2026-04-16'),
('PC003', 'US003', 'CI003', 'Tratamiento dermatologico', '2026-04-17');
GO

/* ============================================================
   PASO 6: VISTAS
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* ============================================================
   VISTA 1: DETALLE DE VENTAS
   Muestra cada venta con el usuario que la registró,
   productos vendidos, cantidades, subtotales y estado del pago.
   ============================================================ */
CREATE OR ALTER VIEW vw_ventas_detalle
AS
SELECT
    v.id_venta,
    v.fecha_venta,
    u.id_usuario,
    p_usuario.nombre + ' ' + p_usuario.apellido1 AS usuario_registra,
    pr.id_producto,
    pr.nombre AS producto,
    pr.tipo AS tipo_producto,
    pr.precio,
    pv.cantidad,
    pv.subtotal,
    v.total AS total_venta,
    pa.metodo_pago,
    pa.estado AS estado_pago,
    pa.fecha_pago
FROM venta v
INNER JOIN usuarios u
    ON v.id_usuario = u.id_usuario
INNER JOIN personas p_usuario
    ON u.cedula = p_usuario.cedula
INNER JOIN producto_venta pv
    ON v.id_venta = pv.id_venta
INNER JOIN producto pr
    ON pv.id_producto = pr.id_producto
LEFT JOIN pago pa
    ON v.id_venta = pa.id_venta;
GO


/* ============================================================
   VISTA 2: CITAS CON MASCOTAS Y CLIENTES
   Muestra las citas veterinarias junto con la mascota,
   el cliente propietario y los procedimientos asociados.
   ============================================================ */
CREATE OR ALTER VIEW vw_citas_mascotas_clientes
AS
SELECT
    c.id_cita,
    c.fecha_cita,
    c.hora,
    c.motivo,
    m.id_mascota,
    m.nombre AS nombre_mascota,
    m.especie,
    m.genero,
    DATEDIFF(YEAR, m.fecha_nacimiento, GETDATE()) AS edad_aproximada_mascota,
    cl.id_cliente,
    p_cliente.cedula,
    p_cliente.nombre + ' ' + p_cliente.apellido1 AS nombre_cliente,
    prc.id_procedimiento,
    prc.descripcion AS procedimiento_realizado,
    prc.fecha_procedimiento
FROM cita c
INNER JOIN mascotas m
    ON c.id_mascota = m.id_mascota
INNER JOIN clientes cl
    ON m.id_cliente = cl.id_cliente
INNER JOIN personas p_cliente
    ON cl.cedula = p_cliente.cedula
LEFT JOIN procedimiento prc
    ON c.id_cita = prc.id_cita;
GO


/* ============================================================
   VISTA 3: INVENTARIO DE PRODUCTOS
   Muestra productos con su stock actual, ubicación
   y una clasificación del estado del inventario.
   ============================================================ */
CREATE OR ALTER VIEW vw_inventario_productos
AS
SELECT
    pr.id_producto,
    pr.nombre AS producto,
    pr.tipo AS tipo_producto,
    pr.precio,
    i.id_inventario,
    i.fecha_inventario,
    pi.stock_actual,
    pi.ubicacion,
    CASE
        WHEN pi.stock_actual = 0 THEN 'Sin stock'
        WHEN pi.stock_actual BETWEEN 1 AND 10 THEN 'Stock bajo'
        WHEN pi.stock_actual BETWEEN 11 AND 30 THEN 'Stock medio'
        ELSE 'Stock suficiente'
    END AS estado_inventario
FROM producto pr
INNER JOIN producto_inventario pi
    ON pr.id_producto = pi.id_producto
INNER JOIN inventario i
    ON pi.id_inventario = i.id_inventario;
GO

/* ============================================================
   PASO 7: TRIGGERS
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* ============================================================
   TRIGGER 1: LIMITAR TELÉFONOS POR PERSONA
   Evita que una persona tenga más de 3 teléfonos registrados.
   Se ejecuta después de insertar en telefonos_personas.
   ============================================================ */
CREATE OR ALTER TRIGGER trg_limitar_telefonos_persona
ON telefonos_personas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        GROUP BY i.cedula
        HAVING (
            SELECT COUNT(tp.telefono)
            FROM telefonos_personas tp
            WHERE tp.cedula = i.cedula
        ) > 3
    )
    BEGIN
        RAISERROR('No se pueden registrar mas de 3 telefonos por persona.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    PRINT 'Telefono insertado correctamente.';
END;
GO


/* ============================================================
   TRIGGER 2: ACTUALIZAR TOTAL DE VENTA
   Actualiza automáticamente el total de una venta cuando se
   insertan, modifican o eliminan productos de producto_venta.
   ============================================================ */
CREATE OR ALTER TRIGGER trg_actualizar_total_venta
ON producto_venta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE v
    SET v.total = ISNULL(detalle.total_calculado, 0)
    FROM venta v
    INNER JOIN (
        SELECT id_venta FROM inserted
        UNION
        SELECT id_venta FROM deleted
    ) ventas_afectadas
        ON v.id_venta = ventas_afectadas.id_venta
    OUTER APPLY (
        SELECT SUM(pv.subtotal) AS total_calculado
        FROM producto_venta pv
        WHERE pv.id_venta = v.id_venta
    ) detalle;

    PRINT 'Total de venta actualizado automaticamente.';
END;
GO


/* ============================================================
   TRIGGER 3: DESCONTAR STOCK POR VENTA
   Valida y descuenta stock cuando se inserta un producto
   vendido en producto_venta.
   Si no hay stock suficiente, cancela la operación.
   ============================================================ */
CREATE OR ALTER TRIGGER trg_descontar_stock_venta
ON producto_venta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* Validar que exista stock suficiente en el inventario más reciente */
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT 
                id_producto,
                SUM(cantidad) AS cantidad_vendida
            FROM inserted
            GROUP BY id_producto
        ) ins
        OUTER APPLY (
            SELECT TOP 1 
                pi.stock_actual
            FROM producto_inventario pi
            INNER JOIN inventario inv
                ON pi.id_inventario = inv.id_inventario
            WHERE pi.id_producto = ins.id_producto
            ORDER BY inv.fecha_inventario DESC, pi.id_inventario DESC
        ) stock_producto
        WHERE stock_producto.stock_actual IS NULL
           OR stock_producto.stock_actual < ins.cantidad_vendida
    )
    BEGIN
        RAISERROR('No hay suficiente stock para registrar la venta.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* Descontar stock del inventario más reciente de cada producto */
    UPDATE pi
    SET pi.stock_actual = pi.stock_actual - ins.cantidad_vendida
    FROM producto_inventario pi
    INNER JOIN (
        SELECT 
            id_producto,
            SUM(cantidad) AS cantidad_vendida
        FROM inserted
        GROUP BY id_producto
    ) ins
        ON pi.id_producto = ins.id_producto
    INNER JOIN inventario inv
        ON pi.id_inventario = inv.id_inventario
    WHERE pi.id_inventario = (
        SELECT TOP 1 pi2.id_inventario
        FROM producto_inventario pi2
        INNER JOIN inventario inv2
            ON pi2.id_inventario = inv2.id_inventario
        WHERE pi2.id_producto = pi.id_producto
        ORDER BY inv2.fecha_inventario DESC, pi2.id_inventario DESC
    );

    PRINT 'Stock descontado automaticamente.';
END;
GO

/* ============================================================
   PASO 8: CURSORES
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* ============================================================
   CURSOR 1: REPORTE DE INVENTARIO POR PRODUCTO

   Recorre los productos registrados en inventario y muestra
   su stock, ubicación y estado según la cantidad disponible.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_cursor_reporte_inventario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @id_producto VARCHAR(10),
        @nombre_producto VARCHAR(60),
        @tipo_producto VARCHAR(30),
        @stock_actual INT,
        @ubicacion VARCHAR(50),
        @estado_inventario VARCHAR(30);

    DECLARE cursor_inventario_productos CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT 
        p.id_producto,
        p.nombre,
        p.tipo,
        pi.stock_actual,
        pi.ubicacion
    FROM producto p
    INNER JOIN producto_inventario pi
        ON p.id_producto = pi.id_producto
    INNER JOIN inventario i
        ON pi.id_inventario = i.id_inventario
    ORDER BY p.id_producto;

    OPEN cursor_inventario_productos;

    FETCH NEXT FROM cursor_inventario_productos
    INTO @id_producto, @nombre_producto, @tipo_producto, @stock_actual, @ubicacion;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @stock_actual = 0
            SET @estado_inventario = 'SIN STOCK';
        ELSE IF @stock_actual BETWEEN 1 AND 10
            SET @estado_inventario = 'STOCK BAJO';
        ELSE IF @stock_actual BETWEEN 11 AND 30
            SET @estado_inventario = 'STOCK MEDIO';
        ELSE
            SET @estado_inventario = 'STOCK SUFICIENTE';

        PRINT 'Producto: ' + @id_producto + ' - ' + @nombre_producto;
        PRINT 'Tipo: ' + @tipo_producto;
        PRINT 'Stock actual: ' + CAST(@stock_actual AS VARCHAR);
        PRINT 'Ubicacion: ' + ISNULL(@ubicacion, 'Sin ubicacion');
        PRINT 'Estado: ' + @estado_inventario;
        PRINT '--------------------------------------------';

        FETCH NEXT FROM cursor_inventario_productos
        INTO @id_producto, @nombre_producto, @tipo_producto, @stock_actual, @ubicacion;
    END;

    CLOSE cursor_inventario_productos;
    DEALLOCATE cursor_inventario_productos;
END;
GO


/* ============================================================
   CURSOR 2: REPORTE DE VENTAS POR USUARIO

   Recorre cada usuario del sistema y calcula la cantidad
   de ventas registradas, total vendido y nivel de actividad.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_cursor_reporte_ventas_usuarios
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @id_usuario VARCHAR(10),
        @nombre_usuario VARCHAR(120),
        @rol VARCHAR(25),
        @cantidad_ventas INT,
        @total_vendido INT,
        @estado_usuario VARCHAR(40);

    DECLARE cursor_ventas_usuarios CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
        u.id_usuario,
        per.nombre + ' ' + per.apellido1 AS nombre_usuario,
        u.rol
    FROM usuarios u
    INNER JOIN personas per
        ON u.cedula = per.cedula
    ORDER BY u.id_usuario;

    OPEN cursor_ventas_usuarios;

    FETCH NEXT FROM cursor_ventas_usuarios
    INTO @id_usuario, @nombre_usuario, @rol;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT
            @cantidad_ventas = COUNT(v.id_venta),
            @total_vendido = ISNULL(SUM(v.total), 0)
        FROM usuarios u
        LEFT JOIN venta v
            ON u.id_usuario = v.id_usuario
        WHERE u.id_usuario = @id_usuario;

        IF @cantidad_ventas >= 3
            SET @estado_usuario = 'ALTA ACTIVIDAD DE VENTAS';
        ELSE IF @cantidad_ventas BETWEEN 1 AND 2
            SET @estado_usuario = 'ACTIVIDAD NORMAL';
        ELSE
            SET @estado_usuario = 'SIN VENTAS REGISTRADAS';

        PRINT 'Usuario: ' + @id_usuario + ' - ' + @nombre_usuario;
        PRINT 'Rol: ' + @rol;
        PRINT 'Ventas realizadas: ' + CAST(@cantidad_ventas AS VARCHAR);
        PRINT 'Total vendido: ' + CAST(@total_vendido AS VARCHAR);
        PRINT 'Estado: ' + @estado_usuario;
        PRINT '--------------------------------------------';

        FETCH NEXT FROM cursor_ventas_usuarios
        INTO @id_usuario, @nombre_usuario, @rol;
    END;

    CLOSE cursor_ventas_usuarios;
    DEALLOCATE cursor_ventas_usuarios;
END;
GO

/* ============================================================
   PASO 9: CONSULTAS AVANZADAS
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO


/* ============================================================
   CONSULTA 1: RESUMEN DE VENTAS POR USUARIO

   Muestra cuánto ha vendido cada usuario, cuántas ventas
   registró, el promedio por venta y su nivel de actividad.

   Usa:
   JOIN, LEFT JOIN, COUNT, SUM, AVG, CASE, GROUP BY.
   ============================================================ */
SELECT
    u.id_usuario,
    per.nombre + ' ' + per.apellido1 AS nombre_usuario,
    u.rol,
    COUNT(v.id_venta) AS cantidad_ventas,
    ISNULL(SUM(v.total), 0) AS total_vendido,
    ISNULL(AVG(v.total), 0) AS promedio_por_venta,
    CASE
        WHEN COUNT(v.id_venta) >= 3 THEN 'Alta actividad'
        WHEN COUNT(v.id_venta) BETWEEN 1 AND 2 THEN 'Actividad normal'
        ELSE 'Sin ventas'
    END AS clasificacion_usuario
FROM usuarios u
INNER JOIN personas per
    ON u.cedula = per.cedula
LEFT JOIN venta v
    ON u.id_usuario = v.id_usuario
GROUP BY
    u.id_usuario,
    per.nombre,
    per.apellido1,
    u.rol
ORDER BY total_vendido DESC;
GO


/* ============================================================
   CONSULTA 2: PRODUCTOS MÁS VENDIDOS CON INVENTARIO

   Muestra productos vendidos, unidades vendidas, ingresos
   generados y el estado actual del stock.

   Usa:
   CTE, JOIN, SUM, CASE, GROUP BY, ORDER BY.
   ============================================================ */
WITH ventas_producto AS (
    SELECT
        pv.id_producto,
        SUM(pv.cantidad) AS unidades_vendidas,
        SUM(pv.subtotal) AS ingresos_generados
    FROM producto_venta pv
    GROUP BY pv.id_producto
),
stock_producto AS (
    SELECT
        pi.id_producto,
        SUM(pi.stock_actual) AS stock_total
    FROM producto_inventario pi
    GROUP BY pi.id_producto
)
SELECT
    p.id_producto,
    p.nombre AS producto,
    p.tipo,
    p.precio,
    ISNULL(vp.unidades_vendidas, 0) AS unidades_vendidas,
    ISNULL(vp.ingresos_generados, 0) AS ingresos_generados,
    ISNULL(sp.stock_total, 0) AS stock_total,
    CASE
        WHEN ISNULL(sp.stock_total, 0) = 0 THEN 'Sin stock'
        WHEN ISNULL(sp.stock_total, 0) BETWEEN 1 AND 10 THEN 'Stock bajo'
        WHEN ISNULL(sp.stock_total, 0) BETWEEN 11 AND 30 THEN 'Stock medio'
        ELSE 'Stock suficiente'
    END AS estado_inventario
FROM producto p
LEFT JOIN ventas_producto vp
    ON p.id_producto = vp.id_producto
LEFT JOIN stock_producto sp
    ON p.id_producto = sp.id_producto
ORDER BY
    unidades_vendidas DESC,
    ingresos_generados DESC;
GO


/* ============================================================
   CONSULTA 3: HISTORIAL DE CLIENTES, MASCOTAS Y CITAS

   Muestra un resumen del historial veterinario de cada cliente,
   incluyendo mascotas, citas y procedimientos registrados.

   Usa:
   Múltiples LEFT JOIN, COUNT DISTINCT, MAX, GROUP BY, CASE.
   ============================================================ */
SELECT
    cl.id_cliente,
    per.cedula,
    per.nombre + ' ' + per.apellido1 AS nombre_cliente,
    COUNT(DISTINCT m.id_mascota) AS cantidad_mascotas,
    COUNT(DISTINCT c.id_cita) AS cantidad_citas,
    COUNT(DISTINCT pr.id_procedimiento) AS cantidad_procedimientos,
    MAX(c.fecha_cita) AS ultima_cita,
    CASE
        WHEN COUNT(DISTINCT c.id_cita) = 0 THEN 'Sin citas registradas'
        WHEN COUNT(DISTINCT pr.id_procedimiento) = 0 THEN 'Tiene citas sin procedimientos'
        ELSE 'Con historial veterinario'
    END AS estado_cliente
FROM clientes cl
INNER JOIN personas per
    ON cl.cedula = per.cedula
LEFT JOIN mascotas m
    ON cl.id_cliente = m.id_cliente
LEFT JOIN cita c
    ON m.id_mascota = c.id_mascota
LEFT JOIN procedimiento pr
    ON c.id_cita = pr.id_cita
GROUP BY
    cl.id_cliente,
    per.cedula,
    per.nombre,
    per.apellido1
ORDER BY
    cantidad_citas DESC,
    cantidad_procedimientos DESC;
GO


/* ============================================================
   CONSULTA 4: PEDIDOS CON PRODUCTOS Y TOTAL ESTIMADO

   Muestra los pedidos, cliente, tipo de entrega, productos
   incluidos y total estimado.

   Nota:
   Como producto_pedido no guarda cantidad, se calcula tomando
   una unidad por producto.

   Usa:
   JOIN, STRING_AGG, SUM, GROUP BY, CASE, HAVING.
   ============================================================ */
SELECT
    pe.id_pedido,
    cl.id_cliente,
    per.nombre + ' ' + per.apellido1 AS nombre_cliente,
    pe.tipo_entrega,
    pe.estado,
    STRING_AGG(p.nombre, ', ') AS productos_solicitados,
    COUNT(p.id_producto) AS cantidad_productos_distintos,
    SUM(p.precio) AS total_estimado,
    CASE
        WHEN pe.estado = 'Pendiente' THEN 'Requiere preparacion'
        WHEN pe.estado = 'Preparacion' THEN 'En proceso'
        WHEN pe.estado = 'Entregado' THEN 'Finalizado'
        ELSE 'Cancelado'
    END AS estado_operativo
FROM pedido pe
INNER JOIN clientes cl
    ON pe.id_cliente = cl.id_cliente
INNER JOIN personas per
    ON cl.cedula = per.cedula
INNER JOIN producto_pedido pp
    ON pe.id_pedido = pp.id_pedido
INNER JOIN producto p
    ON pp.id_producto = p.id_producto
GROUP BY
    pe.id_pedido,
    cl.id_cliente,
    per.nombre,
    per.apellido1,
    pe.tipo_entrega,
    pe.estado
HAVING COUNT(p.id_producto) >= 1
ORDER BY
    total_estimado DESC;
GO


/* ============================================================
   CONSULTA 5: RESUMEN DE PAGOS Y VENTAS POR ESTADO

   Muestra cuánto dinero hay aprobado, pendiente o rechazado,
   junto con la cantidad de ventas asociadas.

   Usa:
   CTE, JOIN, COUNT, SUM, CASE y agrupación.
   ============================================================ */
WITH resumen_pagos AS (
    SELECT
        pa.estado AS estado_pago,
        COUNT(pa.id_pago) AS cantidad_pagos,
        SUM(pa.monto) AS monto_total_pagado,
        COUNT(v.id_venta) AS ventas_asociadas,
        SUM(v.total) AS total_ventas_asociadas
    FROM pago pa
    INNER JOIN venta v
        ON pa.id_venta = v.id_venta
    GROUP BY pa.estado
)
SELECT
    estado_pago,
    cantidad_pagos,
    ventas_asociadas,
    monto_total_pagado,
    total_ventas_asociadas,
    CASE
        WHEN estado_pago = 'Aprobado' THEN 'Ingreso confirmado'
        WHEN estado_pago = 'Pendiente' THEN 'Ingreso por confirmar'
        ELSE 'Pago no valido'
    END AS interpretacion,
    CASE
        WHEN total_ventas_asociadas = 0 THEN 0
        ELSE (monto_total_pagado * 100) / total_ventas_asociadas
    END AS porcentaje_cubierto
FROM resumen_pagos
ORDER BY monto_total_pagado DESC;
GO

/* ============================================================
   PASO 10: PROCEDIMIENTOS CRUD POR TABLA
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO

/* ============================================================
   CRUD: PERSONAS
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_personas_insertar
    @cedula T_CEDULA,
    @nombre T_NOMBRE,
    @apellido1 T_APELLIDO,
    @apellido2 T_APELLIDO = NULL,
    @fecha_nacimiento DATE,
    @direccion T_DIRECCION = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO personas (
        cedula, nombre, apellido1, apellido2, fecha_nacimiento, direccion
    )
    VALUES (
        @cedula, @nombre, @apellido1, @apellido2, @fecha_nacimiento, @direccion
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_personas_modificar
    @cedula T_CEDULA,
    @nombre T_NOMBRE,
    @apellido1 T_APELLIDO,
    @apellido2 T_APELLIDO = NULL,
    @fecha_nacimiento DATE,
    @direccion T_DIRECCION = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE personas
    SET nombre = @nombre,
        apellido1 = @apellido1,
        apellido2 = @apellido2,
        fecha_nacimiento = @fecha_nacimiento,
        direccion = @direccion
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_personas_eliminar
    @cedula T_CEDULA
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM personas
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_personas_consultar
    @cedula T_CEDULA = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        cedula,
        nombre,
        apellido1,
        apellido2,
        fecha_nacimiento,
        DATEDIFF(YEAR, fecha_nacimiento, GETDATE()) AS edad_aproximada,
        direccion
    FROM personas
    WHERE @cedula IS NULL OR cedula = @cedula;
END;
GO


/* ============================================================
   CRUD: CLIENTES
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_clientes_insertar
    @cedula T_CEDULA,
    @id_cliente T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO clientes (cedula, id_cliente)
    VALUES (@cedula, @id_cliente);
END;
GO

CREATE OR ALTER PROCEDURE usp_clientes_modificar
    @cedula T_CEDULA,
    @id_cliente T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE clientes
    SET id_cliente = @id_cliente
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_clientes_eliminar
    @cedula T_CEDULA
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM clientes
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_clientes_consultar
    @id_cliente T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.cedula,
        c.id_cliente,
        p.nombre,
        p.apellido1,
        p.apellido2,
        p.direccion
    FROM clientes c
    INNER JOIN personas p
        ON c.cedula = p.cedula
    WHERE @id_cliente IS NULL OR c.id_cliente = @id_cliente;
END;
GO


/* ============================================================
   CRUD: USUARIOS
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_usuarios_insertar
    @cedula T_CEDULA,
    @id_usuario T_ID_INTERNO,
    @rol T_ROL_USUARIO,
    @contrasena T_CONTRASENA
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO usuarios (cedula, id_usuario, rol, contrasena)
    VALUES (@cedula, @id_usuario, @rol, @contrasena);
END;
GO

CREATE OR ALTER PROCEDURE usp_usuarios_modificar
    @cedula T_CEDULA,
    @id_usuario T_ID_INTERNO,
    @rol T_ROL_USUARIO,
    @contrasena T_CONTRASENA
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE usuarios
    SET id_usuario = @id_usuario,
        rol = @rol,
        contrasena = @contrasena
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_usuarios_eliminar
    @cedula T_CEDULA
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM usuarios
    WHERE cedula = @cedula;
END;
GO

CREATE OR ALTER PROCEDURE usp_usuarios_consultar
    @id_usuario T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.cedula,
        u.id_usuario,
        p.nombre,
        p.apellido1,
        u.rol
    FROM usuarios u
    INNER JOIN personas p
        ON u.cedula = p.cedula
    WHERE @id_usuario IS NULL OR u.id_usuario = @id_usuario;
END;
GO


/* ============================================================
   CRUD: TELEFONOS_PERSONAS
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_telefonos_personas_insertar
    @cedula T_CEDULA,
    @telefono T_TELEFONO
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO telefonos_personas (cedula, telefono)
    VALUES (@cedula, @telefono);
END;
GO

CREATE OR ALTER PROCEDURE usp_telefonos_personas_modificar
    @cedula T_CEDULA,
    @telefono_actual T_TELEFONO,
    @telefono_nuevo T_TELEFONO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE telefonos_personas
    SET telefono = @telefono_nuevo
    WHERE cedula = @cedula
      AND telefono = @telefono_actual;
END;
GO

CREATE OR ALTER PROCEDURE usp_telefonos_personas_eliminar
    @cedula T_CEDULA,
    @telefono T_TELEFONO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM telefonos_personas
    WHERE cedula = @cedula
      AND telefono = @telefono;
END;
GO

CREATE OR ALTER PROCEDURE usp_telefonos_personas_consultar
    @cedula T_CEDULA = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        tp.cedula,
        p.nombre,
        p.apellido1,
        tp.telefono
    FROM telefonos_personas tp
    INNER JOIN personas p
        ON tp.cedula = p.cedula
    WHERE @cedula IS NULL OR tp.cedula = @cedula;
END;
GO


/* ============================================================
   CRUD: MASCOTAS
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_mascotas_insertar
    @id_mascota T_ID_INTERNO,
    @id_cliente T_ID_INTERNO,
    @nombre T_NOMBRE_MASCOTA,
    @especie T_ESPECIE,
    @peso INT = NULL,
    @genero T_GENERO_MASCOTA = NULL,
    @fecha_nacimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO mascotas (
        id_mascota, id_cliente, nombre, especie, peso, genero, fecha_nacimiento
    )
    VALUES (
        @id_mascota, @id_cliente, @nombre, @especie, @peso, @genero, @fecha_nacimiento
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_mascotas_modificar
    @id_mascota T_ID_INTERNO,
    @id_cliente T_ID_INTERNO,
    @nombre T_NOMBRE_MASCOTA,
    @especie T_ESPECIE,
    @peso INT = NULL,
    @genero T_GENERO_MASCOTA = NULL,
    @fecha_nacimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE mascotas
    SET id_cliente = @id_cliente,
        nombre = @nombre,
        especie = @especie,
        peso = @peso,
        genero = @genero,
        fecha_nacimiento = @fecha_nacimiento
    WHERE id_mascota = @id_mascota;
END;
GO

CREATE OR ALTER PROCEDURE usp_mascotas_eliminar
    @id_mascota T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM mascotas
    WHERE id_mascota = @id_mascota;
END;
GO

CREATE OR ALTER PROCEDURE usp_mascotas_consultar
    @id_mascota T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id_mascota,
        m.id_cliente,
        p.nombre + ' ' + p.apellido1 AS nombre_cliente,
        m.nombre AS nombre_mascota,
        m.especie,
        m.peso,
        m.genero,
        m.fecha_nacimiento,
        DATEDIFF(YEAR, m.fecha_nacimiento, GETDATE()) AS edad_aproximada
    FROM mascotas m
    INNER JOIN clientes c
        ON m.id_cliente = c.id_cliente
    INNER JOIN personas p
        ON c.cedula = p.cedula
    WHERE @id_mascota IS NULL OR m.id_mascota = @id_mascota;
END;
GO


/* ============================================================
   CRUD: PRODUCTO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_producto_insertar
    @id_producto T_ID_INTERNO,
    @nombre T_NOMBRE_PRODUCTO,
    @tipo T_TIPO_PRODUCTO,
    @precio T_MONTO,
    @fecha_registro DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO producto (id_producto, nombre, tipo, precio, fecha_registro)
    VALUES (
        @id_producto,
        @nombre,
        @tipo,
        @precio,
        ISNULL(@fecha_registro, CAST(GETDATE() AS DATE))
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_modificar
    @id_producto T_ID_INTERNO,
    @nombre T_NOMBRE_PRODUCTO,
    @tipo T_TIPO_PRODUCTO,
    @precio T_MONTO,
    @fecha_registro DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE producto
    SET nombre = @nombre,
        tipo = @tipo,
        precio = @precio,
        fecha_registro = @fecha_registro
    WHERE id_producto = @id_producto;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_eliminar
    @id_producto T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM producto
    WHERE id_producto = @id_producto;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_consultar
    @id_producto T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_producto,
        nombre,
        tipo,
        precio,
        fecha_registro
    FROM producto
    WHERE @id_producto IS NULL OR id_producto = @id_producto;
END;
GO

/* ============================================================
   CRUD: VENTA
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_venta_insertar
    @id_venta T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @fecha_venta DATE = NULL,
    @total T_MONTO = 0
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO venta (id_venta, id_usuario, fecha_venta, total)
    VALUES (
        @id_venta,
        @id_usuario,
        ISNULL(@fecha_venta, CAST(GETDATE() AS DATE)),
        @total
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_venta_modificar
    @id_venta T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @fecha_venta DATE,
    @total T_MONTO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE venta
    SET id_usuario = @id_usuario,
        fecha_venta = @fecha_venta,
        total = @total
    WHERE id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE usp_venta_eliminar
    @id_venta T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM venta
    WHERE id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE usp_venta_consultar
    @id_venta T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.id_venta,
        v.id_usuario,
        p.nombre + ' ' + p.apellido1 AS usuario_registra,
        v.fecha_venta,
        v.total
    FROM venta v
    INNER JOIN usuarios u
        ON v.id_usuario = u.id_usuario
    INNER JOIN personas p
        ON u.cedula = p.cedula
    WHERE @id_venta IS NULL OR v.id_venta = @id_venta;
END;
GO


/* ============================================================
   CRUD: PAGO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_pago_insertar
    @id_pago T_ID_INTERNO,
    @id_venta T_ID_INTERNO,
    @monto T_MONTO,
    @metodo_pago T_METODO_PAGO,
    @estado T_ESTADO_PAGO = 'Pendiente',
    @fecha_pago DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO pago (
        id_pago, id_venta, monto, metodo_pago, estado, fecha_pago
    )
    VALUES (
        @id_pago,
        @id_venta,
        @monto,
        @metodo_pago,
        @estado,
        ISNULL(@fecha_pago, CAST(GETDATE() AS DATE))
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_pago_modificar
    @id_pago T_ID_INTERNO,
    @id_venta T_ID_INTERNO,
    @monto T_MONTO,
    @metodo_pago T_METODO_PAGO,
    @estado T_ESTADO_PAGO,
    @fecha_pago DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pago
    SET id_venta = @id_venta,
        monto = @monto,
        metodo_pago = @metodo_pago,
        estado = @estado,
        fecha_pago = @fecha_pago
    WHERE id_pago = @id_pago;
END;
GO

CREATE OR ALTER PROCEDURE usp_pago_eliminar
    @id_pago T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM pago
    WHERE id_pago = @id_pago;
END;
GO

CREATE OR ALTER PROCEDURE usp_pago_consultar
    @id_pago T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pa.id_pago,
        pa.id_venta,
        pa.monto,
        pa.metodo_pago,
        pa.estado,
        pa.fecha_pago,
        v.total AS total_venta
    FROM pago pa
    INNER JOIN venta v
        ON pa.id_venta = v.id_venta
    WHERE @id_pago IS NULL OR pa.id_pago = @id_pago;
END;
GO


/* ============================================================
   CRUD: PEDIDO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_pedido_insertar
    @id_pedido T_ID_INTERNO,
    @id_cliente T_ID_INTERNO,
    @tipo_entrega T_TIPO_ENTREGA,
    @estado T_ESTADO_PEDIDO = 'Pendiente'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO pedido (id_pedido, id_cliente, tipo_entrega, estado)
    VALUES (@id_pedido, @id_cliente, @tipo_entrega, @estado);
END;
GO

CREATE OR ALTER PROCEDURE usp_pedido_modificar
    @id_pedido T_ID_INTERNO,
    @id_cliente T_ID_INTERNO,
    @tipo_entrega T_TIPO_ENTREGA,
    @estado T_ESTADO_PEDIDO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pedido
    SET id_cliente = @id_cliente,
        tipo_entrega = @tipo_entrega,
        estado = @estado
    WHERE id_pedido = @id_pedido;
END;
GO

CREATE OR ALTER PROCEDURE usp_pedido_eliminar
    @id_pedido T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM pedido
    WHERE id_pedido = @id_pedido;
END;
GO

CREATE OR ALTER PROCEDURE usp_pedido_consultar
    @id_pedido T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pe.id_pedido,
        pe.id_cliente,
        p.nombre + ' ' + p.apellido1 AS nombre_cliente,
        pe.tipo_entrega,
        pe.estado
    FROM pedido pe
    INNER JOIN clientes c
        ON pe.id_cliente = c.id_cliente
    INNER JOIN personas p
        ON c.cedula = p.cedula
    WHERE @id_pedido IS NULL OR pe.id_pedido = @id_pedido;
END;
GO


/* ============================================================
   CRUD: CITA
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_cita_insertar
    @id_cita T_ID_INTERNO,
    @id_mascota T_ID_INTERNO,
    @fecha_cita DATE,
    @hora TIME,
    @motivo T_TEXTO_MEDIO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO cita (id_cita, id_mascota, fecha_cita, hora, motivo)
    VALUES (@id_cita, @id_mascota, @fecha_cita, @hora, @motivo);
END;
GO

CREATE OR ALTER PROCEDURE usp_cita_modificar
    @id_cita T_ID_INTERNO,
    @id_mascota T_ID_INTERNO,
    @fecha_cita DATE,
    @hora TIME,
    @motivo T_TEXTO_MEDIO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE cita
    SET id_mascota = @id_mascota,
        fecha_cita = @fecha_cita,
        hora = @hora,
        motivo = @motivo
    WHERE id_cita = @id_cita;
END;
GO

CREATE OR ALTER PROCEDURE usp_cita_eliminar
    @id_cita T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM cita
    WHERE id_cita = @id_cita;
END;
GO

CREATE OR ALTER PROCEDURE usp_cita_consultar
    @id_cita T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id_cita,
        c.fecha_cita,
        c.hora,
        c.motivo,
        m.id_mascota,
        m.nombre AS nombre_mascota,
        m.especie
    FROM cita c
    INNER JOIN mascotas m
        ON c.id_mascota = m.id_mascota
    WHERE @id_cita IS NULL OR c.id_cita = @id_cita;
END;
GO


/* ============================================================
   CRUD: PROCEDIMIENTO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_procedimiento_insertar
    @id_procedimiento T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @id_cita T_ID_INTERNO,
    @descripcion T_TEXTO_MEDIO,
    @fecha_procedimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO procedimiento (
        id_procedimiento, id_usuario, id_cita, descripcion, fecha_procedimiento
    )
    VALUES (
        @id_procedimiento,
        @id_usuario,
        @id_cita,
        @descripcion,
        ISNULL(@fecha_procedimiento, CAST(GETDATE() AS DATE))
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_procedimiento_modificar
    @id_procedimiento T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @id_cita T_ID_INTERNO,
    @descripcion T_TEXTO_MEDIO,
    @fecha_procedimiento DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE procedimiento
    SET id_usuario = @id_usuario,
        id_cita = @id_cita,
        descripcion = @descripcion,
        fecha_procedimiento = @fecha_procedimiento
    WHERE id_procedimiento = @id_procedimiento;
END;
GO

CREATE OR ALTER PROCEDURE usp_procedimiento_eliminar
    @id_procedimiento T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM procedimiento
    WHERE id_procedimiento = @id_procedimiento;
END;
GO

CREATE OR ALTER PROCEDURE usp_procedimiento_consultar
    @id_procedimiento T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pr.id_procedimiento,
        pr.id_usuario,
        per.nombre + ' ' + per.apellido1 AS usuario_registra,
        pr.id_cita,
        pr.descripcion,
        pr.fecha_procedimiento
    FROM procedimiento pr
    INNER JOIN usuarios u
        ON pr.id_usuario = u.id_usuario
    INNER JOIN personas per
        ON u.cedula = per.cedula
    WHERE @id_procedimiento IS NULL OR pr.id_procedimiento = @id_procedimiento;
END;
GO

/* ============================================================
   CRUD: INVENTARIO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_inventario_insertar
    @id_inventario T_ID_INTERNO,
    @fecha_inventario DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO inventario (id_inventario, fecha_inventario)
    VALUES (@id_inventario, ISNULL(@fecha_inventario, CAST(GETDATE() AS DATE)));
END;
GO

CREATE OR ALTER PROCEDURE usp_inventario_modificar
    @id_inventario T_ID_INTERNO,
    @fecha_inventario DATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE inventario
    SET fecha_inventario = @fecha_inventario
    WHERE id_inventario = @id_inventario;
END;
GO

CREATE OR ALTER PROCEDURE usp_inventario_eliminar
    @id_inventario T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM inventario
    WHERE id_inventario = @id_inventario;
END;
GO

CREATE OR ALTER PROCEDURE usp_inventario_consultar
    @id_inventario T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_inventario,
        fecha_inventario
    FROM inventario
    WHERE @id_inventario IS NULL OR id_inventario = @id_inventario;
END;
GO


/* ============================================================
   CRUD: PRODUCTO_VENTA
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_producto_venta_insertar
    @id_producto T_ID_INTERNO,
    @id_venta T_ID_INTERNO,
    @cantidad T_CANTIDAD,
    @subtotal T_MONTO
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO producto_venta (id_producto, id_venta, cantidad, subtotal)
    VALUES (@id_producto, @id_venta, @cantidad, @subtotal);
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_venta_modificar
    @id_producto T_ID_INTERNO,
    @id_venta T_ID_INTERNO,
    @cantidad T_CANTIDAD,
    @subtotal T_MONTO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE producto_venta
    SET cantidad = @cantidad,
        subtotal = @subtotal
    WHERE id_producto = @id_producto
      AND id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_venta_eliminar
    @id_producto T_ID_INTERNO,
    @id_venta T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM producto_venta
    WHERE id_producto = @id_producto
      AND id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_venta_consultar
    @id_venta T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pv.id_producto,
        p.nombre AS producto,
        pv.id_venta,
        pv.cantidad,
        pv.subtotal
    FROM producto_venta pv
    INNER JOIN producto p
        ON pv.id_producto = p.id_producto
    WHERE @id_venta IS NULL OR pv.id_venta = @id_venta;
END;
GO


/* ============================================================
   CRUD: PRODUCTO_INVENTARIO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_producto_inventario_insertar
    @id_producto T_ID_INTERNO,
    @id_inventario T_ID_INTERNO,
    @stock_actual T_STOCK,
    @ubicacion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO producto_inventario (
        id_producto, id_inventario, stock_actual, ubicacion
    )
    VALUES (
        @id_producto, @id_inventario, @stock_actual, @ubicacion
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_inventario_modificar
    @id_producto T_ID_INTERNO,
    @id_inventario T_ID_INTERNO,
    @stock_actual T_STOCK,
    @ubicacion VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE producto_inventario
    SET stock_actual = @stock_actual,
        ubicacion = @ubicacion
    WHERE id_producto = @id_producto
      AND id_inventario = @id_inventario;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_inventario_eliminar
    @id_producto T_ID_INTERNO,
    @id_inventario T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM producto_inventario
    WHERE id_producto = @id_producto
      AND id_inventario = @id_inventario;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_inventario_consultar
    @id_producto T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pi.id_producto,
        p.nombre AS producto,
        pi.id_inventario,
        i.fecha_inventario,
        pi.stock_actual,
        pi.ubicacion
    FROM producto_inventario pi
    INNER JOIN producto p
        ON pi.id_producto = p.id_producto
    INNER JOIN inventario i
        ON pi.id_inventario = i.id_inventario
    WHERE @id_producto IS NULL OR pi.id_producto = @id_producto;
END;
GO


/* ============================================================
   CRUD: PRODUCTO_PEDIDO
   ============================================================ */

CREATE OR ALTER PROCEDURE usp_producto_pedido_insertar
    @id_producto T_ID_INTERNO,
    @id_pedido T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO producto_pedido (id_producto, id_pedido)
    VALUES (@id_producto, @id_pedido);
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_pedido_modificar
    @id_producto_actual T_ID_INTERNO,
    @id_pedido_actual T_ID_INTERNO,
    @id_producto_nuevo T_ID_INTERNO,
    @id_pedido_nuevo T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE producto_pedido
    SET id_producto = @id_producto_nuevo,
        id_pedido = @id_pedido_nuevo
    WHERE id_producto = @id_producto_actual
      AND id_pedido = @id_pedido_actual;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_pedido_eliminar
    @id_producto T_ID_INTERNO,
    @id_pedido T_ID_INTERNO
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM producto_pedido
    WHERE id_producto = @id_producto
      AND id_pedido = @id_pedido;
END;
GO

CREATE OR ALTER PROCEDURE usp_producto_pedido_consultar
    @id_pedido T_ID_INTERNO = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pp.id_producto,
        p.nombre AS producto,
        pp.id_pedido,
        pe.tipo_entrega,
        pe.estado
    FROM producto_pedido pp
    INNER JOIN producto p
        ON pp.id_producto = p.id_producto
    INNER JOIN pedido pe
        ON pp.id_pedido = pe.id_pedido
    WHERE @id_pedido IS NULL OR pp.id_pedido = @id_pedido;
END;
GO

/* ============================================================
   PASO 11: PROCEDIMIENTOS CON TRANSACCIONES
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO


/* ============================================================
   TRANSACCIÓN 1: REGISTRAR VENTA COMPLETA

   Inserta una venta, registra el producto vendido y registra
   el pago asociado. Además, los triggers creados anteriormente
   actualizan el total de la venta y descuentan stock.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_transaccion_registrar_venta_completa
    @id_venta T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @id_producto T_ID_INTERNO,
    @cantidad T_CANTIDAD,
    @id_pago T_ID_INTERNO,
    @metodo_pago T_METODO_PAGO,
    @estado_pago T_ESTADO_PAGO = 'Aprobado',
    @fecha_venta DATE = NULL,
    @fecha_pago DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @precio INT;
    DECLARE @subtotal INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @precio = precio
        FROM producto
        WHERE id_producto = @id_producto;

        IF @precio IS NULL
        BEGIN
            RAISERROR('El producto indicado no existe.', 16, 1);
        END;

        IF @cantidad <= 0
        BEGIN
            RAISERROR('La cantidad debe ser mayor que cero.', 16, 1);
        END;

        SET @subtotal = @precio * @cantidad;

        INSERT INTO venta (id_venta, id_usuario, fecha_venta, total)
        VALUES (
            @id_venta,
            @id_usuario,
            ISNULL(@fecha_venta, CAST(GETDATE() AS DATE)),
            0
        );

        INSERT INTO producto_venta (id_producto, id_venta, cantidad, subtotal)
        VALUES (@id_producto, @id_venta, @cantidad, @subtotal);

        INSERT INTO pago (id_pago, id_venta, monto, metodo_pago, estado, fecha_pago)
        VALUES (
            @id_pago,
            @id_venta,
            @subtotal,
            @metodo_pago,
            @estado_pago,
            ISNULL(@fecha_pago, CAST(GETDATE() AS DATE))
        );

        COMMIT TRANSACTION;

        SELECT 
            'Venta completa registrada correctamente.' AS mensaje,
            @id_venta AS id_venta,
            @id_pago AS id_pago,
            @subtotal AS monto_total;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_transaccion;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   TRANSACCIÓN 2: REGISTRAR PEDIDO COMPLETO

   Inserta un pedido y asocia un producto al pedido.
   La tabla producto_pedido representa la relación N:M entre
   pedidos y productos.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_transaccion_registrar_pedido_completo
    @id_pedido T_ID_INTERNO,
    @id_cliente T_ID_INTERNO,
    @id_producto T_ID_INTERNO,
    @tipo_entrega T_TIPO_ENTREGA,
    @estado T_ESTADO_PEDIDO = 'Pendiente'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM clientes WHERE id_cliente = @id_cliente
        )
        BEGIN
            RAISERROR('El cliente indicado no existe.', 16, 1);
        END;

        IF NOT EXISTS (
            SELECT 1 FROM producto WHERE id_producto = @id_producto
        )
        BEGIN
            RAISERROR('El producto indicado no existe.', 16, 1);
        END;

        INSERT INTO pedido (id_pedido, id_cliente, tipo_entrega, estado)
        VALUES (@id_pedido, @id_cliente, @tipo_entrega, @estado);

        INSERT INTO producto_pedido (id_producto, id_pedido)
        VALUES (@id_producto, @id_pedido);

        COMMIT TRANSACTION;

        SELECT 
            'Pedido completo registrado correctamente.' AS mensaje,
            @id_pedido AS id_pedido,
            @id_cliente AS id_cliente,
            @id_producto AS id_producto;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_transaccion;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   TRANSACCIÓN 3: REGISTRAR CITA CON PROCEDIMIENTO

   Inserta una cita veterinaria y registra inmediatamente
   un procedimiento asociado a esa cita.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_transaccion_registrar_cita_con_procedimiento
    @id_cita T_ID_INTERNO,
    @id_mascota T_ID_INTERNO,
    @fecha_cita DATE,
    @hora TIME,
    @motivo T_TEXTO_MEDIO,
    @id_procedimiento T_ID_INTERNO,
    @id_usuario T_ID_INTERNO,
    @descripcion T_TEXTO_MEDIO,
    @fecha_procedimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM mascotas WHERE id_mascota = @id_mascota
        )
        BEGIN
            RAISERROR('La mascota indicada no existe.', 16, 1);
        END;

        IF NOT EXISTS (
            SELECT 1 FROM usuarios WHERE id_usuario = @id_usuario
        )
        BEGIN
            RAISERROR('El usuario indicado no existe.', 16, 1);
        END;

        INSERT INTO cita (id_cita, id_mascota, fecha_cita, hora, motivo)
        VALUES (@id_cita, @id_mascota, @fecha_cita, @hora, @motivo);

        INSERT INTO procedimiento (
            id_procedimiento,
            id_usuario,
            id_cita,
            descripcion,
            fecha_procedimiento
        )
        VALUES (
            @id_procedimiento,
            @id_usuario,
            @id_cita,
            @descripcion,
            ISNULL(@fecha_procedimiento, @fecha_cita)
        );

        COMMIT TRANSACTION;

        SELECT
            'Cita y procedimiento registrados correctamente.' AS mensaje,
            @id_cita AS id_cita,
            @id_procedimiento AS id_procedimiento;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_transaccion;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   TRANSACCIÓN 4: REGISTRAR PRODUCTO CON INVENTARIO

   Inserta un producto nuevo, crea o reutiliza un registro de
   inventario y asocia el producto con su stock inicial.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_transaccion_registrar_producto_con_inventario
    @id_producto T_ID_INTERNO,
    @nombre T_NOMBRE_PRODUCTO,
    @tipo T_TIPO_PRODUCTO,
    @precio T_MONTO,
    @id_inventario T_ID_INTERNO,
    @fecha_inventario DATE = NULL,
    @stock_actual T_STOCK,
    @ubicacion VARCHAR(50) = NULL,
    @fecha_registro DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @precio < 0
        BEGIN
            RAISERROR('El precio no puede ser negativo.', 16, 1);
        END;

        IF @stock_actual < 0
        BEGIN
            RAISERROR('El stock no puede ser negativo.', 16, 1);
        END;

        INSERT INTO producto (
            id_producto,
            nombre,
            tipo,
            precio,
            fecha_registro
        )
        VALUES (
            @id_producto,
            @nombre,
            @tipo,
            @precio,
            ISNULL(@fecha_registro, CAST(GETDATE() AS DATE))
        );

        IF NOT EXISTS (
            SELECT 1 FROM inventario WHERE id_inventario = @id_inventario
        )
        BEGIN
            INSERT INTO inventario (id_inventario, fecha_inventario)
            VALUES (
                @id_inventario,
                ISNULL(@fecha_inventario, CAST(GETDATE() AS DATE))
            );
        END;

        INSERT INTO producto_inventario (
            id_producto,
            id_inventario,
            stock_actual,
            ubicacion
        )
        VALUES (
            @id_producto,
            @id_inventario,
            @stock_actual,
            @ubicacion
        );

        COMMIT TRANSACTION;

        SELECT
            'Producto con inventario registrado correctamente.' AS mensaje,
            @id_producto AS id_producto,
            @id_inventario AS id_inventario,
            @stock_actual AS stock_inicial;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_transaccion;
        THROW;
    END CATCH;
END;
GO


/* ============================================================
   TRANSACCIÓN 5: PROCESAR PAGO DE VENTA

   Registra o actualiza el pago asociado a una venta.
   Si el pago ya existe para la venta, se actualiza.
   Si no existe, se crea un nuevo pago.
   ============================================================ */
CREATE OR ALTER PROCEDURE usp_transaccion_procesar_pago_venta
    @id_pago T_ID_INTERNO,
    @id_venta T_ID_INTERNO,
    @monto T_MONTO,
    @metodo_pago T_METODO_PAGO,
    @fecha_pago DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @total_venta INT;
    DECLARE @estado_pago T_ESTADO_PAGO;
    DECLARE @id_pago_existente VARCHAR(10);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @total_venta = total
        FROM venta
        WHERE id_venta = @id_venta;

        IF @total_venta IS NULL
        BEGIN
            RAISERROR('La venta indicada no existe.', 16, 1);
        END;

        IF @monto <= 0
        BEGIN
            RAISERROR('El monto del pago debe ser mayor que cero.', 16, 1);
        END;

        IF @monto >= @total_venta
            SET @estado_pago = 'Aprobado';
        ELSE
            SET @estado_pago = 'Pendiente';

        SELECT @id_pago_existente = id_pago
        FROM pago
        WHERE id_venta = @id_venta;

        IF @id_pago_existente IS NULL
        BEGIN
            INSERT INTO pago (
                id_pago,
                id_venta,
                monto,
                metodo_pago,
                estado,
                fecha_pago
            )
            VALUES (
                @id_pago,
                @id_venta,
                @monto,
                @metodo_pago,
                @estado_pago,
                ISNULL(@fecha_pago, CAST(GETDATE() AS DATE))
            );
        END
        ELSE
        BEGIN
            UPDATE pago
            SET monto = @monto,
                metodo_pago = @metodo_pago,
                estado = @estado_pago,
                fecha_pago = ISNULL(@fecha_pago, CAST(GETDATE() AS DATE))
            WHERE id_venta = @id_venta;
        END;

        COMMIT TRANSACTION;

        SELECT
            'Pago procesado correctamente.' AS mensaje,
            @id_venta AS id_venta,
            @monto AS monto_pagado,
            @estado_pago AS estado_pago;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS error_transaccion;
        THROW;
    END CATCH;
END;
GO

/* ============================================================
   PASO 12: PRUEBAS GENERALES

   Tabla resumen de pruebas realizadas
   ============================================================

   | N° | Prueba realizada                                      | Objetivo principal |
   |----|--------------------------------------------------------|-------------------|
   | 1  | Verificar cantidad total de procedimientos             | Confirmar el total de procedimientos almacenados creados. |
   | 2  | Resumen de procedimientos por categoría                | Clasificar procedimientos CRUD, cursores y transacciones. |
   | 3  | Listar todos los procedimientos                        | Mostrar todos los procedimientos almacenados existentes. |
   | 4  | Listar procedimientos clasificados                     | Ver cada procedimiento junto con su categoría. |
   | 5  | Listar solo procedimientos CRUD                        | Confirmar los procedimientos de inserción, modificación, eliminación y consulta. |
   | 6  | Listar solo procedimientos de cursores                 | Confirmar los procedimientos que ejecutan cursores. |
   | 7  | Listar solo procedimientos con transacciones           | Confirmar los 5 procedimientos transaccionales. |
   | 8  | Verificar tablas creadas                               | Confirmar la cantidad y nombres de las tablas del modelo. |
   | 9  | Verificar tipos de datos personalizados                | Confirmar los dominios personalizados creados. |
   | 10 | Verificar reglas creadas                               | Confirmar las reglas asociadas a los tipos personalizados. |
   | 11 | Verificar llaves primarias                             | Confirmar las claves primarias de las tablas. |
   | 12 | Verificar llaves foráneas                              | Confirmar las relaciones entre tablas. |
   | 13 | Verificar restricciones CHECK                          | Confirmar las validaciones de dominio en las tablas. |
   | 14 | Verificar valores por defecto                          | Confirmar las restricciones DEFAULT configuradas. |
   | 15 | Verificar índices creados                              | Confirmar los índices solicitados en el proyecto. |
   | 16 | Verificar vistas creadas                               | Confirmar la existencia de las vistas. |
   | 17 | Consultar vistas                                       | Validar que las vistas devuelvan información correctamente. |
   | 18 | Verificar triggers creados                             | Confirmar la existencia y estado de los triggers. |
   | 19 | Verificar cantidad de registros por tabla              | Confirmar que los datos de prueba fueron insertados. |
   | 20 | Ejecutar procedimientos de cursores                    | Validar el funcionamiento de los cursores. |
   | 21 | Probar trigger de límite de teléfonos                  | Confirmar que no se permitan más de 3 teléfonos por persona. |
   | 22 | Probar trigger de total de venta y descuento de stock  | Confirmar actualización automática de venta e inventario. |
   | 23 | Probar transacción de registrar venta completa         | Validar venta, detalle de venta y pago en una misma transacción. |
   | 24 | Probar transacción de registrar pedido completo        | Validar pedido y asociación con producto. |
   | 25 | Probar transacción de cita con procedimiento           | Validar cita veterinaria y procedimiento asociado. |
   | 26 | Probar transacción de producto con inventario          | Validar producto, inventario y stock inicial. |
   | 27 | Probar transacción de procesar pago de venta           | Validar registro o actualización del pago de una venta. |

   Nota:
   Algunas pruebas utilizan ROLLBACK para validar el funcionamiento
   sin dejar datos adicionales en la base de datos.
   ============================================================ */

USE BD_AgroveterinariaLaYunta;
GO


/* ============================================================
   PRUEBA 1: VERIFICAR CANTIDAD DE PROCEDIMIENTOS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_total_procedimientos
FROM sys.procedures;
GO


/* ============================================================
   PRUEBA 2: RESUMEN DE PROCEDIMIENTOS POR CATEGORÍA
   ============================================================ */

SELECT 
    'CRUD' AS categoria,
    COUNT(*) AS cantidad
FROM sys.procedures
WHERE name LIKE 'usp_%'
  AND name NOT LIKE 'usp_cursor%'
  AND name NOT LIKE 'usp_transaccion%'

UNION ALL

SELECT 
    'Cursores' AS categoria,
    COUNT(*) AS cantidad
FROM sys.procedures
WHERE name LIKE 'usp_cursor%'

UNION ALL

SELECT 
    'Transacciones' AS categoria,
    COUNT(*) AS cantidad
FROM sys.procedures
WHERE name LIKE 'usp_transaccion%'

UNION ALL

SELECT 
    'Total' AS categoria,
    COUNT(*) AS cantidad
FROM sys.procedures;
GO


/* ============================================================
   PRUEBA 3: LISTAR TODOS LOS PROCEDIMIENTOS
   ============================================================ */

SELECT 
    name AS procedimiento
FROM sys.procedures
ORDER BY name;
GO


/* ============================================================
   PRUEBA 4: LISTAR PROCEDIMIENTOS CLASIFICADOS
   ============================================================ */

SELECT
    name AS procedimiento,
    CASE
        WHEN name LIKE 'usp_cursor%' THEN 'Cursor'
        WHEN name LIKE 'usp_transaccion%' THEN 'Transaccion'
        ELSE 'CRUD'
    END AS categoria
FROM sys.procedures
ORDER BY categoria, name;
GO


/* ============================================================
   PRUEBA 5: LISTAR SOLO PROCEDIMIENTOS CRUD
   ============================================================ */

SELECT 
    name AS procedimiento_crud
FROM sys.procedures
WHERE name LIKE 'usp_%'
  AND name NOT LIKE 'usp_cursor%'
  AND name NOT LIKE 'usp_transaccion%'
ORDER BY name;
GO


/* ============================================================
   PRUEBA 6: LISTAR SOLO PROCEDIMIENTOS DE CURSORES
   ============================================================ */

SELECT 
    name AS procedimiento_cursor
FROM sys.procedures
WHERE name LIKE 'usp_cursor%'
ORDER BY name;
GO


/* ============================================================
   PRUEBA 7: LISTAR SOLO PROCEDIMIENTOS CON TRANSACCIONES
   ============================================================ */

SELECT 
    name AS procedimiento_transaccion
FROM sys.procedures
WHERE name LIKE 'usp_transaccion%'
ORDER BY name;
GO

/* ============================================================
   PRUEBA 8: VERIFICAR TABLAS CREADAS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_tablas
FROM sys.tables;
GO

SELECT 
    name AS tabla
FROM sys.tables
ORDER BY name;
GO


/* ============================================================
   PRUEBA 9: VERIFICAR TIPOS DE DATOS PERSONALIZADOS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_tipos_personalizados
FROM sys.types
WHERE is_user_defined = 1;
GO

SELECT
    name AS tipo_personalizado,
    TYPE_NAME(system_type_id) AS tipo_base,
    max_length AS longitud
FROM sys.types
WHERE is_user_defined = 1
ORDER BY name;
GO


/* ============================================================
   PRUEBA 10: VERIFICAR REGLAS CREADAS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_reglas
FROM sys.objects
WHERE type = 'R';
GO

SELECT 
    name AS regla
FROM sys.objects
WHERE type = 'R'
ORDER BY name;
GO


/* ============================================================
   PRUEBA 11: VERIFICAR LLAVES PRIMARIAS
   ============================================================ */

SELECT
    t.name AS tabla,
    kc.name AS llave_primaria
FROM sys.key_constraints kc
INNER JOIN sys.tables t
    ON kc.parent_object_id = t.object_id
WHERE kc.type = 'PK'
ORDER BY t.name;
GO


/* ============================================================
   PRUEBA 12: VERIFICAR LLAVES FORÁNEAS
   ============================================================ */

SELECT
    fk.name AS llave_foranea,
    OBJECT_NAME(fk.parent_object_id) AS tabla_origen,
    OBJECT_NAME(fk.referenced_object_id) AS tabla_referenciada
FROM sys.foreign_keys fk
ORDER BY tabla_origen, llave_foranea;
GO


/* ============================================================
   PRUEBA 13: VERIFICAR RESTRICCIONES CHECK
   ============================================================ */

SELECT
    OBJECT_NAME(parent_object_id) AS tabla,
    name AS restriccion_check,
    definition AS condicion
FROM sys.check_constraints
ORDER BY tabla, restriccion_check;
GO


/* ============================================================
   PRUEBA 14: VERIFICAR VALORES POR DEFECTO
   ============================================================ */

SELECT
    OBJECT_NAME(parent_object_id) AS tabla,
    name AS restriccion_default,
    definition AS valor_default
FROM sys.default_constraints
ORDER BY tabla, restriccion_default;
GO

/* ============================================================
   PRUEBA 15: VERIFICAR ÍNDICES CREADOS
   ============================================================ */

SELECT
    t.name AS tabla,
    i.name AS indice,
    i.type_desc AS tipo_indice
FROM sys.indexes i
INNER JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
ORDER BY t.name, i.name;
GO


/* ============================================================
   PRUEBA 16: VERIFICAR VISTAS CREADAS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_vistas
FROM sys.views;
GO

SELECT 
    name AS vista
FROM sys.views
ORDER BY name;
GO


/* ============================================================
   PRUEBA 17: CONSULTAR VISTAS
   ============================================================ */

SELECT * FROM vw_ventas_detalle;
GO

SELECT * FROM vw_citas_mascotas_clientes;
GO

SELECT * FROM vw_inventario_productos;
GO


/* ============================================================
   PRUEBA 18: VERIFICAR TRIGGERS CREADOS
   ============================================================ */

SELECT 
    COUNT(*) AS cantidad_triggers
FROM sys.triggers;
GO

SELECT
    tr.name AS trigger_nombre,
    OBJECT_NAME(tr.parent_id) AS tabla_asociada,
    tr.is_disabled AS esta_deshabilitado
FROM sys.triggers tr
ORDER BY tr.name;
GO


/* ============================================================
   PRUEBA 19: VERIFICAR CANTIDAD DE REGISTROS POR TABLA
   ============================================================ */

SELECT 'personas' AS tabla, COUNT(*) AS cantidad FROM personas
UNION ALL
SELECT 'clientes', COUNT(*) FROM clientes
UNION ALL
SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL
SELECT 'telefonos_personas', COUNT(*) FROM telefonos_personas
UNION ALL
SELECT 'mascotas', COUNT(*) FROM mascotas
UNION ALL
SELECT 'producto', COUNT(*) FROM producto
UNION ALL
SELECT 'venta', COUNT(*) FROM venta
UNION ALL
SELECT 'pago', COUNT(*) FROM pago
UNION ALL
SELECT 'pedido', COUNT(*) FROM pedido
UNION ALL
SELECT 'cita', COUNT(*) FROM cita
UNION ALL
SELECT 'procedimiento', COUNT(*) FROM procedimiento
UNION ALL
SELECT 'inventario', COUNT(*) FROM inventario
UNION ALL
SELECT 'producto_venta', COUNT(*) FROM producto_venta
UNION ALL
SELECT 'producto_inventario', COUNT(*) FROM producto_inventario
UNION ALL
SELECT 'producto_pedido', COUNT(*) FROM producto_pedido;
GO

/* ============================================================
   PRUEBA 20: EJECUTAR PROCEDIMIENTOS DE CURSORES
   ============================================================ */

EXEC usp_cursor_reporte_inventario;
GO

EXEC usp_cursor_reporte_ventas_usuarios;
GO


/* ============================================================
   PRUEBA 21: PROBAR TRIGGER DE LÍMITE DE TELÉFONOS

   Esta prueba intenta agregar más de 3 teléfonos a una persona.
   El trigger debe impedirlo.
   ============================================================ */

BEGIN TRY
    INSERT INTO telefonos_personas (cedula, telefono)
    VALUES ('3-3333-3333', '7000-0001');

    INSERT INTO telefonos_personas (cedula, telefono)
    VALUES ('3-3333-3333', '7000-0002');

    INSERT INTO telefonos_personas (cedula, telefono)
    VALUES ('3-3333-3333', '7000-0003');

    PRINT 'Prueba de trigger de telefonos ejecutada.';
END TRY
BEGIN CATCH
    PRINT 'El trigger funciono correctamente.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO


/* ============================================================
   PRUEBA 22: PROBAR TRIGGER DE TOTAL DE VENTA Y DESCUENTO DE STOCK

   Se usa una transacción externa para probar y luego hacer ROLLBACK.
   Así no quedan datos de prueba adicionales.
   ============================================================ */

BEGIN TRANSACTION;

    INSERT INTO venta (id_venta, id_usuario, fecha_venta, total)
    VALUES ('VE999', 'US002', GETDATE(), 0);

    INSERT INTO producto_venta (id_producto, id_venta, cantidad, subtotal)
    VALUES ('PR001', 'VE999', 1, 12500);

    SELECT 
        id_venta,
        total
    FROM venta
    WHERE id_venta = 'VE999';

    SELECT
        id_producto,
        id_inventario,
        stock_actual,
        ubicacion
    FROM producto_inventario
    WHERE id_producto = 'PR001';

ROLLBACK TRANSACTION;
GO


/* ============================================================
   PRUEBA 23: PROBAR TRANSACCIÓN DE REGISTRAR VENTA COMPLETA

   Se ejecuta el procedimiento transaccional y luego se revierte
   con ROLLBACK para no alterar los datos finales.
   ============================================================ */

BEGIN TRANSACTION;

    EXEC usp_transaccion_registrar_venta_completa
        @id_venta = 'VE900',
        @id_usuario = 'US002',
        @id_producto = 'PR002',
        @cantidad = 1,
        @id_pago = 'PA900',
        @metodo_pago = 'Efectivo',
        @estado_pago = 'Aprobado';

    SELECT * FROM venta WHERE id_venta = 'VE900';
    SELECT * FROM producto_venta WHERE id_venta = 'VE900';
    SELECT * FROM pago WHERE id_pago = 'PA900';

ROLLBACK TRANSACTION;
GO


/* ============================================================
   PRUEBA 24: PROBAR TRANSACCIÓN DE REGISTRAR PEDIDO COMPLETO
   ============================================================ */

BEGIN TRANSACTION;

    EXEC usp_transaccion_registrar_pedido_completo
        @id_pedido = 'PE900',
        @id_cliente = 'CL001',
        @id_producto = 'PR003',
        @tipo_entrega = 'Recoger',
        @estado = 'Pendiente';

    SELECT * FROM pedido WHERE id_pedido = 'PE900';
    SELECT * FROM producto_pedido WHERE id_pedido = 'PE900';

ROLLBACK TRANSACTION;
GO


/* ============================================================
   PRUEBA 25: PROBAR TRANSACCIÓN DE CITA CON PROCEDIMIENTO
   ============================================================ */

BEGIN TRANSACTION;

    EXEC usp_transaccion_registrar_cita_con_procedimiento
        @id_cita = 'CI900',
        @id_mascota = 'MA001',
        @fecha_cita = '2026-05-01',
        @hora = '11:30',
        @motivo = 'Prueba de cita',
        @id_procedimiento = 'PC900',
        @id_usuario = 'US003',
        @descripcion = 'Procedimiento de prueba';

    SELECT * FROM cita WHERE id_cita = 'CI900';
    SELECT * FROM procedimiento WHERE id_procedimiento = 'PC900';

ROLLBACK TRANSACTION;
GO


/* ============================================================
   PRUEBA 26: PROBAR TRANSACCIÓN DE PRODUCTO CON INVENTARIO
   ============================================================ */

BEGIN TRANSACTION;

    EXEC usp_transaccion_registrar_producto_con_inventario
        @id_producto = 'PR900',
        @nombre = 'Producto Prueba',
        @tipo = 'Otro',
        @precio = 5000,
        @id_inventario = 'IN900',
        @stock_actual = 20,
        @ubicacion = 'Zona de prueba';

    SELECT * FROM producto WHERE id_producto = 'PR900';
    SELECT * FROM inventario WHERE id_inventario = 'IN900';
    SELECT * FROM producto_inventario WHERE id_producto = 'PR900';

ROLLBACK TRANSACTION;
GO


/* ============================================================
   PRUEBA 27: PROBAR TRANSACCIÓN DE PROCESAR PAGO DE VENTA
   ============================================================ */

BEGIN TRANSACTION;

    EXEC usp_transaccion_procesar_pago_venta
        @id_pago = 'PA901',
        @id_venta = 'VE001',
        @monto = 30500,
        @metodo_pago = 'SINPE';

    SELECT * FROM pago WHERE id_venta = 'VE001';

ROLLBACK TRANSACTION;
GO

