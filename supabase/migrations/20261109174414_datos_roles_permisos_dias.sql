-- ============================================================================
-- SIEMBRA IDEMPOTENTE DE DATOS MAESTROS Y RBAC
-- Sistema de Gestión Universitaria
-- ============================================================================

-- 1. Siembra de Catálogo: Días de la semana (ISO 1 a 7)
INSERT INTO dia (id, nombre)
VALUES
    (1, 'Lunes'),
    (2, 'Martes'),
    (3, 'Miércoles'),
    (4, 'Jueves'),
    (5, 'Viernes'),
    (6, 'Sábado'),
    (7, 'Domingo')
ON CONFLICT (id) DO UPDATE
SET nombre = EXCLUDED.nombre;

-- 2. Siembra de Roles del Sistema
INSERT INTO rol (code, nombre, activo)
VALUES
    ('ADMIN', 'Administrador', true),
    ('DIRECTOR', 'Director', true),
    ('DOCENTE', 'Docente', true)
ON CONFLICT (code) DO UPDATE
SET nombre = EXCLUDED.nombre,
    activo = EXCLUDED.activo;

-- 3. Siembra de Matriz de Permisos (94 registros sobre 32 tablas)
DO $$
DECLARE
    v_admin_id UUID;
    v_director_id UUID;
    v_docente_id UUID;
BEGIN
    SELECT id INTO v_admin_id FROM rol WHERE code = 'ADMIN';
    SELECT id INTO v_director_id FROM rol WHERE code = 'DIRECTOR';
    SELECT id INTO v_docente_id FROM rol WHERE code = 'DOCENTE';

    -- ------------------------------------------------------------------------
    -- 3.1 Permisos para ADMINISTRADOR (32 tablas con privilegios completos)
    -- ------------------------------------------------------------------------
    INSERT INTO permiso (id_rol, entidad, operaciones_permitidas, activo)
    VALUES
        (v_admin_id, 'direccion', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'carrera', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'modalidad', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'tipo_periodo_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'periodo_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'ciclo_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'materia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'centro_universitario', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'plan_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'detalle_plan_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'malla_curricular', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'materia_prerequisito', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'tipo_evento', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'periodo_escolar', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'feriado', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'instancia_academica', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'tipo_aula', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'aula', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'docente', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'estudiante', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'materia_por_grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'dia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'calendario_semanal', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'calendario', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'inscripcion_grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'motivo_ausencia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'asistencia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'asistencia_detalle', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'rol', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'permiso', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_admin_id, 'usuario', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true)
    ON CONFLICT (id_rol, entidad) DO UPDATE
    SET operaciones_permitidas = EXCLUDED.operaciones_permitidas,
        activo = EXCLUDED.activo,
        fecha_actualizacion = now();

    -- ------------------------------------------------------------------------
    -- 3.2 Permisos para DIRECTOR (13 full CRUD + 18 solo SELECT = 31 registros)
    -- ------------------------------------------------------------------------
    INSERT INTO permiso (id_rol, entidad, operaciones_permitidas, activo)
    VALUES
        -- Solo SELECT (18 tablas)
        (v_director_id, 'direccion', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'carrera', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'modalidad', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'tipo_periodo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'periodo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'ciclo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'materia', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'centro_universitario', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'plan_academico', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'tipo_evento', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'periodo_escolar', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'feriado', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'instancia_academica', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'tipo_aula', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'aula', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'dia', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'rol', ARRAY['select']::tipo_operacion[], true),
        (v_director_id, 'permiso', ARRAY['select']::tipo_operacion[], true),
        -- Full CRUD (13 tablas)
        (v_director_id, 'detalle_plan_academico', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'malla_curricular', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'materia_prerequisito', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'docente', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'estudiante', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'materia_por_grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'calendario_semanal', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'calendario', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'inscripcion_grupo', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'motivo_ausencia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'asistencia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_director_id, 'asistencia_detalle', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true)
    ON CONFLICT (id_rol, entidad) DO UPDATE
    SET operaciones_permitidas = EXCLUDED.operaciones_permitidas,
        activo = EXCLUDED.activo,
        fecha_actualizacion = now();

    -- ------------------------------------------------------------------------
    -- 3.3 Permisos para DOCENTE (2 full CRUD + 29 solo SELECT = 31 registros)
    -- ------------------------------------------------------------------------
    INSERT INTO permiso (id_rol, entidad, operaciones_permitidas, activo)
    VALUES
        -- Full CRUD (2 tablas)
        (v_docente_id, 'asistencia', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        (v_docente_id, 'asistencia_detalle', ARRAY['select', 'insert', 'update', 'delete']::tipo_operacion[], true),
        -- Solo SELECT (29 tablas)
        (v_docente_id, 'direccion', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'carrera', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'modalidad', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'tipo_periodo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'periodo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'ciclo_academico', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'materia', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'centro_universitario', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'plan_academico', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'detalle_plan_academico', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'malla_curricular', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'materia_prerequisito', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'tipo_evento', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'periodo_escolar', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'feriado', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'instancia_academica', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'grupo', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'tipo_aula', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'aula', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'docente', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'estudiante', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'materia_por_grupo', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'dia', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'calendario_semanal', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'calendario', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'inscripcion_grupo', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'motivo_ausencia', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'rol', ARRAY['select']::tipo_operacion[], true),
        (v_docente_id, 'permiso', ARRAY['select']::tipo_operacion[], true)
    ON CONFLICT (id_rol, entidad) DO UPDATE
    SET operaciones_permitidas = EXCLUDED.operaciones_permitidas,
        activo = EXCLUDED.activo,
        fecha_actualizacion = now();

END $$;

