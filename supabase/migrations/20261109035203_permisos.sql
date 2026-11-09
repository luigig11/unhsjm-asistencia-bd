SET local check_function_bodies = off;

ALTER TABLE "public"."permiso"
  DROP CONSTRAINT "chk_permiso_operaciones";

ALTER TABLE "public"."permiso"
  ALTER COLUMN "operaciones_permitidas" DROP DEFAULT;

ALTER TYPE "public"."tipo_operacion" RENAME TO "tipo_operacion__pgdelta_replaced";

CREATE TYPE "public"."tipo_operacion" AS ENUM (
  'insert',
  'select',
  'update',
  'delete'
);

ALTER TABLE "public"."permiso"
  ALTER COLUMN "operaciones_permitidas" TYPE "public"."tipo_operacion"[] USING "operaciones_permitidas"::text[]::"public"."tipo_operacion"[];

DROP TYPE "public"."tipo_operacion__pgdelta_replaced";

ALTER TABLE "public"."permiso"
  ALTER COLUMN "operaciones_permitidas" SET DEFAULT '{}'::public.tipo_operacion[];

CREATE OR REPLACE FUNCTION public.update_permiso_fecha_actualizacion()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
    NEW.fecha_actualizacion = now();
    RETURN NEW;
END;
$function$;

ALTER TABLE "public"."permiso"
  ADD CONSTRAINT "chk_permiso_operaciones"
    CHECK
    (((cardinality(operaciones_permitidas) > 0) AND (operaciones_permitidas <@ ARRAY['select'::public.tipo_operacion, 'insert'::public.tipo_operacion,
    'update'::public.tipo_operacion, 'delete'::public.tipo_operacion])));
