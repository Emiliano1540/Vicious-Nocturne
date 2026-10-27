# Vicious Nocturne · Sitio web con patrocinios de prueba

Sitio estático (HTML + CSS + JavaScript) pensado para publicarse gratis en **GitHub Pages**, con una base de datos gratuita en **Supabase** que guarda el **nombre, correo y monto** de cada aporte y alimenta la barra de **"Meta del primer proyecto"**.

> **Todo es de prueba.** El sitio no cobra ni mueve dinero real. Las cantidades son ficticias y así se avisa en la propia página.

## Qué contiene

| Archivo | Para qué sirve |
|---|---|
| `index.html` | El sitio público (un solo archivo con CSS, JavaScript y logo incluidos). |
| `admin.html` | Panel privado para ver los aportes, buscarlos, borrarlos y exportarlos a CSV. |
| `supabase/schema.sql` | Crea la tabla, las reglas de seguridad y la función de totales. |

## Cómo funciona

1. Un visitante elige un paquete y llena el formulario. El sitio guarda **nombre, correo, monto y paquete** en Supabase.
2. La barra de meta pide a la base de datos solo los **totales** (suma y número de aportes). Nunca recibe nombres ni correos.
3. Tú entras a `admin.html` con tu correo y contraseña y ves la lista completa. Nadie más puede leerla.

Mientras no conectes Supabase, ambas páginas funcionan en **modo local**: los aportes se guardan solo en el navegador donde pruebas. Sirve para ver cómo se comporta todo antes de configurar nada.

## Configuración paso a paso

### 1. Crear la base de datos (Supabase)

1. Crea una cuenta y un proyecto nuevo en [supabase.com](https://supabase.com) (el plan gratuito basta).
2. Abre `supabase/schema.sql` y cambia `TU_CORREO_ADMIN@ejemplo.com` por tu correo (aparece **2 veces**).
3. En Supabase entra a **SQL Editor**, pega todo el archivo y presiona **Run**.

### 2. Crear tu usuario administrador

1. En Supabase ve a **Authentication → Users → Add user** y crea un usuario con **el mismo correo** que pusiste en el SQL y una contraseña larga. Marca la opción de confirmar el correo automáticamente.
2. En los ajustes de **Authentication**, desactiva el **registro público de usuarios** ("Allow new users to sign up"). Así nadie más puede crearse una cuenta.

### 3. Conectar el sitio

1. En Supabase abre **Project Settings → API Keys** y copia la clave pública: la **Publishable key** (empieza con `sb_publishable_`; la clave **anon** antigua también sirve). La **Project URL** aparece en el botón **Connect**.
2. Pega esos dos datos en las constantes `SUPABASE_URL` y `SUPABASE_ANON_KEY`, al inicio del bloque `<script>` de **`index.html`** y también de **`admin.html`**.

> **Nunca** pegues la clave `service_role` ni la "secret key". Esas dan control total y no deben estar en una página pública. La clave pública sí puede ir en el código: lo que protege tus datos son las reglas de `schema.sql`.

### 4. Publicar en GitHub Pages

1. Crea un repositorio en GitHub y sube `index.html`, `admin.html`, `supabase/` y este `README.md`.
2. En el repositorio ve a **Settings → Pages**, elige **Deploy from a branch**, rama `main` y carpeta `/ (root)`.
3. En unos minutos tendrás una dirección como `https://tu-usuario.github.io/tu-repo/`. El panel estará en `.../admin.html`.

### 5. Probar

1. Abre el sitio, haz un aporte de prueba y comprueba que la barra de meta sube.
2. Abre `admin.html`, inicia sesión y verifica que ves el aporte con nombre, correo y monto.

## Cambiar la meta o las cifras

- **Meta:** cambia `GOAL` (en MXN) en `index.html` y en `admin.html`.
- **Paquetes y montos:** los precios están en `PRICES` dentro de `index.html`. Si cambias los nombres de los paquetes, actualiza también la lista permitida en `schema.sql` (`check (paquete in (...))`).

## Seguridad y límites

- Los visitantes solo pueden **insertar** (nombre, correo, monto, paquete). No pueden leer ni modificar nada.
- La base rechaza montos fuera de $20–$100,000 y correos con formato inválido.
- El formulario tiene un campo trampa para robots y una pausa de 8 segundos entre envíos, pero **no impide el spam por completo**: cualquiera con conocimientos técnicos podría enviar aportes falsos y subir la meta. Si pasa, bórralos desde el panel.
- El panel mantiene tu sesión solo mientras la pestaña está abierta.
- Los proyectos gratuitos de Supabase pueden pausarse tras un tiempo sin actividad. Se reactivan desde su panel.

## Antes de usarlo con gente real

Estás guardando **correos electrónicos**, que son datos personales. Antes de compartir el sitio públicamente conviene publicar un **aviso de privacidad** y decir con claridad que es una simulación. Si más adelante quieres recibir dinero de verdad, hará falta conectar un servicio de pagos (Mercado Pago, Stripe, PayPal, etc.) y revisar las obligaciones fiscales y legales que correspondan.
