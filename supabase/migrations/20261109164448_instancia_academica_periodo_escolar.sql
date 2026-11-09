CREATE TABLE "public"."feriado" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "id_periodo_escolar" uuid                     NOT NULL,
  "id_tipo_evento"     uuid                     NOT NULL,
  "nombre"             character varying(150)   NOT NULL,
  "fecha_inicio"       timestamp with time zone NOT NULL,
  "fecha_fin"          timestamp with time zone NOT NULL,
  "activo"             boolean                  NOT NULL DEFAULT true,
  CONSTRAINT "chk_feriado_fechas" CHECK ((fecha_fin >= fecha_inicio)),
  CONSTRAINT "chk_feriado_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "feriado_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."feriado"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."feriado" FROM "anon";

CREATE TABLE "public"."grupo" (
  "id"                     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_instancia_academica" uuid                   NOT NULL,
  "codigo"                 character varying(20)  NOT NULL,
  "nombre"                 character varying(100) NOT NULL,
  "cupo"                   smallint               NOT NULL DEFAULT 35,
  "activo"                 boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_grupo_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_grupo_cupo" CHECK ((cupo > 0)),
  CONSTRAINT "chk_grupo_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "grupo_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_grupo_instancia_codigo" UNIQUE (id_instancia_academica, codigo)
);

ALTER TABLE "public"."grupo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."grupo" FROM "anon";

CREATE TABLE "public"."instancia_academica" (
  "id"                        uuid                  NOT NULL DEFAULT gen_random_uuid(),
  "id_periodo_escolar"        uuid                  NOT NULL,
  "id_detalle_plan_academico" uuid                  NOT NULL,
  "nombre"                    character varying(50) NOT NULL,
  "fecha_inicio"              date                  NOT NULL,
  "fecha_fin"                 date                  NOT NULL,
  "activo"                    boolean               NOT NULL DEFAULT true,
  CONSTRAINT "chk_instancia_academica_fechas" CHECK ((fecha_fin > fecha_inicio)),
  CONSTRAINT "chk_instancia_academica_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "instancia_academica_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."instancia_academica"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."instancia_academica" FROM "anon";

CREATE TABLE "public"."periodo_escolar" (
  "id"                     uuid                  NOT NULL DEFAULT gen_random_uuid(),
  "nombre_periodo_escolar" character varying(50) NOT NULL,
  "fecha_inicio"           date                  NOT NULL,
  "fecha_fin"              date                  NOT NULL,
  "activo"                 boolean               NOT NULL DEFAULT true,
  CONSTRAINT "chk_periodo_escolar_fechas" CHECK ((fecha_fin > fecha_inicio)),
  CONSTRAINT "chk_periodo_escolar_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre_periodo_escolar)) > 0)),
  CONSTRAINT "periodo_escolar_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_periodo_escolar_nombre" UNIQUE (nombre_periodo_escolar)
);

ALTER TABLE "public"."periodo_escolar"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."periodo_escolar" FROM "anon";

CREATE TABLE "public"."tipo_evento" (
  "id"     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo" character varying(20)  NOT NULL,
  "nombre" character varying(100) NOT NULL,
  "activo" boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_tipo_evento_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_tipo_evento_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "tipo_evento_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_tipo_evento_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_tipo_evento_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."tipo_evento"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tipo_evento" FROM "anon";

ALTER TABLE "public"."instancia_academica"
  ADD CONSTRAINT "fk_instancia_academica_detalle_plan" FOREIGN KEY (id_detalle_plan_academico) REFERENCES public.detalle_plan_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."grupo"
  ADD CONSTRAINT "fk_grupo_instancia_academica" FOREIGN KEY (id_instancia_academica) REFERENCES public.instancia_academica(id) ON DELETE RESTRICT;

ALTER TABLE "public"."feriado"
  ADD CONSTRAINT "fk_feriado_periodo_escolar" FOREIGN KEY (id_periodo_escolar) REFERENCES public.periodo_escolar(id) ON DELETE RESTRICT;

ALTER TABLE "public"."instancia_academica"
  ADD CONSTRAINT "fk_instancia_academica_periodo_escolar" FOREIGN KEY (id_periodo_escolar) REFERENCES public.periodo_escolar(id) ON DELETE RESTRICT;

ALTER TABLE "public"."feriado"
  ADD CONSTRAINT "fk_feriado_tipo_evento" FOREIGN KEY (id_tipo_evento) REFERENCES public.tipo_evento(id) ON DELETE RESTRICT;

CREATE INDEX idx_feriado_periodo_escolar ON public.feriado USING btree (id_periodo_escolar);

CREATE INDEX idx_feriado_tipo_evento ON public.feriado USING btree (id_tipo_evento);

CREATE INDEX idx_grupo_instancia ON public.grupo USING btree (id_instancia_academica);

CREATE INDEX idx_instancia_academica_detalle_plan ON public.instancia_academica USING btree (id_detalle_plan_academico);

CREATE INDEX idx_instancia_academica_periodo ON public.instancia_academica USING btree (id_periodo_escolar);

CREATE POLICY "policy_feriado_delete" ON "public"."feriado"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('feriado'::text, 'delete'::text));

CREATE POLICY "policy_feriado_insert" ON "public"."feriado"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('feriado'::text, 'insert'::text));

