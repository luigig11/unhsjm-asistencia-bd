CREATE TABLE "public"."asistencia_detalle" (
  "id"                        uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "id_asistencia"             uuid                     NOT NULL,
  "id_inscripcion_grupo"      uuid                     NOT NULL,
  "asistio"                   boolean                  NOT NULL DEFAULT false,
  "id_motivo_ausencia"        uuid,
  "fecha_registro_estudiante" timestamp with time zone DEFAULT now(),
  CONSTRAINT "asistencia_detalle_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_asistencia_detalle_motivo" CHECK (((asistio = false) OR (id_motivo_ausencia IS NULL))),
  CONSTRAINT "uq_asistencia_detalle" UNIQUE (id_asistencia, id_inscripcion_grupo)
);

ALTER TABLE "public"."asistencia_detalle"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."asistencia_detalle" FROM "anon";

CREATE TABLE "public"."asistencia" (
  "id"                       uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "id_calendario"            uuid                     NOT NULL,
  "id_docente_sustituto"     uuid,
  "docente_asignado_asistio" boolean,
  "id_motivo_ausencia"       uuid,
  "fecha_registro_docente"   timestamp with time zone,
  CONSTRAINT "asistencia_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_asistencia_docente_sustituto" CHECK ((NOT ((docente_asignado_asistio = true) AND (id_docente_sustituto IS NOT NULL)))),
  CONSTRAINT "chk_asistencia_motivo_ausencia" CHECK (((docente_asignado_asistio = false) OR (id_motivo_ausencia IS NULL))),
  CONSTRAINT "uq_asistencia_calendario" UNIQUE (id_calendario)
);

ALTER TABLE "public"."asistencia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."asistencia" FROM "anon";

CREATE TABLE "public"."aula" (
  "id"           uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_tipo_aula" uuid                   NOT NULL,
  "codigo"       character varying(20)  NOT NULL,
  "nombre"       character varying(100) NOT NULL,
  "capacidad"    smallint               NOT NULL DEFAULT 40,
  "ubicacion"    character varying(150),
  "activo"       boolean                NOT NULL DEFAULT true,
  CONSTRAINT "aula_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_aula_capacidad" CHECK ((capacidad > 0)),
  CONSTRAINT "chk_aula_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_aula_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "uq_aula_codigo" UNIQUE (codigo)
);

ALTER TABLE "public"."aula"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."aula" FROM "anon";

CREATE TABLE "public"."calendario_semanal" (
  "id"                   uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_materia_por_grupo" uuid                   NOT NULL,
  "id_aula"              uuid                   NOT NULL,
  "id_dia"               smallint               NOT NULL,
  "hora_inicio"          time without time zone NOT NULL,
  "hora_fin"             time without time zone NOT NULL,
  "activo"               boolean                NOT NULL DEFAULT true,
  CONSTRAINT "calendario_semanal_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_calendario_semanal_horas" CHECK ((hora_fin > hora_inicio)),
  CONSTRAINT "uq_calendario_semanal" UNIQUE (id_materia_por_grupo, id_dia, hora_inicio)
);

ALTER TABLE "public"."calendario_semanal"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."calendario_semanal" FROM "anon";

CREATE TABLE "public"."calendario" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "id_materia_por_grupo" uuid                     NOT NULL,
  "id_aula"              uuid                     NOT NULL,
  "fecha_inicio"         timestamp with time zone NOT NULL,
  "fecha_fin"            timestamp with time zone NOT NULL,
  "activo"               boolean                  NOT NULL DEFAULT true,
  CONSTRAINT "calendario_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_calendario_fechas" CHECK ((fecha_fin > fecha_inicio)),
  CONSTRAINT "uq_calendario_sesion" UNIQUE (id_materia_por_grupo, fecha_inicio)
);

ALTER TABLE "public"."calendario"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."calendario" FROM "anon";

