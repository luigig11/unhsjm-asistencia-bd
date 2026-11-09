SET local check_function_bodies = off;

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

CREATE POLICY "policy_carrera_delete" ON "public"."carrera"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('carrera'::text, 'delete'::text));

CREATE POLICY "policy_carrera_insert" ON "public"."carrera"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('carrera'::text, 'insert'::text));

CREATE POLICY "policy_carrera_select" ON "public"."carrera"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('carrera'::text, 'select'::text));

CREATE POLICY "policy_carrera_update" ON "public"."carrera"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('carrera'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('carrera'::text, 'update'::text));

CREATE POLICY "policy_direccion_delete" ON "public"."direccion"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('direccion'::text, 'delete'::text));

CREATE POLICY "policy_direccion_insert" ON "public"."direccion"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('direccion'::text, 'insert'::text));

CREATE POLICY "policy_direccion_select" ON "public"."direccion"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('direccion'::text, 'select'::text));

CREATE POLICY "policy_direccion_update" ON "public"."direccion"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('direccion'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('direccion'::text, 'update'::text));

CREATE POLICY "policy_modalidad_delete" ON "public"."modalidad"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autorizado('modalidad'::text, 'delete'::text));

CREATE POLICY "policy_modalidad_insert" ON "public"."modalidad"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autorizado('modalidad'::text, 'insert'::text));

CREATE POLICY "policy_modalidad_select" ON "public"."modalidad"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autorizado('modalidad'::text, 'select'::text));

CREATE POLICY "policy_modalidad_update" ON "public"."modalidad"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autorizado('modalidad'::text, 'update'::text))
  WITH CHECK (public.esta_autorizado('modalidad'::text, 'update'::text));

CREATE POLICY "policy_permiso_anon_select" ON "public"."permiso"
  FOR SELECT
  TO "anon"
  USING ((activo = true));

CREATE POLICY "policy_permiso_delete" ON "public"."permiso"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_permiso_insert" ON "public"."permiso"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autenticado());

CREATE POLICY "policy_permiso_select" ON "public"."permiso"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_permiso_update" ON "public"."permiso"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autenticado())
  WITH CHECK (public.esta_autenticado());

CREATE POLICY "policy_rol_anon_select" ON "public"."rol"
  FOR SELECT
  TO "anon"
  USING ((activo = true));

CREATE POLICY "policy_rol_delete" ON "public"."rol"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_rol_insert" ON "public"."rol"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autenticado());

CREATE POLICY "policy_rol_select" ON "public"."rol"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_rol_update" ON "public"."rol"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autenticado())
  WITH CHECK (public.esta_autenticado());

CREATE POLICY "policy_usuario_anon_insert" ON "public"."usuario"
  FOR INSERT
  TO "anon"
  WITH CHECK ((activo = true));

CREATE POLICY "policy_usuario_anon_select" ON "public"."usuario"
  FOR SELECT
  TO "anon"
  USING ((activo = true));

CREATE POLICY "policy_usuario_delete" ON "public"."usuario"
  FOR DELETE
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_usuario_insert" ON "public"."usuario"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (public.esta_autenticado());

CREATE POLICY "policy_usuario_select" ON "public"."usuario"
  FOR SELECT
  TO "authenticated"
  USING (public.esta_autenticado());

CREATE POLICY "policy_usuario_update" ON "public"."usuario"
  FOR UPDATE
  TO "authenticated"
  USING (public.esta_autenticado())
  WITH CHECK (public.esta_autenticado());
