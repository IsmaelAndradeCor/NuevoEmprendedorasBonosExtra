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
-- Description:			Consistencia en may�sculas y min�sculas: los nombres de columnas y tablas se mantienen consistentes y el uso de may�sculas sigue las convenciones de SQL Server.
						--Indentaci�n: el c�digo est� estructurado con indentaci�n adecuada para facilitar su lectura.
						--Comentarios descriptivos: se han a�adido comentarios para describir cada bloque de c�digo seg�n la opci�n elegida.
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

    -- Opci�n 1: Selecci�n de a�os de periodo
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

    -- Opci�n 2: A�os de periodo entre el a�o actual y el pr�ximo
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

    -- Opci�n 3: Niveles de bonos
    IF @opcion = 3
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
        SELECT P_NIVEL AS Id, P_NOMBRENIVEL AS [Name]
        FROM Sql_Ventas.dbo.P_PARAMETROSELITE (NOLOCK);
    END

    -- Opci�n 4: Periodos por a�o espec�fico
    IF @opcion = 4
    BEGIN
        SELECT DISTINCT FECPER_NUM_PERI AS Id, FECPER_NUM_PERI AS [Name]
        FROM Sql_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_FECHA_FIN >= '2023/01/01'
            AND FECPER_ANO_PERI = @anio;
    END

    -- Opci�n 5: Periodos de un a�o espec�fico sin fecha de fin
    IF @opcion = 5
    BEGIN
        SELECT DISTINCT FECPER_NUM_PERI AS Id, FECPER_NUM_PERI AS [Name]
        FROM Sql_Ventas.dbo.v_periodos (NOLOCK)
        WHERE FECPER_NUMCIA = 1 
            AND FECPER_TIPO_PERI = 'CA'
            AND FECPER_ANO_PERI = CASE WHEN @anio IS NULL THEN YEAR(GETDATE()) ELSE @anio END;
    END

    -- Opci�n 6: Tipos de bonos disponibles
    IF @opcion = 6
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
        SELECT IDTipoBono, Descripcion FROM SQL_Ventas.dbo.P_Cat_TipoBono (NOLOCK)
    END

    -- Opci�n 7: Metas para invitadas
    IF @opcion = 7
    BEGIN
        SELECT 0 AS Id, 'Selecciona...' AS [Name]
        UNION ALL
		SELECT IDTipoBonoConfiguracion, Descripcion FROM SQL_Ventas.dbo.P_Cat_TipoBonoConfiguracion (NOLOCK) WHERE IDTipoBono = @tipoBono
    END

	-- Opci�n 8: A�o y Campa�a Actual
	IF @opcion = 8
	BEGIN
		SELECT FECPER_ANO_PERI AS Anio, FECPER_NUM_PERI AS Campania 
		FROM SQL_VENTAS.DBO.V_PERIODOS (NOLOCK) 
		WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI = 'CA' AND '2025/01/01' BETWEEN CAST(FECPER_FECHA_INI AS DATE) AND CAST(FECPER_FECHA_FIN AS DATE)
		--WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI = 'CA' AND GETDATE() BETWEEN CAST(FECPER_FECHA_INI AS DATE) AND CAST(FECPER_FECHA_FIN AS DATE)
	END
END
GO