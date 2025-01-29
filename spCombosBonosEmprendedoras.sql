/****** Object:  StoredProcedure [dbo].[spCombosBonosEmprendedoras]    Script Date: 28/01/2025 07:48:01 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Arturo Vargas Triujeque
-- Create date: 2022-12-22
-- Description:	Combos Modulo Bonos Emprendedoras

-- Author:				Gilberto Andrade
-- Modification date:	21/10/2024
-- Description:			Consistencia en mayúsculas y minúsculas: los nombres de columnas y tablas se mantienen consistentes y el uso de mayúsculas sigue las convenciones de SQL Server.
						--Indentación: el código está estructurado con indentación adecuada para facilitar su lectura.
						--Comentarios descriptivos: se han añadido comentarios para describir cada bloque de código según la opción elegida.
-- =============================================
-- [spCombosBonosEmprendedoras] 4, 2023
-- [spCombosBonosEmprendedoras] 5, 2024
-- [spCombosBonosEmprendedoras] 7, 1, 1
CREATE PROCEDURE [dbo].[spCombosBonosEmprendedoras]
    @opcion INT,
    @anio INT = 0,
	@tipoBono INT = 0
AS
BEGIN

    -- Opción 1: Selección de años de periodo
    IF @opcion = 1
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
        SELECT DISTINCT 
            CAST(FECPER_ANO_PERI AS VARCHAR) AS Id,
            CAST(FECPER_ANO_PERI AS VARCHAR) AS [Name]
        FROM SQL_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_ANO_PERI BETWEEN YEAR(GETDATE()) - 2 AND YEAR(GETDATE()) + 1;
    END

    -- Opción 2: Años de periodo entre el año actual y el próximo
    IF @opcion = 2
    BEGIN
        SELECT DISTINCT 
            CAST(FECPER_ANO_PERI AS VARCHAR) AS Id,
            CAST(FECPER_ANO_PERI AS VARCHAR) AS [Name]
        FROM Sql_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_ANO_PERI BETWEEN YEAR(GETDATE()) AND YEAR(GETDATE()) + 1;
    END

    -- Opción 3: Niveles de bonos
    IF @opcion = 3
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
        SELECT P_NIVEL AS Id, P_NOMBRENIVEL AS [Name]
        FROM Sql_Ventas.dbo.P_PARAMETROSELITE (NOLOCK);
    END

    -- Opción 4: Periodos por año específico
    IF @opcion = 4
    BEGIN
        SELECT DISTINCT FECPER_NUM_PERI AS Id, FECPER_NUM_PERI AS [Name]
        FROM Sql_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_FECHA_FIN >= '2023/01/01'
            AND FECPER_ANO_PERI = @anio;
    END

    -- Opción 5: Periodos de un año específico sin fecha de fin
    IF @opcion = 5
    BEGIN
        SELECT DISTINCT FECPER_NUM_PERI AS Id, FECPER_NUM_PERI AS [Name]
        FROM Sql_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_ANO_PERI = CASE WHEN @anio IS NULL THEN YEAR(GETDATE()) ELSE @anio END;
    END

    -- Opción 6: Tipos de bonos disponibles
    IF @opcion = 6
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
        SELECT IDTipoBono, Descripcion FROM SQL_Ventas.dbo.P_Cat_TipoBono (NOLOCK)
    END

    -- Opción 7: Metas para invitadas
    IF @opcion = 7
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
		SELECT IDTipoBonoConfiguracion, Descripcion FROM SQL_Ventas.dbo.P_Cat_TipoBonoConfiguracion (NOLOCK) WHERE IDTipoBono = @tipoBono
    END

	-- Opción 8: Año y Campaña Actual
	IF @opcion = 8
	BEGIN
		SELECT FECPER_ANO_PERI AS Anio, FECPER_NUM_PERI AS Campania 
		FROM SQL_VENTAS.DBO.V_PERIODOS (NOLOCK) 
		WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI = 'CA' AND '2025/01/01' BETWEEN CAST(FECPER_FECHA_INI AS DATE) AND CAST(FECPER_FECHA_FIN AS DATE)
		--WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI = 'CA' AND GETDATE() BETWEEN CAST(FECPER_FECHA_INI AS DATE) AND CAST(FECPER_FECHA_FIN AS DATE)
	END
END
GO