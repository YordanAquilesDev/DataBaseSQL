-- =====================================================================
-- APUNTES DE COMANDOS DCL (Data Control Language)
-- Autor: yordan_dev
-- =====================================================================
-- REGLA DE ORO 1: El comando GRANT asigna permisos de operación a un USUARIO.
-- REGLA DE ORO 2: Previamente DEBE haberse creado el LOGIN en el servidor y su USUARIO en la BD.
-- REGLA DE ORO 3: GRANT aplica a UN solo objeto (tabla/vista) a la vez. Los ROLES agrupan permisos.



-- =================================================================
-- COMANDO 1: GRANT (Otorgar / Dar accesos)
-- REGLA: Varios permisos, a varios usuarios, pero sobre UNA sola tabla.
-- ----------------------------------------------------------
-- Caso A: Permiso estándar en una tabla completa
-- Permite a yordan_dev leer datos de la tabla de auditoría.
GRANT SELECT ON TablaAuditoria TO yordan_dev;

-- Caso B: Permisos avanzados usando una VISTA (Seguridad Quirúrgica)
-- No le damos permiso a la tabla "Perfil" directamente para evitar que vea datos ajenos.
-- Le damos GRANT a una vista que filtra automáticamente para que solo altere SU propia fila.
GRANT SELECT, INSERT, UPDATE ON Vista_MiPerfil TO yordan_dev;

--  El Rol ahora tiene poder solo sobre la tabla Perfil
GRANT SELECT, INSERT, UPDATE, DELETE ON Perfil TO Rol_Desarrollador;


-- =================================================================
-- COMANDO 2: REVOKE (Quitar / Retirar accesos previos)
-- REGLA: Elimina un GRANT otorgado antes. No bloquea, solo "borra" el permiso.
-- ----------------------------------------------------------
-- El negocio cambia y yordan_dev ya no debe insertar perfiles, solo ver y editar.
-- Quitamos limpiamente el INSERT, pero el SELECT y UPDATE siguen activos.
REVOKE INSERT ON Vista_MiPerfil FROM yordan_dev;



-- =================================================================
-- COMANDO 3: DENY (Prohibir Explícitamente)
-- REGLA: Bloqueo absoluto. El DENY destruye cualquier GRANT.
-- ----------------------------------------------------------

-- Por seguridad extrema, yordan_dev JAMÁS debe ver la tabla de salarios,
-- incluso si por error alguien lo mete a un rol de administradores.
DENY SELECT ON TablaSalarios TO yordan_dev;


