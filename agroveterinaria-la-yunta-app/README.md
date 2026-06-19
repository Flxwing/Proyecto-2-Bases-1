# Agroveterinaria La Yunta - Aplicación Web

Aplicación web desarrollada para el segundo proyecto del curso de Bases de Datos.
El sistema permite administrar información básica de una agroveterinaria, consultar datos desde SQL Server, registrar entidades principales y ejecutar procedimientos almacenados con transacciones.

## Tecnologías utilizadas

* Node.js
* Express
* SQL Server
* Paquete `mssql`
* HTML
* CSS
* JavaScript

## Base de datos utilizada

La aplicación se conecta a la base de datos:

```txt
BD_AgroveterinariaLaYunta
```

Esta base de datos contiene tablas, vistas, triggers, procedimientos CRUD, cursores y procedimientos con transacciones.

## Funcionalidades principales

La aplicación incluye los siguientes módulos:

* **Resumen:** muestra cantidades generales de clientes, mascotas, productos y citas.
* **Clientes:** permite consultar clientes y registrar cliente completo.
* **Mascotas:** permite consultar y registrar mascotas.
* **Productos:** permite consultar y registrar productos.
* **Inventario:** permite consultar el inventario de productos.
* **Ventas:** permite consultar ventas y registrar una venta completa.
* **Citas:** permite consultar y registrar citas.
* **Reportes:** consulta vistas SQL creadas en la base de datos.
* **Transacciones:** permite ejecutar operaciones especiales mediante procedimientos almacenados.

## Reportes disponibles

Los reportes consumen vistas SQL existentes en la base de datos:

```txt
vw_ventas_detalle
vw_citas_mascotas_clientes
vw_inventario_productos
```

## Procedimientos utilizados

La aplicación utiliza procedimientos almacenados para consultar e insertar información.
También utiliza procedimientos con transacciones para operaciones más complejas, por ejemplo:

```txt
usp_transaccion_registrar_venta_completa
usp_transaccion_registrar_pedido_completo
usp_transaccion_registrar_producto_con_inventario
usp_transaccion_registrar_cita_con_procedimiento
usp_transaccion_procesar_pago_venta
```

## Requisitos previos

Antes de ejecutar la aplicación, se necesita tener instalado:

* Node.js
* SQL Server
* SQL Server Management Studio
* Base de datos `BD_AgroveterinariaLaYunta` creada y cargada con el script SQL del proyecto

## Instalación

Clonar o copiar el proyecto y entrar a la carpeta principal:

```bash
cd agroveterinaria-la-yunta-app
```

Instalar las dependencias:

```bash
npm install
```

## Configuración de variables de entorno

Crear un archivo llamado `.env` en la raíz del proyecto.

Ejemplo:

```env
DB_USER=app_layunta
DB_PASSWORD=tu_contrasena
DB_SERVER=127.0.0.1
DB_DATABASE=BD_AgroveterinariaLaYunta
DB_PORT=1433
DB_ENCRYPT=false
DB_TRUST_CERT=true
```

El archivo `.env` no debe subirse a repositorios públicos porque contiene datos de conexión.

Se recomienda mantener un archivo `.env.example` con esta estructura:

```env
DB_USER=app_layunta
DB_PASSWORD=tu_contrasena
DB_SERVER=127.0.0.1
DB_DATABASE=BD_AgroveterinariaLaYunta
DB_PORT=1433
DB_ENCRYPT=false
DB_TRUST_CERT=true
```

## Ejecución

Para iniciar la aplicación:

```bash
npm start
```

La aplicación se ejecutará en:

```txt
http://localhost:3000
```

## Verificación de conexión

Para verificar que el servidor y la base de datos están conectados correctamente, abrir:

```txt
http://localhost:3000/api/health
```

Si todo funciona correctamente, debe devolver información de la base de datos conectada.

## Problemas comunes de conexión

Si la aplicación inicia correctamente, pero no logra conectarse a SQL Server, se recomienda revisar lo siguiente:

1. Verificar que la base de datos `BD_AgroveterinariaLaYunta` exista en SQL Server.
2. Confirmar que el archivo `.env` tenga los datos correctos de conexión.
3. Verificar que el usuario `app_layunta` exista en SQL Server y tenga permisos sobre la base de datos.
4. Revisar que SQL Server tenga habilitado el protocolo TCP/IP.
5. Confirmar que SQL Server esté escuchando en el puerto `1433`.

Para verificar la conexión desde la app, se puede abrir:

```txt
http://localhost:3000/api/health
```

Si la conexión funciona, la ruta debe devolver información de la base de datos y del servidor SQL.


## Estructura del proyecto

```txt
agroveterinaria-la-yunta-app/
│
├── server.js
├── db.js
├── package.json
├── package-lock.json
├── .env.example
│
├── routes/
│   ├── clientes.routes.js
│   ├── mascotas.routes.js
│   ├── productos.routes.js
│   ├── inventario.routes.js
│   ├── ventas.routes.js
│   ├── citas.routes.js
│   ├── usuarios.routes.js
│   ├── reportes.routes.js
│   └── transacciones.routes.js
│
└── public/
    ├── index.html
    ├── styles.css
    └── app.js
```

## Rutas principales

Algunas rutas utilizadas por la aplicación son:

```txt
GET  /api/health
GET  /api/clientes
POST /api/clientes/completo

GET  /api/mascotas
POST /api/mascotas

GET  /api/productos
POST /api/productos

GET  /api/inventario
GET  /api/ventas
GET  /api/citas
POST /api/citas

GET  /api/reportes/ventas-detalle
GET  /api/reportes/citas-mascotas-clientes
GET  /api/reportes/inventario-productos

POST /api/transacciones/venta-completa
POST /api/transacciones/pedido-completo
POST /api/transacciones/producto-inventario
POST /api/transacciones/cita-procedimiento
POST /api/transacciones/procesar-pago
```

## Notas importantes

* No se debe subir la carpeta `node_modules`.
* No se debe subir el archivo `.env` con contraseñas reales.
* Para instalar dependencias se debe usar `npm install`.
* Para ejecutar la aplicación se debe usar `npm start`.
* SQL Server debe tener TCP/IP habilitado para permitir la conexión desde Node.js.
* La base de datos debe existir antes de iniciar la aplicación.

## Archivos ignorados recomendados

El archivo `.gitignore` debería incluir:

```gitignore
node_modules/
.env
```

## Pruebas sugeridas

Después de iniciar la aplicación, se recomienda probar:

1. Abrir el panel principal y verificar el resumen.
2. Consultar clientes, mascotas, productos, inventario, ventas y citas.
3. Registrar un cliente completo.
4. Registrar una mascota.
5. Registrar una cita.
6. Registrar un producto.
7. Registrar una venta completa.
8. Consultar los reportes.
9. Ejecutar una operación especial desde el módulo de transacciones.

## Descripción general

La aplicación web funciona como interfaz administrativa para la base de datos de Agroveterinaria La Yunta.
Permite demostrar la conexión entre una aplicación web y una base de datos SQL Server, utilizando procedimientos almacenados, vistas y transacciones para gestionar información del sistema.
