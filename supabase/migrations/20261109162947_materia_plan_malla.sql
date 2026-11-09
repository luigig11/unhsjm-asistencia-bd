CREATE TABLE "public"."centro_universitario" (
  "id"        uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo"    character varying(20)  NOT NULL,
  "nombre"    character varying(150) NOT NULL,
  "ubicacion" character varying(200),
  "activo"    boolean                NOT NULL DEFAULT true,
  CONSTRAINT "centro_universitario_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_centro_universitario_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_centro_universitario_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "uq_centro_universitario_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_centro_universitario_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."centro_universitario"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."centro_universitario" FROM "anon";

CREATE TABLE "public"."detalle_plan_academico" (
  "id"                    uuid     NOT NULL DEFAULT gen_random_uuid(),
  "id_plan_academico"     uuid     NOT NULL,
  "id_ciclo_academico"    uuid     NOT NULL,
  "id_periodo_academico"  uuid     NOT NULL,
  "duracion_semanas"      smallint NOT NULL,
  "duracion_meses"        smallint NOT NULL,
  "id_detalle_predecesor" uuid,
  "activo"                boolean  NOT NULL DEFAULT true,
  CONSTRAINT "chk_detalle_plan_meses" CHECK (((duracion_meses > 0) AND (duracion_meses <= 12))),
  CONSTRAINT "chk_detalle_plan_predecesor" CHECK (((id_detalle_predecesor IS NULL) OR (id_detalle_predecesor <> id))),
  CONSTRAINT "chk_detalle_plan_semanas" CHECK (((duracion_semanas > 0) AND (duracion_semanas <= 52))),
  CONSTRAINT "detalle_plan_academico_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_detalle_plan_bloque" UNIQUE (id_plan_academico, id_ciclo_academico, id_periodo_academico)
);

ALTER TABLE "public"."detalle_plan_academico"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."detalle_plan_academico" FROM "anon";

CREATE TABLE "public"."malla_curricular" (
  "id"                        uuid         NOT NULL DEFAULT gen_random_uuid(),
  "id_detalle_plan_academico" uuid         NOT NULL,
  "id_materia"                uuid         NOT NULL,
  "encuentros_totales"        smallint     NOT NULL,
  "encuentros_por_semana"     smallint     NOT NULL,
  "cantidad_horas_materia"    numeric(5,2) NOT NULL,
  "creditos"                  smallint     NOT NULL,
  "obligatoria"               boolean      NOT NULL DEFAULT true,
  "activo"                    boolean      NOT NULL DEFAULT true,
  CONSTRAINT "chk_malla_curricular_creditos" CHECK ((creditos > 0)),
  CONSTRAINT "chk_malla_curricular_encuentros_semana" CHECK (((encuentros_por_semana > 0) AND (encuentros_por_semana <= 7) AND (encuentros_totales >= encuentros_por_semana))),
  CONSTRAINT "chk_malla_curricular_encuentros_totales" CHECK ((encuentros_totales > 0)),
  CONSTRAINT "chk_malla_curricular_horas" CHECK ((cantidad_horas_materia > (0)::numeric)),
  CONSTRAINT "malla_curricular_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_malla_curricular_bloque_materia" UNIQUE (id_detalle_plan_academico, id_materia)
);

ALTER TABLE "public"."malla_curricular"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."malla_curricular" FROM "anon";

CREATE TABLE "public"."materia_prerequisito" (
  "id"                                       uuid    NOT NULL DEFAULT gen_random_uuid(),
  "id_malla_curricular_materia"              uuid    NOT NULL,
  "id_malla_curricular_materia_prerequisito" uuid    NOT NULL,
  "activo"                                   boolean NOT NULL DEFAULT true,
  CONSTRAINT "chk_materia_prerequisito_distintos" CHECK ((id_malla_curricular_materia <> id_malla_curricular_materia_prerequisito)),
  CONSTRAINT "materia_prerequisito_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_materia_prerequisito" UNIQUE (id_malla_curricular_materia, id_malla_curricular_materia_prerequisito)
);

ALTER TABLE "public"."materia_prerequisito"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."materia_prerequisito" FROM "anon";

CREATE TABLE "public"."materia" (
  "id"     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo" character varying(25)  NOT NULL,
  "nombre" character varying(150) NOT NULL,
  "activo" boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_materia_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_materia_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "materia_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_materia_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_materia_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."materia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."materia" FROM "anon";

CREATE TABLE "public"."plan_academico" (
  "id"                         uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_centro_universitario"    uuid                   NOT NULL,
  "id_carrera"                 uuid                   NOT NULL,
  "id_tipo_periodo_academico"  uuid                   NOT NULL,
  "id_modalidad"               uuid                   NOT NULL,
  "codigo"                     character varying(30)  NOT NULL,
  "nombre"                     character varying(150) NOT NULL,
  "cantidad_ciclo_academico"   smallint               NOT NULL,
  "cantidad_periodo_academico" smallint               NOT NULL,
  "activo_desde"               date                   NOT NULL,
  "activo_hasta"               date,
  "activo"                     boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_plan_academico_cantidad_ciclo" CHECK ((cantidad_ciclo_academico > 0)),
  CONSTRAINT "chk_plan_academico_cantidad_periodo" CHECK ((cantidad_periodo_academico > 0)),
  CONSTRAINT "chk_plan_academico_fechas" CHECK (((activo_hasta IS NULL) OR (activo_hasta > activo_desde))),
  CONSTRAINT "chk_plan_academico_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "plan_academico_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_plan_academico_codigo" UNIQUE (codigo)
);

ALTER TABLE "public"."plan_academico"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."plan_academico" FROM "anon";

ALTER TABLE "public"."detalle_plan_academico"
  ADD CONSTRAINT "fk_detalle_plan_ciclo" FOREIGN KEY (id_ciclo_academico) REFERENCES public.ciclo_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."detalle_plan_academico"
  ADD CONSTRAINT "fk_detalle_plan_periodo" FOREIGN KEY (id_periodo_academico) REFERENCES public.periodo_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."detalle_plan_academico"
  ADD CONSTRAINT "fk_detalle_plan_predecesor" FOREIGN KEY (id_detalle_predecesor) REFERENCES public.detalle_plan_academico(id) ON DELETE SET NULL;

ALTER TABLE "public"."malla_curricular"
  ADD CONSTRAINT "fk_malla_curricular_detalle" FOREIGN KEY (id_detalle_plan_academico) REFERENCES public.detalle_plan_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."malla_curricular"
  ADD CONSTRAINT "fk_malla_curricular_materia" FOREIGN KEY (id_materia) REFERENCES public.materia(id) ON DELETE RESTRICT;

ALTER TABLE "public"."materia_prerequisito"
  ADD CONSTRAINT "fk_prerequisito_materia_pre" FOREIGN KEY (id_malla_curricular_materia_prerequisito) REFERENCES public.malla_curricular(id) ON DELETE RESTRICT;

ALTER TABLE "public"."materia_prerequisito"
  ADD CONSTRAINT "fk_prerequisito_materia" FOREIGN KEY (id_malla_curricular_materia) REFERENCES public.malla_curricular(id) ON DELETE CASCADE;

ALTER TABLE "public"."plan_academico"
  ADD CONSTRAINT "fk_plan_academico_carrera" FOREIGN KEY (id_carrera) REFERENCES public.carrera(id) ON DELETE RESTRICT;

ALTER TABLE "public"."plan_academico"
  ADD CONSTRAINT "fk_plan_academico_centro" FOREIGN KEY (id_centro_universitario) REFERENCES public.centro_universitario(id) ON DELETE RESTRICT;

ALTER TABLE "public"."plan_academico"
  ADD CONSTRAINT "fk_plan_academico_modalidad" FOREIGN KEY (id_modalidad) REFERENCES public.modalidad(id) ON DELETE RESTRICT;

ALTER TABLE "public"."plan_academico"
  ADD CONSTRAINT "fk_plan_academico_tipo_periodo" FOREIGN KEY (id_tipo_periodo_academico) REFERENCES public.tipo_periodo_academico(id) ON DELETE RESTRICT;

ALTER TABLE "public"."detalle_plan_academico"
  ADD CONSTRAINT "fk_detalle_plan_plan" FOREIGN KEY (id_plan_academico) REFERENCES public.plan_academico(id) ON DELETE RESTRICT;

CREATE INDEX idx_detalle_plan_ciclo ON public.detalle_plan_academico USING btree (id_ciclo_academico);

CREATE INDEX idx_detalle_plan_periodo ON public.detalle_plan_academico USING btree (id_periodo_academico);

CREATE INDEX idx_detalle_plan_plan ON public.detalle_plan_academico USING btree (id_plan_academico);

CREATE INDEX idx_detalle_plan_predecesor ON public.detalle_plan_academico USING btree (id_detalle_predecesor);

CREATE INDEX idx_malla_curricular_detalle ON public.malla_curricular USING btree (id_detalle_plan_academico);

CREATE INDEX idx_malla_curricular_materia ON public.malla_curricular USING btree (id_materia);

CREATE INDEX idx_materia_prerequisito_materia_pre ON public.materia_prerequisito USING btree (id_malla_curricular_materia_prerequisito);

CREATE INDEX idx_materia_prerequisito_materia ON public.materia_prerequisito USING btree (id_malla_curricular_materia);

CREATE INDEX idx_plan_academico_carrera ON public.plan_academico USING btree (id_carrera);

CREATE INDEX idx_plan_academico_centro ON public.plan_academico USING btree (id_centro_universitario);

CREATE INDEX idx_plan_academico_modalidad ON public.plan_academico USING btree (id_modalidad);

CREATE INDEX idx_plan_academico_tipo_periodo ON public.plan_academico USING btree (id_tipo_periodo_academico);

CREATE POLICY "policy_centro_universitario_delete" ON "public"."centro_universitario"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('centro_universitario'::text, 'delete'::text));

CREATE POLICY "policy_centro_universitario_insert" ON "public"."centro_universitario"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('centro_universitario'::text, 'insert'::text));

