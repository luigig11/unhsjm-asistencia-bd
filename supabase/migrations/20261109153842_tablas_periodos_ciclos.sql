SET local check_function_bodies = off;

CREATE TABLE "public"."ciclo_academico" (
  "id"     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo" character varying(20)  NOT NULL,
  "nombre" character varying(100) NOT NULL,
  "orden"  smallint               NOT NULL,
  "activo" boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_ciclo_academico_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_ciclo_academico_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "chk_ciclo_academico_orden" CHECK (((orden > 0) AND (orden <= 10))),
  CONSTRAINT "ciclo_academico_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_ciclo_academico_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_ciclo_academico_nombre" UNIQUE (nombre),
  CONSTRAINT "uq_ciclo_academico_orden" UNIQUE (orden)
);

ALTER TABLE "public"."ciclo_academico"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."ciclo_academico" FROM "anon";

CREATE TABLE "public"."periodo_academico" (
  "id"                        uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_tipo_periodo_academico" uuid                   NOT NULL,
  "codigo"                    character varying(20)  NOT NULL,
  "nombre"                    character varying(100) NOT NULL,
  "orden"                     smallint               NOT NULL,
  "activo"                    boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_periodo_academico_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_periodo_academico_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "chk_periodo_academico_orden" CHECK ((orden > 0)),
  CONSTRAINT "periodo_academico_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_periodo_academico_tipo_codigo" UNIQUE (id_tipo_periodo_academico, codigo),
  CONSTRAINT "uq_periodo_academico_tipo_orden" UNIQUE (id_tipo_periodo_academico, orden)
);

ALTER TABLE "public"."periodo_academico"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."periodo_academico" FROM "anon";

CREATE TABLE "public"."tipo_periodo_academico" (
  "id"                    uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo"                character varying(20)  NOT NULL,
  "nombre"                character varying(100) NOT NULL,
  "duracion_meses_minimo" smallint               NOT NULL,
  "duracion_meses_maximo" smallint               NOT NULL,
  "duracion_horas_minimo" smallint               NOT NULL,
  "duracion_horas_maximo" smallint               NOT NULL,
  "activo"                boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_tipo_periodo_academico_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_tipo_periodo_academico_horas_max" CHECK ((duracion_horas_maximo >= duracion_horas_minimo)),
  CONSTRAINT "chk_tipo_periodo_academico_horas_min" CHECK ((duracion_horas_minimo > 0)),
  CONSTRAINT "chk_tipo_periodo_academico_meses_max" CHECK ((duracion_meses_maximo >= duracion_meses_minimo)),
  CONSTRAINT "chk_tipo_periodo_academico_meses_min" CHECK ((duracion_meses_minimo > 0)),
  CONSTRAINT "chk_tipo_periodo_academico_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "tipo_periodo_academico_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_tipo_periodo_academico_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_tipo_periodo_academico_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."tipo_periodo_academico"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tipo_periodo_academico" FROM "anon";

CREATE OR REPLACE FUNCTION public.esta_autenticado()
  RETURNS boolean
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
BEGIN
    IF auth.uid() IS NULL THEN
        RETURN false;
    END IF;

    RETURN EXISTS (
        SELECT 1
        FROM public.usuario u
        JOIN public.rol r ON r.id = u.id_rol
        WHERE u.id_user = auth.uid()
          AND u.activo = true
          AND r.activo = true
    );
END;
$function$;

CREATE OR REPLACE FUNCTION public.esta_autorizado (
  p_resource text,
  p_op       text
)
  RETURNS boolean
  LANGUAGE plpgsql
  STABLE
  SECURITY DEFINER
  AS $function$
DECLARE
    v_op text := lower(trim(p_op));
    v_resource text := lower(trim(p_resource));
    v_role_id uuid;
BEGIN
    IF NOT public.esta_autenticado() THEN
        RETURN false;
    END IF;

    IF v_op NOT IN ('select', 'insert', 'update', 'delete') THEN
        RETURN false;
    END IF;

    IF v_resource IS NULL OR length(v_resource) = 0 THEN
        RETURN false;
    END IF;

    SELECT u.id_rol
    INTO v_role_id
    FROM public.usuario u
    WHERE u.id_user = auth.uid()
      AND u.activo = true;

    IF v_role_id IS NULL THEN
        RETURN false;
    END IF;

    RETURN EXISTS (
        SELECT 1
        FROM public.permiso pr
        WHERE pr.id_rol = v_role_id
          AND pr.entidad = v_resource
          AND pr.activo = true
          AND v_op::tipo_operacion = ANY(pr.operaciones_permitidas)
    );
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_permiso_fecha_actualizacion()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
    NEW.fecha_actualizacion = now();
    RETURN NEW;
END;
$function$;

ALTER TABLE "public"."periodo_academico"
  ADD CONSTRAINT "fk_periodo_academico_tipo" FOREIGN KEY (id_tipo_periodo_academico) REFERENCES public.tipo_periodo_academico(id) ON DELETE RESTRICT;

CREATE INDEX idx_periodo_academico_tipo ON public.periodo_academico USING btree (id_tipo_periodo_academico);

CREATE POLICY "policy_ciclo_academico_delete" ON "public"."ciclo_academico"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('ciclo_academico'::text, 'delete'::text));

