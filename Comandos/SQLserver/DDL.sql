-- =====================================================================
-- APUNTES DE COMANDOS DDL (Data Definition Language)
-- Autor: yordan_dev
-- =====================================================================
-- REGLA DE ORO 1: El CREATE LOGIN se crea a nivel global del Servidor (BD master).
-- REGLA DE ORO 2: El CREATE USER se crea a nivel local dentro de cada base de datos.
-- REGLA DE ORO 3: DDL define y altera ESTRUCTURAS (moldes). No manipula registros directamente.
-- REGLA DE ORO 4: Cuidado con las llaves foráneas; la tabla padre DEBE existir antes que la tabla hijo.


-- =================================================================
-- COMANDO 1: CREATE (Crear objetos estructurales)
-- REGLA: Construye desde cero bases de datos, tablas, vistas, logins o usuarios.
-- -----------------------------------------------------------------

-- Caso A: Crear la Base de Datos
CREATE DATABASE mi_perfil_profesional;
GO -- Forzar a que se cree la BD antes de continuar

-- Nos movemos a la base de datos recién creada
USE mi_perfil_profesional;

-- Caso B: Crear Tablas (Primero la Tabla Padre 'HerramientasProfesionales')
CREATE TABLE HerramientasProfesionales (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), -- UUID en SQL Server
    nombre VARCHAR(70) NOT NULL,
    usoProfesion VARCHAR(60) NULL
);

-- Ahora creamos la Tabla Hijo 'Perfil' (Ya existe la referencia)
CREATE TABLE Perfil (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    profesion VARCHAR(70) NOT NULL,
    ciclo VARCHAR(6) NULL,
    herramienta UNIQUEIDENTIFIER REFERENCES HerramientasProfesionales(id) -- FK directa
);

-- Caso C: Crear Vista (Corrección de alias 'h.id' y filtro dinámico)
CREATE VIEW Vista_MiPerfil AS 
SELECT p.id, p.nombre, p.apellido, p.profesion, p.ciclo, h.nombre AS herramienta_nombre
FROM Perfil p
INNER JOIN HerramientasProfesionales h ON p.herramienta = h.id
WHERE p.nombre = USER_NAME(); -- Filtro de seguridad por usuario de BD

-- Caso D: Crear Login (Nivel Servidor global)
USE master;
CREATE LOGIN login_yordan WITH PASSWORD = 'ContraseñaSegura123!';

-- Caso E: Crear Usuario (Mapeado en la BD específica)
USE mi_perfil_profesional;
CREATE USER yordan_dev FOR LOGIN login_yordan;
--Caso F: craer indice
CREATE INDEX ix_perfil_apellido Perfil(apellido);

--Caso G: craer procedimiento
CREATE PROCEDURE SP_InsertarPerfil
    @Nom VARCHAR(100), 
    @Ape VARCHAR(100),
     @Prof VARCHAR(70)
AS
BEGIN
    INSERT INTO Perfil(nombre, apellido, profesion) 
    VALUES (@Nom, @Ape, @Prof);
END;
--Caso H: craer trigger
CREATE TRIGGER TR_Perfil_Auditoria
ON Perfil
AFTER INSERT
AS
BEGIN
    PRINT '¡Alerta de Sistema: Se ha creado un nuevo perfil profesional!';
END;
--Caso I:
CREATE FUNCTION Fn_NombreCompleto (@Nom VARCHAR(100), @Ape VARCHAR(100))
RETURNS VARCHAR(200)
AS
BEGIN
    RETURN @Ape + ', ' + @Nom;
END;
--Caso J:
CREATE ROLE Rol_Desarrollador;

-- =================================================================
-- COMANDO 2: ALTER (Alterar o Modificar Estructuras existentes)
-- REGLA: Modifica columnas o restricciones SIN borrar el objeto completo.
-- -----------------------------------------------------------------

-- Caso A: Agregar una nueva columna a una tabla existente
ALTER TABLE Perfil ADD correo VARCHAR(150) NULL;

-- Caso B: Modificar el tipo de dato o restricción de una columna existente
ALTER TABLE Perfil ALTER COLUMN ciclo VARCHAR(10) NOT NULL;

-- Caso C: Eliminar una columna que ya no es necesaria
ALTER TABLE Perfil DROP COLUMN ciclo;

-- Caso D: Modificar una Vista existente (Usa ALTER VIEW para redefinirla)
ALTER VIEW Vista_MiPerfil AS 
SELECT p.id, p.nombre, p.apellido, p.profesion, h.nombre AS herramienta_nombre, p.correo
FROM Perfil p
INNER JOIN HerramientasProfesionales h ON p.herramienta = h.id
WHERE p.nombre = USER_NAME();


-- =================================================================
-- COMANDO 3: DROP (Eliminar Objetos por Completo)
-- REGLA: Destruye el objeto y todo su contenido de forma irreversible.
-- -----------------------------------------------------------------

-- Nota de Orden: Si borras la tabla padre antes que el hijo, dará error por la FK.
-- Primero se borra el objeto que depende de otros.

-- Caso A: Eliminar la vista
DROP VIEW Vista_MiPerfil;

-- Caso B: Eliminar la tabla hijo
DROP TABLE Perfil;

-- Caso C: Eliminar la tabla padre
DROP TABLE HerramientasProfesionales;

-- Caso D: Eliminar la Identidad Local (User) y el Acceso Global (Login)
USE mi_perfil_profesional;
DROP USER yordan_dev;

USE master;
DROP LOGIN login_yordan;

-- Caso E: Eliminar toda la Base de Datos (Debes estar fuera de ella)
USE master;
DROP DATABASE mi_perfil_profesional;


-- =================================================================
-- COMANDO BONUS DDL: TRUNCATE (Vaciar contenido estructural)
-- REGLA 1: Borra todos los registros instantáneamente liberando páginas de datos.
-- REGLA 2: Es DDL porque altera la estructura física de almacenamiento y reinicia contadores (IDENTITY).
-- REGLA 3: No permite la cláusula WHERE (Es todo o nada).
-- -----------------------------------------------------------------


--  Si intentas hacer TRUNCATE a una tabla padre que está siendo
-- referenciada por una Llave Foránea (FK) activa, el motor la bloqueará por seguridad.
-- Primero deberías truncar la tabla hijo.
TRUNCATE TABLE Perfil;                  -- Primero el hijo (Cumple)
TRUNCATE TABLE HerramientasProfesionales; -- Luego el padre (Cumple)