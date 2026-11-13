ALTER TABLE "public"."estudiante"
  ADD COLUMN "codigo_unico" character varying(20) NOT NULL;

ALTER TABLE "public"."estudiante"
  ADD CONSTRAINT "chk_estudiante_codigo_unico" CHECK (((char_length(TRIM(BOTH FROM codigo_unico)) >= 6) AND (char_length(TRIM(BOTH FROM codigo_unico)) <= 20)));

ALTER TABLE "public"."estudiante"
  ADD CONSTRAINT "uq_estudiante_codigo_unico" UNIQUE (codigo_unico);