CREATE TABLE "public"."dia" (
  "id"     smallint              NOT NULL,
  "nombre" character varying(15) NOT NULL,
  CONSTRAINT "chk_dia_id" CHECK (((id >= 1) AND (id <= 7))),
  CONSTRAINT "chk_dia_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "dia_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_dia_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."dia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."dia" FROM "anon";

CREATE TABLE "public"."docente" (
  "id"              uuid                  NOT NULL DEFAULT gen_random_uuid(),
  "id_usuario"      uuid                  NOT NULL,
  "id_direccion"    uuid                  NOT NULL,
  "codigo_empleado" character varying(30) NOT NULL,
  "telefono"        character varying(20),
  CONSTRAINT "chk_docente_codigo_empleado" CHECK ((char_length(TRIM(BOTH FROM codigo_empleado)) > 0)),
  CONSTRAINT "docente_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_docente_codigo_empleado" UNIQUE (codigo_empleado),
  CONSTRAINT "uq_docente_usuario" UNIQUE (id_usuario)
);

ALTER TABLE "public"."docente"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."docente" FROM "anon";

CREATE TABLE "public"."estudiante" (
  "id"                uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_carrera"        uuid                   NOT NULL,
  "id_plan_academico" uuid                   NOT NULL,
  "carnet"            character varying(20)  NOT NULL,
  "cedula"            character varying(20),
  "nombres"           character varying(100) NOT NULL,
  "primer_apellido"   character varying(60)  NOT NULL,
  "segundo_apellido"  character varying(60),
  "correo"            character varying(150),
  "telefono"          character varying(20),
  "fecha_ingreso"     date                   NOT NULL DEFAULT CURRENT_DATE,
  "activo"            boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_estudiante_carnet" CHECK ((char_length(TRIM(BOTH FROM carnet)) > 0)),
  CONSTRAINT "chk_estudiante_nombres" CHECK ((char_length(TRIM(BOTH FROM nombres)) > 0)),
  CONSTRAINT "chk_estudiante_primer_apellido" CHECK ((char_length(TRIM(BOTH FROM primer_apellido)) > 0)),
  CONSTRAINT "estudiante_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_estudiante_carnet" UNIQUE (carnet),
  CONSTRAINT "uq_estudiante_cedula" UNIQUE (cedula),
  CONSTRAINT "uq_estudiante_correo" UNIQUE (correo)
);

ALTER TABLE "public"."estudiante"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."estudiante" FROM "anon";

CREATE TABLE "public"."inscripcion_grupo" (
  "id"                   uuid    NOT NULL DEFAULT gen_random_uuid(),
  "id_materia_por_grupo" uuid    NOT NULL,
  "id_estudiante"        uuid    NOT NULL,
  "fecha_inscripcion"    date    NOT NULL DEFAULT CURRENT_DATE,
  "activo"               boolean NOT NULL DEFAULT true,
  CONSTRAINT "inscripcion_grupo_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_inscripcion_grupo" UNIQUE (id_materia_por_grupo, id_estudiante)
);

ALTER TABLE "public"."inscripcion_grupo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."inscripcion_grupo" FROM "anon";

CREATE TABLE "public"."materia_por_grupo" (
  "id"                  uuid     NOT NULL DEFAULT gen_random_uuid(),
  "id_grupo"            uuid     NOT NULL,
  "id_malla_curricular" uuid     NOT NULL,
  "id_docente"          uuid     NOT NULL,
  "cupo_limite"         smallint NOT NULL DEFAULT 35,
  "activo"              boolean  NOT NULL DEFAULT true,
  CONSTRAINT "chk_materia_por_grupo_cupo" CHECK ((cupo_limite > 0)),
  CONSTRAINT "materia_por_grupo_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_materia_por_grupo" UNIQUE (id_grupo, id_malla_curricular)
);

ALTER TABLE "public"."materia_por_grupo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."materia_por_grupo" FROM "anon";

CREATE TABLE "public"."motivo_ausencia" (
  "id"                     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo"                 character varying(20)  NOT NULL,
  "nombre"                 character varying(100) NOT NULL,
  "descripcion"            character varying(250),
  "justifica_inasistencia" boolean                NOT NULL DEFAULT true,
  "aplica_a"               character varying(15)  NOT NULL DEFAULT 'AMBOS'::character varying,
  "activo"                 boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_motivo_ausencia_aplica_a"
    CHECK (((aplica_a)::text = ANY ((ARRAY['DOCENTE'::character varying, 'ESTUDIANTE'::character varying, 'AMBOS'::character varying])::text[]))),
  CONSTRAINT "chk_motivo_ausencia_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_motivo_ausencia_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "motivo_ausencia_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_motivo_ausencia_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_motivo_ausencia_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."motivo_ausencia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."motivo_ausencia" FROM "anon";

CREATE TABLE "public"."tipo_aula" (
  "id"          uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo"      character varying(20)  NOT NULL,
  "nombre"      character varying(100) NOT NULL,
  "descripcion" character varying(250),
  "activo"      boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_tipo_aula_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_tipo_aula_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "tipo_aula_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_tipo_aula_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_tipo_aula_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."tipo_aula"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tipo_aula" FROM "anon";

CREATE TYPE "public"."tipo_contratacion_docente" AS ENUM (
  'FIJO',
  'TEMPORAL'
);

ALTER TABLE "public"."docente"
  ADD COLUMN "tipo_contratacion" public.tipo_contratacion_docente NOT NULL;

ALTER TABLE "public"."docente"
  ADD COLUMN "activo" boolean NOT NULL DEFAULT true;

ALTER TABLE "public"."asistencia_detalle"
  ADD CONSTRAINT "fk_asistencia_detalle_asistencia" FOREIGN KEY (id_asistencia) REFERENCES public.asistencia(id) ON DELETE CASCADE;

ALTER TABLE "public"."asistencia"
  ADD CONSTRAINT "fk_asistencia_calendario" FOREIGN KEY (id_calendario) REFERENCES public.calendario(id) ON DELETE RESTRICT;

ALTER TABLE "public"."calendario"
  ADD CONSTRAINT "fk_calendario_aula" FOREIGN KEY (id_aula) REFERENCES public.aula(id) ON DELETE RESTRICT;

ALTER TABLE "public"."calendario_semanal"
  ADD CONSTRAINT "fk_calendario_semanal_aula" FOREIGN KEY (id_aula) REFERENCES public.aula(id) ON DELETE RESTRICT;

ALTER TABLE "public"."calendario_semanal"
  ADD CONSTRAINT "fk_calendario_semanal_dia" FOREIGN KEY (id_dia) REFERENCES public.dia(id) ON DELETE RESTRICT;

ALTER TABLE "public"."asistencia"
  ADD CONSTRAINT "fk_asistencia_docente_sustituto" FOREIGN KEY (id_docente_sustituto) REFERENCES public.docente(id) ON DELETE RESTRICT;

ALTER TABLE "public"."docente"
  ADD CONSTRAINT "fk_docente_direccion" FOREIGN KEY (id_direccion) REFERENCES public.direccion(id) ON DELETE RESTRICT;

ALTER TABLE "public"."docente"
  ADD CONSTRAINT "fk_docente_usuario" FOREIGN KEY (id_usuario) REFERENCES public.usuario(id) ON DELETE RESTRICT;

ALTER TABLE "public"."estudiante"
  ADD CONSTRAINT "fk_estudiante_carrera" FOREIGN KEY (id_carrera) REFERENCES public.carrera(id) ON DELETE RESTRICT;

ALTER TABLE "public"."estudiante"
  ADD CONSTRAINT "fk_estudiante_plan_academico" FOREIGN KEY (id_plan_academico) REFERENCES public.plan_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."inscripcion_grupo"
  ADD CONSTRAINT "fk_inscripcion_grupo_estudiante" FOREIGN KEY (id_estudiante) REFERENCES public.estudiante(id) ON DELETE RESTRICT;

ALTER TABLE "public"."asistencia_detalle"
  ADD CONSTRAINT "fk_asistencia_detalle_inscripcion" FOREIGN KEY (id_inscripcion_grupo) REFERENCES public.inscripcion_grupo(id) ON DELETE RESTRICT;

ALTER TABLE "public"."materia_por_grupo"
  ADD CONSTRAINT "fk_materia_por_grupo_docente" FOREIGN KEY (id_docente) REFERENCES public.docente(id) ON DELETE RESTRICT;

ALTER TABLE "public"."materia_por_grupo"
  ADD CONSTRAINT "fk_materia_por_grupo_grupo" FOREIGN KEY (id_grupo) REFERENCES public.grupo(id) ON DELETE RESTRICT;

ALTER TABLE "public"."materia_por_grupo"
  ADD CONSTRAINT "fk_materia_por_grupo_malla" FOREIGN KEY (id_malla_curricular) REFERENCES public.malla_curricular(id) ON DELETE RESTRICT;

ALTER TABLE "public"."calendario"
  ADD CONSTRAINT "fk_calendario_materia_grupo" FOREIGN KEY (id_materia_por_grupo) REFERENCES public.materia_por_grupo(id) ON DELETE RESTRICT;

ALTER TABLE "public"."calendario_semanal"
  ADD CONSTRAINT "fk_calendario_semanal_materia_grupo" FOREIGN KEY (id_materia_por_grupo) REFERENCES public.materia_por_grupo(id) ON DELETE CASCADE;

ALTER TABLE "public"."inscripcion_grupo"
  ADD CONSTRAINT "fk_inscripcion_grupo_materia_grupo" FOREIGN KEY (id_materia_por_grupo) REFERENCES public.materia_por_grupo(id) ON DELETE RESTRICT;

ALTER TABLE "public"."asistencia"
  ADD CONSTRAINT "fk_asistencia_motivo_ausencia" FOREIGN KEY (id_motivo_ausencia) REFERENCES public.motivo_ausencia(id) ON DELETE RESTRICT;

ALTER TABLE "public"."asistencia_detalle"
  ADD CONSTRAINT "fk_asistencia_detalle_motivo" FOREIGN KEY (id_motivo_ausencia) REFERENCES public.motivo_ausencia(id) ON DELETE RESTRICT;

ALTER TABLE "public"."aula"
  ADD CONSTRAINT "fk_aula_tipo_aula" FOREIGN KEY (id_tipo_aula) REFERENCES public.tipo_aula(id) ON DELETE RESTRICT;

CREATE INDEX idx_asistencia_calendario ON public.asistencia USING btree (id_calendario);

CREATE INDEX idx_asistencia_detalle_asistencia ON public.asistencia_detalle USING btree (id_asistencia);

CREATE INDEX idx_asistencia_detalle_inscripcion ON public.asistencia_detalle USING btree (id_inscripcion_grupo);

CREATE INDEX idx_asistencia_detalle_motivo ON public.asistencia_detalle USING btree (id_motivo_ausencia);

CREATE INDEX idx_asistencia_docente_sustituto ON public.asistencia USING btree (id_docente_sustituto);

CREATE INDEX idx_asistencia_motivo_ausencia ON public.asistencia USING btree (id_motivo_ausencia);

CREATE INDEX idx_aula_tipo_aula ON public.aula USING btree (id_tipo_aula);

CREATE INDEX idx_calendario_aula ON public.calendario USING btree (id_aula);

CREATE INDEX idx_calendario_materia_grupo ON public.calendario USING btree (id_materia_por_grupo);

CREATE INDEX idx_calendario_semanal_aula ON public.calendario_semanal USING btree (id_aula);

CREATE INDEX idx_calendario_semanal_dia ON public.calendario_semanal USING btree (id_dia);

CREATE INDEX idx_calendario_semanal_materia_grupo ON public.calendario_semanal USING btree (id_materia_por_grupo);

CREATE INDEX idx_docente_direccion ON public.docente USING btree (id_direccion);

CREATE INDEX idx_docente_usuario ON public.docente USING btree (id_usuario);

CREATE INDEX idx_estudiante_carrera ON public.estudiante USING btree (id_carrera);

CREATE INDEX idx_estudiante_plan_academico ON public.estudiante USING btree (id_plan_academico);

CREATE INDEX idx_inscripcion_grupo_estudiante ON public.inscripcion_grupo USING btree (id_estudiante);

CREATE INDEX idx_inscripcion_grupo_materia ON public.inscripcion_grupo USING btree (id_materia_por_grupo);

CREATE INDEX idx_materia_por_grupo_docente ON public.materia_por_grupo USING btree (id_docente);

CREATE INDEX idx_materia_por_grupo_grupo ON public.materia_por_grupo USING btree (id_grupo);

CREATE INDEX idx_materia_por_grupo_malla ON public.materia_por_grupo USING btree (id_malla_curricular);

CREATE POLICY "policy_asistencia_delete" ON "public"."asistencia"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('asistencia'::text, 'delete'::text));

CREATE POLICY "policy_asistencia_insert" ON "public"."asistencia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('asistencia'::text, 'insert'::text));

CREATE POLICY "policy_asistencia_select" ON "public"."asistencia"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('asistencia'::text, 'select'::text));

CREATE POLICY "policy_asistencia_update" ON "public"."asistencia"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('asistencia'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('asistencia'::text, 'update'::text));

CREATE POLICY "policy_asistencia_detalle_delete" ON "public"."asistencia_detalle"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('asistencia_detalle'::text, 'delete'::text));

