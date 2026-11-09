SET local check_function_bodies = off;

REVOKE ALL ON TABLE "public"."carrera" FROM "anon";

REVOKE ALL ON TABLE "public"."direccion" FROM "anon";

REVOKE ALL ON TABLE "public"."modalidad" FROM "anon";

CREATE TABLE "public"."usuario" (
  "id"       uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_user"  uuid,
  "id_rol"   uuid                   NOT NULL,
  "cedula"   character varying(20),
  "nombre"   character varying(100) NOT NULL,
  "apellido" character varying(100) NOT NULL,
  CONSTRAINT "chk_usuario_apellido" CHECK ((char_length(TRIM(BOTH FROM apellido)) > 0)),
  CONSTRAINT "chk_usuario_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "usuario_cedula_key" UNIQUE (cedula),
  CONSTRAINT "usuario_id_user_key" UNIQUE (id_user),
  CONSTRAINT "usuario_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."usuario"
  ENABLE ROW LEVEL SECURITY;

CREATE TYPE "public"."tipo_genero" AS ENUM (
  'F',
  'M'
);

ALTER TABLE "public"."usuario"
  ADD COLUMN "genero" public.tipo_genero NOT NULL;

ALTER TABLE "public"."usuario"
  ADD COLUMN "fecha_nacimiento" date;

ALTER TABLE "public"."usuario"
  ADD COLUMN "activo" boolean NOT NULL DEFAULT true;

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

ALTER TABLE "public"."usuario"
  ADD CONSTRAINT "chk_usuario_fecha_nacimiento" CHECK ((fecha_nacimiento < CURRENT_DATE));

ALTER TABLE "public"."usuario"
  ADD CONSTRAINT "chk_usuario_genero" CHECK ((genero = ANY (ARRAY['F'::public.tipo_genero, 'M'::public.tipo_genero])));

ALTER TABLE "public"."usuario"
  ADD CONSTRAINT "fk_usuario_rol" FOREIGN KEY (id_rol) REFERENCES public.rol(id) ON DELETE RESTRICT;

ALTER TABLE "public"."usuario"
  ADD CONSTRAINT "fk_usuario_user" FOREIGN KEY (id_user) REFERENCES auth.users(id) ON DELETE RESTRICT;

CREATE INDEX idx_usuario_id_rol ON public.usuario USING btree (id_rol);

CREATE INDEX idx_usuario_id_user ON public.usuario USING btree (id_user);

GRANT EXECUTE ON FUNCTION "public"."esta_autenticado"() TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."esta_autenticado"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."esta_autenticado"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."esta_autenticado"() TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."esta_autorizado"(text, text) TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."esta_autorizado"(text, text) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."esta_autorizado"(text, text) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."esta_autorizado"(text, text) TO "service_role";

REVOKE ALL ON TABLE "public"."carrera" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."carrera" TO "authenticated";

REVOKE ALL ON TABLE "public"."direccion" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."direccion" TO "authenticated";

REVOKE ALL ON TABLE "public"."modalidad" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."modalidad" TO "authenticated";

REVOKE ALL ON TABLE "public"."permiso" FROM "anon";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."permiso" TO "anon";

REVOKE ALL ON TABLE "public"."permiso" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."permiso" TO "authenticated";

REVOKE ALL ON TABLE "public"."rol" FROM "anon";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."rol" TO "anon";

REVOKE ALL ON TABLE "public"."rol" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."rol" TO "authenticated";

REVOKE ALL ON TABLE "public"."usuario" FROM "anon";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."usuario" TO "anon";

REVOKE ALL ON TABLE "public"."usuario" FROM "authenticated";

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE "public"."usuario" TO "authenticated";

REVOKE ALL ON TABLE "public"."usuario" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario" TO "service_role";