CREATE POLICY "policy_ciclo_academico_insert" ON "public"."ciclo_academico"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('ciclo_academico'::text, 'insert'::text));

CREATE POLICY "policy_ciclo_academico_select" ON "public"."ciclo_academico"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('ciclo_academico'::text, 'select'::text));

CREATE POLICY "policy_ciclo_academico_update" ON "public"."ciclo_academico"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('ciclo_academico'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('ciclo_academico'::text, 'update'::text));

CREATE POLICY "policy_periodo_academico_delete" ON "public"."periodo_academico"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('periodo_academico'::text, 'delete'::text));

CREATE POLICY "policy_periodo_academico_insert" ON "public"."periodo_academico"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('periodo_academico'::text, 'insert'::text));

CREATE POLICY "policy_periodo_academico_select" ON "public"."periodo_academico"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('periodo_academico'::text, 'select'::text));

CREATE POLICY "policy_periodo_academico_update" ON "public"."periodo_academico"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('periodo_academico'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('periodo_academico'::text, 'update'::text));

CREATE POLICY "policy_tipo_periodo_academico_delete" ON "public"."tipo_periodo_academico"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_periodo_academico'::text, 'delete'::text));

CREATE POLICY "policy_tipo_periodo_academico_insert" ON "public"."tipo_periodo_academico"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('tipo_periodo_academico'::text, 'insert'::text));

CREATE POLICY "policy_tipo_periodo_academico_select" ON "public"."tipo_periodo_academico"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('tipo_periodo_academico'::text, 'select'::text));

CREATE POLICY "policy_tipo_periodo_academico_update" ON "public"."tipo_periodo_academico"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('tipo_periodo_academico'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('tipo_periodo_academico'::text, 'update'::text));

REVOKE ALL ON TABLE "public"."ciclo_academico" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."ciclo_academico" TO "authenticated";

REVOKE ALL ON TABLE "public"."ciclo_academico" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ciclo_academico" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ciclo_academico" TO "service_role";

REVOKE ALL ON TABLE "public"."periodo_academico" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."periodo_academico" TO "authenticated";

REVOKE ALL ON TABLE "public"."periodo_academico" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."periodo_academico" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."periodo_academico" TO "service_role";

REVOKE ALL ON TABLE "public"."tipo_periodo_academico" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."tipo_periodo_academico" TO "authenticated";

REVOKE ALL ON TABLE "public"."tipo_periodo_academico" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_periodo_academico" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_periodo_academico" TO "service_role";