CREATE POLICY "policy_asistencia_detalle_insert" ON "public"."asistencia_detalle"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('asistencia_detalle'::text, 'insert'::text));

CREATE POLICY "policy_asistencia_detalle_select" ON "public"."asistencia_detalle"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('asistencia_detalle'::text, 'select'::text));

CREATE POLICY "policy_asistencia_detalle_update" ON "public"."asistencia_detalle"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('asistencia_detalle'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('asistencia_detalle'::text, 'update'::text));

CREATE POLICY "policy_aula_delete" ON "public"."aula"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('aula'::text, 'delete'::text));

CREATE POLICY "policy_aula_insert" ON "public"."aula"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('aula'::text, 'insert'::text));

CREATE POLICY "policy_aula_select" ON "public"."aula"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('aula'::text, 'select'::text));

CREATE POLICY "policy_aula_update" ON "public"."aula"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('aula'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('aula'::text, 'update'::text));

CREATE POLICY "policy_calendario_delete" ON "public"."calendario"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('calendario'::text, 'delete'::text));

CREATE POLICY "policy_calendario_insert" ON "public"."calendario"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('calendario'::text, 'insert'::text));

CREATE POLICY "policy_calendario_select" ON "public"."calendario"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('calendario'::text, 'select'::text));

CREATE POLICY "policy_calendario_update" ON "public"."calendario"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('calendario'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('calendario'::text, 'update'::text));

