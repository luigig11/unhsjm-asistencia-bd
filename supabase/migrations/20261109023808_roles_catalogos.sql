SET local check_function_bodies = off;

CREATE TABLE "public"."carrera" (
  "id"           uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "id_direccion" uuid                   NOT NULL,
  "codigo"       character varying(20)  NOT NULL,
  "nombre"       character varying(150) NOT NULL,
  "activo"       boolean                NOT NULL DEFAULT true,
  CONSTRAINT "carrera_pkey" PRIMARY KEY (id),
  CONSTRAINT "chk_carrera_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_carrera_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "uq_carrera_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_carrera_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."carrera"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."direccion" (
  "id"     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo" character varying(20)  NOT NULL,
  "nombre" character varying(150) NOT NULL,
  "activo" boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_direccion_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_direccion_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "direccion_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_direccion_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_direccion_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."direccion"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."modalidad" (
  "id"     uuid                   NOT NULL DEFAULT gen_random_uuid(),
  "codigo" character varying(20)  NOT NULL,
  "nombre" character varying(100) NOT NULL,
  "activo" boolean                NOT NULL DEFAULT true,
  CONSTRAINT "chk_modalidad_codigo" CHECK ((char_length(TRIM(BOTH FROM codigo)) > 0)),
  CONSTRAINT "chk_modalidad_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "modalidad_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_modalidad_codigo" UNIQUE (codigo),
  CONSTRAINT "uq_modalidad_nombre" UNIQUE (nombre)
);

ALTER TABLE "public"."modalidad"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."permiso" (
  "id"      uuid                  NOT NULL DEFAULT gen_random_uuid(),
  "id_rol"  uuid                  NOT NULL,
  "entidad" character varying(60) NOT NULL,
  CONSTRAINT "chk_permiso_entidad" CHECK ((char_length(TRIM(BOTH FROM entidad)) > 0)),
  CONSTRAINT "permiso_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_permiso_rol_entidad" UNIQUE (id_rol, entidad)
);

ALTER TABLE "public"."permiso"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."rol" (
  "id"     uuid                  NOT NULL DEFAULT gen_random_uuid(),
  "code"   character varying(30) NOT NULL,
  "nombre" character varying(80) NOT NULL,
  "activo" boolean               NOT NULL DEFAULT true,
  CONSTRAINT "chk_rol_code" CHECK ((char_length(TRIM(BOTH FROM code)) > 0)),
  CONSTRAINT "chk_rol_nombre" CHECK ((char_length(TRIM(BOTH FROM nombre)) > 0)),
  CONSTRAINT "rol_pkey" PRIMARY KEY (id),
  CONSTRAINT "uq_rol_code" UNIQUE (code)
);

ALTER TABLE "public"."rol"
  ENABLE ROW LEVEL SECURITY;

CREATE TYPE "public"."tipo_operacion" AS ENUM (
  'CREATE',
  'READ',
  'UPDATE',
  'DELETE'
);

ALTER TABLE "public"."permiso"
  ADD COLUMN "operaciones_permitidas" public.tipo_operacion[] NOT NULL DEFAULT '{}'::public.tipo_operacion[];

ALTER TABLE "public"."permiso"
  ADD COLUMN "fecha_creacion" timestamp WITH time zone NOT NULL DEFAULT now();

ALTER TABLE "public"."permiso"
  ADD COLUMN "fecha_actualizacion" timestamp WITH time zone NOT NULL DEFAULT now();

ALTER TABLE "public"."permiso"
  ADD COLUMN "activo" boolean NOT NULL DEFAULT true;

CREATE OR REPLACE FUNCTION public.update_permiso_fecha_actualizacion()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
    NEW.fecha_actualizacion = now();
    RETURN NEW;
END;
$function$;

ALTER TABLE "public"."carrera"
  ADD CONSTRAINT "fk_carrera_direccion" FOREIGN KEY (id_direccion) REFERENCES public.direccion(id) ON DELETE RESTRICT;

ALTER TABLE "public"."permiso"
  ADD CONSTRAINT "chk_permiso_fechas" CHECK ((fecha_actualizacion >= fecha_creacion));

ALTER TABLE "public"."permiso"
  ADD CONSTRAINT "chk_permiso_operaciones"
    CHECK
    (((cardinality(operaciones_permitidas) > 0) AND (operaciones_permitidas <@ ARRAY['CREATE'::public.tipo_operacion, 'READ'::public.tipo_operacion,
    'UPDATE'::public.tipo_operacion, 'DELETE'::public.tipo_operacion])));

ALTER TABLE "public"."permiso"
  ADD CONSTRAINT "fk_permiso_rol" FOREIGN KEY (id_rol) REFERENCES public.rol(id) ON DELETE CASCADE;

CREATE INDEX idx_carrera_id_direccion ON public.carrera USING btree (id_direccion);

CREATE INDEX idx_permiso_entidad ON public.permiso USING btree (entidad);

CREATE INDEX idx_permiso_id_rol ON public.permiso USING btree (id_rol);

CREATE TRIGGER trg_permiso_fecha_actualizacion
  BEFORE UPDATE ON public.permiso
  FOR EACH ROW
  EXECUTE FUNCTION public.update_permiso_fecha_actualizacion();

GRANT EXECUTE ON FUNCTION "public"."update_permiso_fecha_actualizacion"() TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."update_permiso_fecha_actualizacion"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."update_permiso_fecha_actualizacion"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."update_permiso_fecha_actualizacion"() TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."carrera" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."carrera" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."carrera" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."carrera" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."direccion" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."direccion" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."direccion" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."direccion" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."modalidad" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."modalidad" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."modalidad" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."modalidad" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."permiso" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."permiso" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."permiso" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."permiso" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."rol" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."rol" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."rol" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."rol" TO "service_role";