CREATE POLICY "policy_centro_universitario_select" ON "public"."centro_universitario"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('centro_universitario'::text, 'select'::text));

CREATE POLICY "policy_centro_universitario_update" ON "public"."centro_universitario"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('centro_universitario'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('centro_universitario'::text, 'update'::text));

CREATE POLICY "policy_detalle_plan_academico_delete" ON "public"."detalle_plan_academico"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('detalle_plan_academico'::text, 'delete'::text));

CREATE POLICY "policy_detalle_plan_academico_insert" ON "public"."detalle_plan_academico"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('detalle_plan_academico'::text, 'insert'::text));

CREATE POLICY "policy_detalle_plan_academico_select" ON "public"."detalle_plan_academico"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('detalle_plan_academico'::text, 'select'::text));

CREATE POLICY "policy_detalle_plan_academico_update" ON "public"."detalle_plan_academico"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('detalle_plan_academico'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('detalle_plan_academico'::text, 'update'::text));

CREATE POLICY "policy_malla_curricular_delete" ON "public"."malla_curricular"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('malla_curricular'::text, 'delete'::text));

CREATE POLICY "policy_malla_curricular_insert" ON "public"."malla_curricular"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('malla_curricular'::text, 'insert'::text));

CREATE POLICY "policy_malla_curricular_select" ON "public"."malla_curricular"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('malla_curricular'::text, 'select'::text));