CREATE POLICY "policy_calendario_semanal_delete" ON "public"."calendario_semanal"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('calendario_semanal'::text, 'delete'::text));

CREATE POLICY "policy_calendario_semanal_insert" ON "public"."calendario_semanal"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('calendario_semanal'::text, 'insert'::text));

CREATE POLICY "policy_calendario_semanal_select" ON "public"."calendario_semanal"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('calendario_semanal'::text, 'select'::text));

CREATE POLICY "policy_calendario_semanal_update" ON "public"."calendario_semanal"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('calendario_semanal'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('calendario_semanal'::text, 'update'::text));

CREATE POLICY "policy_dia_delete" ON "public"."dia"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('dia'::text, 'delete'::text));

CREATE POLICY "policy_dia_insert" ON "public"."dia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('dia'::text, 'insert'::text));

CREATE POLICY "policy_dia_select" ON "public"."dia"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('dia'::text, 'select'::text));

CREATE POLICY "policy_dia_update" ON "public"."dia"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('dia'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('dia'::text, 'update'::text));

CREATE POLICY "policy_docente_delete" ON "public"."docente"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('docente'::text, 'delete'::text));

CREATE POLICY "policy_docente_insert" ON "public"."docente"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('docente'::text, 'insert'::text));

CREATE POLICY "policy_docente_select" ON "public"."docente"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('docente'::text, 'select'::text));

