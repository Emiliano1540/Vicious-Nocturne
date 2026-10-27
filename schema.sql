-- =====================================================================
--  Vicious Nocturne · Base de datos de patrocinios (Supabase / Postgres)
--
--  CÓMO USAR:
--   1) Cambia TU_CORREO_ADMIN@ejemplo.com (aparece 2 veces) por el correo
--      con el que vas a entrar al panel admin.html.
--   2) Pega TODO este archivo en Supabase > SQL Editor y presiona "Run".
--
--  QUÉ LOGRA:
--   - Cualquier visitante puede REGISTRAR un aporte (nombre, correo, monto, paquete).
--   - Nadie más puede LEER los nombres ni los correos: solo tú, con tu sesión.
--   - La página pública solo puede pedir los TOTALES (suma y número de aportes),
--     que alimentan la barra de "Meta del primer proyecto".
--   - Todas las cifras son de prueba: la tabla no cobra ni mueve dinero real.
-- =====================================================================

-- 1) Tabla de aportes ---------------------------------------------------
create table if not exists public.patrocinios (
  id       bigint generated always as identity primary key,
  creado   timestamptz not null default now(),
  nombre   text not null
             check (char_length(btrim(nombre)) between 1 and 80),
  correo   text not null
             check (char_length(correo) <= 254
                    and correo ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  monto    numeric(10,2) not null
             check (monto >= 20 and monto <= 100000),
  paquete  text not null
             check (paquete in ('sombra', 'luna', 'eclipse')),
  simulado boolean not null default true
);

create index if not exists patrocinios_creado_idx on public.patrocinios (creado desc);

-- 2) Seguridad a nivel de fila (RLS) -----------------------------------
alter table public.patrocinios enable row level security;

-- Empezamos sin permisos para nadie...
revoke all on public.patrocinios from anon, authenticated;

-- ...los visitantes solo pueden INSERTAR estas 4 columnas (no pueden fijar
-- fecha, id ni la marca "simulado")...
grant insert (nombre, correo, monto, paquete) on public.patrocinios to anon, authenticated;

-- ...y tú (sesión iniciada con tu correo) puedes leer y borrar.
grant select, delete on public.patrocinios to authenticated;

drop policy if exists "visitantes registran aportes" on public.patrocinios;
create policy "visitantes registran aportes"
  on public.patrocinios for insert
  to anon, authenticated
  with check (true);

drop policy if exists "admin lee aportes" on public.patrocinios;
create policy "admin lee aportes"
  on public.patrocinios for select
  to authenticated
  using (lower(auth.jwt() ->> 'email') = lower('emilianogf17@gmail.com'));

drop policy if exists "admin borra aportes" on public.patrocinios;
create policy "admin borra aportes"
  on public.patrocinios for delete
  to authenticated
  using (lower(auth.jwt() ->> 'email') = lower('emilianogf17@gmail.com'));

-- 3) Totales públicos para la barra de meta ----------------------------
-- Devuelve solo la suma y el conteo; nunca nombres ni correos.
create or replace function public.totales_campana()
returns json
language sql
stable
security definer
set search_path = public
as $$
  select json_build_object(
    'total',          coalesce(sum(monto), 0),
    'patrocinadores', count(*)
  )
  from public.patrocinios;
$$;

revoke all on function public.totales_campana() from public;
grant execute on function public.totales_campana() to anon, authenticated;