CREATE POLICY "policy_malla_curricular_update" ON "public"."malla_curricular"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('malla_curricular'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('malla_curricular'::text, 'update'::text));

CREATE POLICY "policy_materia_delete" ON "public"."materia"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('materia'::text, 'delete'::text));

CREATE POLICY "policy_materia_insert" ON "public"."materia"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('materia'::text, 'insert'::text));

CREATE POLICY "policy_materia_select" ON "public"."materia"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('materia'::text, 'select'::text));

CREATE POLICY "policy_materia_update" ON "public"."materia"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('materia'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('materia'::text, 'update'::text));

CREATE POLICY "policy_materia_prerequisito_delete" ON "public"."materia_prerequisito"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('materia_prerequisito'::text, 'delete'::text));

CREATE POLICY "policy_materia_prerequisito_insert" ON "public"."materia_prerequisito"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('materia_prerequisito'::text, 'insert'::text));

CREATE POLICY "policy_materia_prerequisito_select" ON "public"."materia_prerequisito"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('materia_prerequisito'::text, 'select'::text));

CREATE POLICY "policy_materia_prerequisito_update" ON "public"."materia_prerequisito"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('materia_prerequisito'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('materia_prerequisito'::text, 'update'::text));

CREATE POLICY "policy_plan_academico_delete" ON "public"."plan_academico"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('plan_academico'::text, 'delete'::text));

CREATE POLICY "policy_plan_academico_insert" ON "public"."plan_academico"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('plan_academico'::text, 'insert'::text));

CREATE POLICY "policy_plan_academico_select" ON "public"."plan_academico"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('plan_academico'::text, 'select'::text));

CREATE POLICY "policy_plan_academico_update" ON "public"."plan_academico"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('plan_academico'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('plan_academico'::text, 'update'::text));

REVOKE ALL ON TABLE "public"."centro_universitario" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."centro_universitario" TO "authenticated";

REVOKE ALL ON TABLE "public"."centro_universitario" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."centro_universitario" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."centro_universitario" TO "service_role";

REVOKE ALL ON TABLE "public"."detalle_plan_academico" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."detalle_plan_academico" TO "authenticated";

REVOKE ALL ON TABLE "public"."detalle_plan_academico" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."detalle_plan_academico" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."detalle_plan_academico" TO "service_role";

REVOKE ALL ON TABLE "public"."malla_curricular" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."malla_curricular" TO "authenticated";

REVOKE ALL ON TABLE "public"."malla_curricular" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."malla_curricular" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."malla_curricular" TO "service_role";

REVOKE ALL ON TABLE "public"."materia" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."materia" TO "authenticated";

REVOKE ALL ON TABLE "public"."materia" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia" TO "service_role";

REVOKE ALL ON TABLE "public"."materia_prerequisito" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."materia_prerequisito" TO "authenticated";

REVOKE ALL ON TABLE "public"."materia_prerequisito" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia_prerequisito" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."materia_prerequisito" TO "service_role";

REVOKE ALL ON TABLE "public"."plan_academico" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."plan_academico" TO "authenticated";

REVOKE ALL ON TABLE "public"."plan_academico" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."plan_academico" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."plan_academico" TO "service_role";