CREATE POLICY "policy_docente_update" ON "public"."docente"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('docente'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('docente'::text, 'update'::text));

CREATE POLICY "policy_estudiante_delete" ON "public"."estudiante"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('estudiante'::text, 'delete'::text));

CREATE POLICY "policy_estudiante_insert" ON "public"."estudiante"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('estudiante'::text, 'insert'::text));

CREATE POLICY "policy_estudiante_select" ON "public"."estudiante"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('estudiante'::text, 'select'::text));

CREATE POLICY "policy_estudiante_update" ON "public"."estudiante"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('estudiante'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('estudiante'::text, 'update'::text));

CREATE POLICY "policy_inscripcion_grupo_delete" ON "public"."inscripcion_grupo"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('inscripcion_grupo'::text, 'delete'::text));

CREATE POLICY "policy_inscripcion_grupo_insert" ON "public"."inscripcion_grupo"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('inscripcion_grupo'::text, 'insert'::text));

CREATE POLICY "policy_inscripcion_grupo_select" ON "public"."inscripcion_grupo"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('inscripcion_grupo'::text, 'select'::text));

CREATE POLICY "policy_inscripcion_grupo_update" ON "public"."inscripcion_grupo"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('inscripcion_grupo'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('inscripcion_grupo'::text, 'update'::text));

CREATE POLICY "policy_materia_por_grupo_delete" ON "public"."materia_por_grupo"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('materia_por_grupo'::text, 'delete'::text));