CREATE POLICY "policy_feriado_select" ON "public"."feriado"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('feriado'::text, 'select'::text));

CREATE POLICY "policy_feriado_update" ON "public"."feriado"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('feriado'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('feriado'::text, 'update'::text));

CREATE POLICY "policy_grupo_delete" ON "public"."grupo"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('grupo'::text, 'delete'::text));

CREATE POLICY "policy_grupo_insert" ON "public"."grupo"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('grupo'::text, 'insert'::text));

CREATE POLICY "policy_grupo_select" ON "public"."grupo"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('grupo'::text, 'select'::text));

CREATE POLICY "policy_grupo_update" ON "public"."grupo"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('grupo'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('grupo'::text, 'update'::text));

CREATE POLICY "policy_instancia_academica_delete" ON "public"."instancia_academica"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('instancia_academica'::text, 'delete'::text));

CREATE POLICY "policy_instancia_academica_insert" ON "public"."instancia_academica"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('instancia_academica'::text, 'insert'::text));

CREATE POLICY "policy_instancia_academica_select" ON "public"."instancia_academica"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('instancia_academica'::text, 'select'::text));

CREATE POLICY "policy_instancia_academica_update" ON "public"."instancia_academica"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('instancia_academica'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('instancia_academica'::text, 'update'::text));

CREATE POLICY "policy_periodo_escolar_delete" ON "public"."periodo_escolar"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('periodo_escolar'::text, 'delete'::text));

CREATE POLICY "policy_periodo_escolar_insert" ON "public"."periodo_escolar"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('periodo_escolar'::text, 'insert'::text));

CREATE POLICY "policy_periodo_escolar_select" ON "public"."periodo_escolar"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('periodo_escolar'::text, 'select'::text));

CREATE POLICY "policy_periodo_escolar_update" ON "public"."periodo_escolar"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('periodo_escolar'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('periodo_escolar'::text, 'update'::text));

CREATE POLICY "policy_tipo_evento_delete" ON "public"."tipo_evento"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_evento'::text, 'delete'::text));

CREATE POLICY "policy_tipo_evento_insert" ON "public"."tipo_evento"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('tipo_evento'::text, 'insert'::text));

CREATE POLICY "policy_tipo_evento_select" ON "public"."tipo_evento"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('tipo_evento'::text, 'select'::text));

CREATE POLICY "policy_tipo_evento_update" ON "public"."tipo_evento"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_evento'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('tipo_evento'::text, 'update'::text));

REVOKE ALL ON TABLE "public"."feriado" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."feriado" TO "authenticated";

REVOKE ALL ON TABLE "public"."feriado" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."feriado" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."feriado" TO "service_role";

REVOKE ALL ON TABLE "public"."grupo" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."grupo" TO "authenticated";

REVOKE ALL ON TABLE "public"."grupo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."grupo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."grupo" TO "service_role";

REVOKE ALL ON TABLE "public"."instancia_academica" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."instancia_academica" TO "authenticated";

REVOKE ALL ON TABLE "public"."instancia_academica" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."instancia_academica" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."instancia_academica" TO "service_role";

REVOKE ALL ON TABLE "public"."periodo_escolar" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."periodo_escolar" TO "authenticated";

REVOKE ALL ON TABLE "public"."periodo_escolar" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."periodo_escolar" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."periodo_escolar" TO "service_role";

REVOKE ALL ON TABLE "public"."tipo_evento" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tipo_evento" TO "authenticated";

REVOKE ALL ON TABLE "public"."tipo_evento" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_evento" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_evento" TO "service_role";