CREATE POLICY "policy_materia_por_grupo_insert" ON "public"."materia_por_grupo"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('materia_por_grupo'::text, 'insert'::text));

CREATE POLICY "policy_materia_por_grupo_select" ON "public"."materia_por_grupo"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('materia_por_grupo'::text, 'select'::text));

CREATE POLICY "policy_materia_por_grupo_update" ON "public"."materia_por_grupo"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('materia_por_grupo'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('materia_por_grupo'::text, 'update'::text));

CREATE POLICY "policy_motivo_ausencia_delete" ON "public"."motivo_ausencia"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('motivo_ausencia'::text, 'delete'::text));

CREATE POLICY "policy_motivo_ausencia_insert" ON "public"."motivo_ausencia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('motivo_ausencia'::text, 'insert'::text));

CREATE POLICY "policy_motivo_ausencia_select" ON "public"."motivo_ausencia"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('motivo_ausencia'::text, 'select'::text));

CREATE POLICY "policy_motivo_ausencia_update" ON "public"."motivo_ausencia"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('motivo_ausencia'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('motivo_ausencia'::text, 'update'::text));

CREATE POLICY "policy_tipo_aula_delete" ON "public"."tipo_aula"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_aula'::text, 'delete'::text));

CREATE POLICY "policy_tipo_aula_insert" ON "public"."tipo_aula"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('tipo_aula'::text, 'insert'::text));

CREATE POLICY "policy_tipo_aula_select" ON "public"."tipo_aula"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('tipo_aula'::text, 'select'::text));

CREATE POLICY "policy_tipo_aula_update" ON "public"."tipo_aula"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_aula'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('tipo_aula'::text, 'update'::text));

REVOKE ALL ON TABLE "public"."asistencia" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."asistencia" TO "authenticated";

REVOKE ALL ON TABLE "public"."asistencia" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asistencia" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asistencia" TO "service_role";

REVOKE ALL ON TABLE "public"."asistencia_detalle" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."asistencia_detalle" TO "authenticated";

REVOKE ALL ON TABLE "public"."asistencia_detalle" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asistencia_detalle" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asistencia_detalle" TO "service_role";

REVOKE ALL ON TABLE "public"."aula" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."aula" TO "authenticated";

REVOKE ALL ON TABLE "public"."aula" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."aula" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."aula" TO "service_role";

REVOKE ALL ON TABLE "public"."calendario" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."calendario" TO "authenticated";

REVOKE ALL ON TABLE "public"."calendario" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calendario" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calendario" TO "service_role";

REVOKE ALL ON TABLE "public"."calendario_semanal" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."calendario_semanal" TO "authenticated";

REVOKE ALL ON TABLE "public"."calendario_semanal" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calendario_semanal" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calendario_semanal" TO "service_role";

REVOKE ALL ON TABLE "public"."dia" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."dia" TO "authenticated";

REVOKE ALL ON TABLE "public"."dia" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."dia" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."dia" TO "service_role";

REVOKE ALL ON TABLE "public"."docente" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."docente" TO "authenticated";

REVOKE ALL ON TABLE "public"."docente" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."docente" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."docente" TO "service_role";

REVOKE ALL ON TABLE "public"."estudiante" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."estudiante" TO "authenticated";

REVOKE ALL ON TABLE "public"."estudiante" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."estudiante" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."estudiante" TO "service_role";

REVOKE ALL ON TABLE "public"."inscripcion_grupo" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."inscripcion_grupo" TO "authenticated";

REVOKE ALL ON TABLE "public"."inscripcion_grupo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inscripcion_grupo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."inscripcion_grupo" TO "service_role";

REVOKE ALL ON TABLE "public"."materia_por_grupo" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."materia_por_grupo" TO "authenticated";

REVOKE ALL ON TABLE "public"."materia_por_grupo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia_por_grupo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia_por_grupo" TO "service_role";

REVOKE ALL ON TABLE "public"."motivo_ausencia" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."motivo_ausencia" TO "authenticated";

REVOKE ALL ON TABLE "public"."motivo_ausencia" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."motivo_ausencia" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."motivo_ausencia" TO "service_role";

REVOKE ALL ON TABLE "public"."tipo_aula" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tipo_aula" TO "authenticated";

REVOKE ALL ON TABLE "public"."tipo_aula" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_aula" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_aula" TO "service_role";
