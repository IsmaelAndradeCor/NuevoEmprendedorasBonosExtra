USE [SQL_Ventas]
GO
/****** Object:  StoredProcedure [dbo].[spEvaluaBonosExtraEmpTrd]    Script Date: 10/02/2025 04:46:38 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--=================================================================
-- Nombre: spEvaluaBonosExtraEmpTrd
-- Descripción: Nueva evaluación de bonos extra emprendedor STH-11437 CONFIGURACIÓN DE BONOS EMPRENDEDORES
-- Fecha Creación: 2024/12/16
-- Responsable Creación: 
-- Fecha Modificación: 
-- Justificación: 
-- Responsable Modificación: 
-- Ejecución: Exec spEvaluaBonosExtraEmpTrd 
--=================================================================
ALTER   PROCEDURE [dbo].[spEvaluaBonosExtraEmpTrd](
@Año INT,
@campaña INT,
@Id INT
)
AS
BEGIN

	DECLARE @Dinamico VARCHAR(8000)
	DECLARE @Dinamico2 VARCHAR(8000)
	DECLARE @Dinamico3 VARCHAR(8000)
	DECLARE @Dinamico4 VARCHAR(8000)
	DECLARE @Dinamico14 VARCHAR(8000)
	DECLARE @tipo INT
	DECLARE @salto INT
	DECLARE @bono INT
	DECLARE @inicio INT
	DECLARE @Fin INT
	DECLARE @Auxd VARCHAR(1000)
	DECLARE @Aux INT
	DECLARE @Ant INT
	DECLARE @tipoConfiguracion INT
	DECLARE @Descripcion VARCHAR(100)

	SET @Dinamico = ''
	SET @Dinamico2 = ''
	SET @Dinamico3 = ''
	SET @Aux = 0
	SET @Ant = 0
	SET @Auxd = ''

	DECLARE @PeriodoActual INT, @PeriodoAnterior INT, @PeriodoDosAtras INT, @PeriodoTresAtras INT
	DECLARE @PedidoCalificadoActual NUMERIC(10,2), @PedidoCalificadoAnterior NUMERIC(10,2), @PedidoCalificadoDosAtras NUMERIC(10,2), @PedidoCalificadoTresAtras NUMERIC(10,2)
	DECLARE @FechaInicioTresAtras VARCHAR(10), @FechaFinTresAtras VARCHAR(10)

	SELECT		 @PedidoCalificadoActual = FECPER_PEDCAL,	@PeriodoActual = (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) FROM V_PERIODOS (NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI LIKE 'CA' AND FECPER_ANO_PERI = @Año AND FECPER_NUM_PERI = @campaña 
	SELECT TOP 1 @PedidoCalificadoAnterior = FECPER_PEDCAL,	@PeriodoAnterior = (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) FROM V_PERIODOS (NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI LIKE 'CA' AND FECPER_ANO_PERI * 100 + FECPER_NUM_PERI < @PeriodoActual ORDER BY (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) DESC
	SELECT TOP 1 @PedidoCalificadoDosAtras = FECPER_PEDCAL,	@PeriodoDosAtras = (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) FROM V_PERIODOS (NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI LIKE 'CA' AND FECPER_ANO_PERI * 100 + FECPER_NUM_PERI < @PeriodoAnterior ORDER BY (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) DESC
	SELECT TOP 1 @PedidoCalificadoTresAtras = FECPER_PEDCAL,@PeriodoTresAtras = (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) FROM V_PERIODOS (NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI LIKE 'CA' AND FECPER_ANO_PERI * 100 + FECPER_NUM_PERI < @PeriodoDosAtras ORDER BY (FECPER_ANO_PERI * 100 + FECPER_NUM_PERI) DESC

	SELECT @FechaInicioTresAtras = FECPER_FECHA_INI, @FechaFinTresAtras = FECPER_FECHA_FIN FROM V_PERIODOS (NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI LIKE 'CA' AND FECPER_ANO_PERI * 100 + FECPER_NUM_PERI = @PeriodoTresAtras

	--IF EXISTS(SELECT P_Region FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Incluir')
	--BEGIN
	--	Set @Dinamico2 = 'AND ('
	
	--	IF EXISTS(SELECT P_Zona FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Incluir' AND P_Zona = 0)
	--	BEGIN
	--		SET @Dinamico2 = @Dinamico2 + '(DEA_LOC_REGION IN(SELECT P_Region FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Incluir'' GROUP BY P_REGION))'
	
	--		IF EXISTS(SELECT P_Zona FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Incluir' AND P_Zona > 0)
	--		BEGIN
	--			SET @Dinamico2 = @Dinamico2 + ' OR (RIGHT(''0'' + CAST(DEA_LOC_REGION AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(DEA_LOC_ZONA AS VARCHAR), 2) IN(SELECT RIGHT(''0'' + CAST(P_Region AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(P_Zona AS VARCHAR), 2) FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Incluir''))'
	--		END
	--	SET @Dinamico2 = @Dinamico2 + ')'
	--	END
	--	ELSE
	--	BEGIN
	--		SET @Dinamico2 = @Dinamico2 + '(RIGHT(''0'' + CAST(DEA_LOC_REGION AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(DEA_LOC_ZONA AS VARCHAR), 2) IN(SELECT RIGHT(''0'' + CAST(P_Region AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(P_Zona AS VARCHAR), 2) FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Incluir'')))'
	--	END
	--END
	
	--IF EXISTS(SELECT P_Region FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Excluir')
	--	BEGIN
	--		Set @Dinamico3 = 'AND ('
	
	--		IF EXISTS(SELECT P_Zona FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Excluir' AND P_Zona = 0)
	--		BEGIN			
	--			SET @Dinamico3 = @Dinamico3 + '(DEA_LOC_REGION NOT IN(SELECT P_Region FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Excluir'' GROUP BY P_REGION))'
	
	--			IF EXISTS(SELECT P_Zona FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = @Id AND P_Bono = 'BONO_ESP' AND P_IncluirExcluir = 'Excluir' AND P_Zona > 0)
	--			BEGIN
	--				SET @Dinamico3 = @Dinamico3 + 'OR (RIGHT(''0'' + CAST(DEA_LOC_REGION AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(DEA_LOC_ZONA AS VARCHAR), 2) NOT IN(SELECT RIGHT(''0'' + CAST(P_Region AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(P_Zona AS VARCHAR), 2) FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Excluir''))'
	--			END
	--		SET @Dinamico3 = @Dinamico3 + ')'
	--		END
	--		ELSE
	--		BEGIN
	--			SET @Dinamico3 = @Dinamico3 + '(RIGHT(''0'' + CAST(DEA_LOC_REGION AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(DEA_LOC_ZONA AS VARCHAR), 2) NOT IN(SELECT RIGHT(''0'' + CAST(P_Region AS VARCHAR),2) + ''-'' + RIGHT(''0'' + CAST(P_Zona AS VARCHAR), 2) FROM P_BonoEmprendedoraXLVDetalle(nolock) WHERE P_IdBono = ' + cast(@Id as varchar) + ' AND P_Bono  = ''BONO_ESP'' AND P_IncluirExcluir = ''Excluir'')))'
	--		END
	--	END

	SELECT @salto = P_INI, @tipo = P_TIPO, @bono = P_MONTOBONO, @inicio = P_INICIO, @tipoConfiguracion = P_TIPO_CONFIGURACION
	FROM P_RangosInvitadasEmprendedoras(NOLOCK)
	WHERE P_BONOID = @Id

	SELECT @Descripcion = CONCAT(A.Descripcion, ' ', B.Descripcion)
	FROM P_Cat_TipoBono A (NOLOCK)
	LEFT JOIN P_Cat_TipoBonoConfiguracion B (NOLOCK) ON A.IDTipoBono = B.IDTipoBono
	WHERE A.IDTipoBono = 1 AND B.IDTipoBonoConfiguracion = CASE WHEN @tipoConfiguracion <> 0 THEN @tipoConfiguracion ELSE B.IDTipoBonoConfiguracion END

	--PRINT @salto
	--PRINT @tipo 
	--PRINT @bono 
	--PRINT @inicio
	--PRINT @tipoConfiguracion
	print @descripcion

	CREATE TABLE #ResultadoGanadoras (Anio INT, Campania INT, Id INT, EmprendedoraGanadora INT, Bono INT)

			--BEGIN TRY
			----
			
			--	INSERT INTO EMPRENDEDORAS_BITACORA 
			--	VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			--END TRY
			--BEGIN CATCH
			--	INSERT INTO EMPRENDEDORAS_BITACORA 
			--	VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
			--		'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			--END CATCH

	IF @tipo = 1
	BEGIN
		IF @tipoConfiguracion = 1
		BEGIN
			BEGIN TRY
				DECLARE @diferencia INT = @inicio - @salto
				SET @dinamico = '
				INSERT INTO #ResultadoGanadoras
				SELECT ' + CAST(@campaña AS VARCHAR) + ' Campaña,
				' + CAST(@Año AS VARCHAR) + ' Año,
				' + CAST (@id as varchar) + ',
				Consejera,
				CASE
					WHEN InvitadasCalificadas >= '+ cast(@inicio as Varchar) +' 
						THEN ((CAST(ISNULL(InvitadasCalificadas, 0) - ' + CAST(@diferencia AS VARCHAR) + '  AS INT) /' + cast(@salto as varchar) + ') * ' + cast(@bono as Varchar) + ') 
					ELSE 0
				END AS bono
				FROM P_Elite_Nuevo_Previo(NOLOCK)
				--INNER JOIN V_DEALER(NOLOCK)
				--ON Consejera = Dea_dealer AND NUMCIA=1
				WHERE InvitadasCalificadas >= ' + cast(@inicio as Varchar) --+' ' + @dinamico2 + ' ' + @dinamico3
			
				PRINT @Dinamico
				EXEC SP_SQLEXEC @Dinamico

				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH
		END

		IF @tipoConfiguracion = 2
		BEGIN	
			BEGIN TRY
				Set @dinamico = 'INSERT INTO #ResultadoGanadoras
				Select ' + cast(@campaña as varchar) + ' Campaña,
				' + cast(@Año as varchar) + ' Año, 
				' + CAST (@id as varchar) + ',
				Consejera,
				ISNULL((Select P_MontoBono From P_RangosInvitadasEmprendedoras(NOLOCK) WHERE P_BonoId = ' + Cast(@Id as Varchar) + ' and InvitadasCalificadas Between P_Ini and P_Fin),0) bono
				FROM P_Elite_Nuevo_Previo(NOLOCK)
				--INNER JOIN V_Dealer(NOLOCK)
				--ON dea_dealer = Consejera  AND NUMCIA=1
				WHERE InvitadasCalificadas > ' + cast(@inicio as Varchar) --+' ' + @dinamico2 + ' ' + @dinamico3
			
				PRINT @Dinamico
				EXEC SP_SQLEXEC @Dinamico

				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH

		END

		IF @tipoConfiguracion = 3
		BEGIN
			BEGIN TRY
				DECLARE CURSOR_BONOEXTRA CURSOR FAST_FORWARD FOR

				SELECT P_Ini, P_fin, P_MontoBono 
				FROM P_RangosInvitadasEmprendedoras(NOLOCK)
				WHERE P_BonoId = @Id
				ORDER BY P_Ini

				OPEN CURSOR_BONOEXTRA
				FETCH NEXT FROM CURSOR_BONOEXTRA into @Inicio, @Fin, @bono

				WHILE @@fetch_status = 0
				BEGIN
			--print 'b'
					IF @Aux = 0
					BEGIN
						SET @Auxd = '(' + CAST(@Fin AS VARCHAR) + ' * ' + CAST(@bono AS VARCHAR) + ') + '
						SET @Dinamico4 = 'CASE WHEN InvitadasCalificadas BETWEEN ' + CAST(@Inicio AS VARCHAR) + ' AND ' + CAST(@Fin AS VARCHAR) + ' THEN InvitadasCalificadas * ' + CAST(@bono AS VARCHAR)
					END
					ELSE
					BEGIN
						IF @Fin > 0
						BEGIN
							SET @Dinamico4 = @Dinamico4 + ' WHEN InvitadasCalificadas BETWEEN ' + CAST(@Inicio AS VARCHAR) + ' AND ' + CAST(@Fin AS VARCHAR) + ' THEN ' + @Auxd + ' ((InvitadasCalificadas - ' + CAST(@Ant AS VARCHAR) + ') * ' + CAST(@bono AS VARCHAR) + ')'
							SET @Auxd = @Auxd + '(' + CAST((@Fin - @Ant) AS VARCHAR) + ' * ' + CAST(@bono AS VARCHAR) + ') + '
						END
						ELSE
						BEGIN
							SET @Dinamico4 = @Dinamico4 + ' WHEN InvitadasCalificadas >= ' + CAST(@Inicio AS VARCHAR) + ' THEN ' + @Auxd + ' ((InvitadasCalificadas - ' + CAST(@Ant AS VARCHAR) + ') * ' + CAST(@bono AS VARCHAR) + ')'
						END
					END
		
					SET @Ant = @Fin
					SET @Aux = @Aux + 1

					FETCH NEXT FROM CURSOR_BONOEXTRA into @Inicio, @Fin, @bono
				END
				CLOSE CURSOR_BONOEXTRA
				DEALLOCATE CURSOR_BONOEXTRA
	
				SET @Dinamico4 = @Dinamico4 + ' ELSE 0 END ' 

				Select @inicio = MIN(P_INICIO)
				FROM P_RangosInvitadasEmprendedoras(NOLOCK)
				WHERE P_BONOID = @Id

				Set @dinamico = 'INSERT INTO #ResultadoGanadoras
				SELECT ' + cast(@campaña as varchar) + ' Campaña,
				' + cast(@Año as varchar) + ' Año,
				' + CAST (@id as varchar) + ',
				Consejera,
				' + @Dinamico4 +' bono
				FROM P_Elite_Nuevo_Previo(NOLOCK)
				--INNER JOIN V_Dealer(NOLOCK)
				--ON dea_dealer = Consejera  AND NUMCIA=1
				WHERE InvitadasCalificadas > ' + cast(@inicio as Varchar) --+' ' + @dinamico2 + ' ' + @dinamico3
			
				PRINT @Dinamico
				EXEC SP_SQLEXEC @Dinamico

				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH

			
		END

		IF @tipoConfiguracion = 4
		BEGIN
			BEGIN TRY
				--DECLARE @QUERY AS VARCHAR(MAX) = ''
				CREATE TABLE #BASECONSEJERAS (CONSEJERA INT, NIVEL_GANADO INT, INVITADASCALIFICADAS INT, BONOINVITADAS INT)
				
				SET @Dinamico14 = 'INSERT INTO #BASECONSEJERAS
				SELECT A.*
				--INTO #BASECONSEJERAS
				FROM (--Aqui se estan trayendo a las de C9 que tambien estan en C8
				SELECT P.consejera,N.NIVEL_GANADO, N.InvitadasCalificadas,P.BonoInvitadas
				FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				INNER JOIN (SELECT consejera, NIVEL_GANADO, InvitadasCalificadas
								FROM P_HISTORICO_GANADORAS_ELITE H (NOLOCK)
								WHERE Año * 100 + Campaña = '+CAST(@PeriodoAnterior AS VARCHAR)+' 
								GROUP BY CONSEJERA, NIVEL_GANADO, InvitadasCalificadas) N ON N.consejera = P.consejera
				WHERE P.Año * 100 + P.Campaña = '+CAST(@PeriodoActual AS VARCHAR)+'
				GROUP BY P.consejera,N.NIVEL_GANADO, N.InvitadasCalificadas, P.BonoInvitadas
				UNION 
				--Emprendedoras de C9 que no estan en C8
				SELECT P.consejera, P.NIVEL_GANADO, P.InvitadasCalificadas, P.BonoInvitadas
				FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				WHERE P.consejera NOT IN (SELECT consejera
											FROM P_HISTORICO_GANADORAS_ELITE H (NOLOCK)
											WHERE Año * 100 + Campaña = '+CAST(@PeriodoAnterior AS VARCHAR)+'
											GROUP BY CONSEJERA)
				AND P.Año * 100 + P.Campaña = '+CAST(@PeriodoActual AS VARCHAR)+'
				GROUP BY P.consejera, P.NIVEL_GANADO, P.InvitadasCalificadas, P.BonoInvitadas
				--ORDER BY H.consejera
				) A 
				INNER JOIN P_ELITE_NUEVO_PREVIO P ON P.consejera = A.consejera 
				WHERE A.InvitadasCalificadas > 0
				ORDER BY A.consejera'

				PRINT @Dinamico14
				EXEC SP_SQLEXEC @Dinamico14

				--INSERT INTO #BASECONSEJERAS
				--SELECT A.*
				----INTO #BASECONSEJERAS
				--FROM (--Aqui se estan trayendo a las de C9 que tambien estan en C8
				--SELECT P.consejera,N.NIVEL_GANADO, N.InvitadasCalificadas,P.BonoInvitadas
				--FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				--INNER JOIN (SELECT consejera, NIVEL_GANADO, InvitadasCalificadas
				--				FROM P_HISTORICO_GANADORAS_ELITE H (NOLOCK)
				--				WHERE Año * 100 + Campaña = @PeriodoAnterior 
				--				GROUP BY CONSEJERA, NIVEL_GANADO, InvitadasCalificadas) N ON N.consejera = P.consejera
				--WHERE P.Año * 100 + P.Campaña = @PeriodoActual
				--GROUP BY P.consejera,N.NIVEL_GANADO, N.InvitadasCalificadas, P.BonoInvitadas
				--UNION 
				----Emprendedoras de C9 que no estan en C8
				--SELECT P.consejera, P.NIVEL_GANADO, P.InvitadasCalificadas, P.BonoInvitadas
				--FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				--WHERE P.consejera NOT IN (SELECT consejera
				--							FROM P_HISTORICO_GANADORAS_ELITE H (NOLOCK)
				--							WHERE Año * 100 + Campaña = @PeriodoAnterior 
				--							GROUP BY CONSEJERA)
				--AND P.Año * 100 + P.Campaña = @PeriodoActual
				--GROUP BY P.consejera, P.NIVEL_GANADO, P.InvitadasCalificadas, P.BonoInvitadas
				----ORDER BY H.consejera
				--) A 
				--INNER JOIN P_ELITE_NUEVO_PREVIO P ON P.consejera = A.consejera 
				--WHERE A.InvitadasCalificadas > 0
				--ORDER BY A.consejera

				SET @dinamico = '
				INSERT INTO #ResultadoGanadoras
				SELECT ' + cast(@campaña as varchar) + ' Campaña,
				' + cast(@Año as varchar) + ' Año,  
				' + CAST (@id as varchar) + ',
				Consejera,
				Bono --Es el que acaba de ganar en esta evaluacion
				FROM (
				SELECT 
					E.consejera, 
					E.NIVEL_GANADO, 
					E.InvitadasCalificadas [invitadasCalificadas],
					-- Calcular el bono usando la tabla de configuración, limitando por nivel
					CASE '
				-- Declaración de variables
				DECLARE @P_BONOID INT, @P_INI INT, @P_FIN INT, @P_TIPO INT, 
						@P_MONTOBONO INT, @P_INICIO INT, 
						@P_INICIO_NIVEL INT, @P_FIN_NIVEL INT;

				-- Declarar el cursor para la consulta
				DECLARE nombre_cursor CURSOR FOR
				SELECT P_BONOID, P_INI, P_FIN, P_TIPO, P_MONTOBONO, P_INICIO, P_INICIO_NIVEL, P_FIN_NIVEL
				FROM P_RangosInvitadasEmprendedoras WHERE P_BONOID = @ID ;  -- Reemplaza con el nombre de tu tabla que contiene estos datos

				OPEN nombre_cursor;

				FETCH NEXT FROM nombre_cursor INTO @P_BONOID, @P_INI, @P_FIN, @P_TIPO, 
												@P_MONTOBONO, @P_INICIO, @P_INICIO_NIVEL, @P_FIN_NIVEL;

				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- Aquí puedes realizar las operaciones que necesites con los valores de @Variable1 y @Variable2
					-- Operaciones, actualizaciones, etc.
					SET @dinamico = @dinamico + '
					WHEN E.NIVEL_GANADO BETWEEN '+CAST(@P_INICIO_NIVEL AS VARCHAR)+' AND '+CAST(@P_FIN_NIVEL AS VARCHAR)+' THEN
												(SELECT MAX(BC.P_MONTOBONO)
												 FROM P_RangosInvitadasEmprendedoras BC 
												 WHERE BC.P_BONOID = ' + Cast(@Id as Varchar) + ' AND E.InvitadasCalificadas BETWEEN BC.P_INI AND BC.P_FIN
												   AND BC.P_MONTOBONO >= '+CAST(@P_MONTOBONO AS VARCHAR)+')
												   '
					-- Obtener la siguiente fila
					FETCH NEXT FROM nombre_cursor INTO @P_BONOID, @P_INI, @P_FIN, @P_TIPO, 
													  @P_MONTOBONO, @P_INICIO, @P_INICIO_NIVEL, @P_FIN_NIVEL;
				END;
				CLOSE nombre_cursor;
				DEALLOCATE nombre_cursor;
				SET @dinamico = @dinamico + '
				ELSE 0
					END AS [bono],
				E.BonoInvitadas
				FROM 
					#BASECONSEJERAS E (NOLOCK)) A WHERE BONO IS NOT NULL ORDER BY BONO ASC'
					--PRINT @Dinamico

				PRINT @Dinamico
				EXEC SP_SQLEXEC @Dinamico
							
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH
		END
	END
	
	IF @tipo = 2
	BEGIN
		BEGIN TRY
			CREATE TABLE [dbo].[#VentaTotal_InvitadaRetencion](
			[AÑO] [int] NULL,[CAMPAÑA] [int] NULL,
			[RECLUTADOR] [numeric](10, 0) NULL,
			[INVITADA] [numeric](10, 0) NULL,[FECHA_INGRESO] [datetime] NULL,
			[TOTAL_FOLLETO] [numeric](38, 2) NULL,[TOTAL_MAYOREO] [numeric](38, 2) NULL,[TOTAL_EMR] [numeric](38, 2) NULL,[VENTA_NEGADA] [numeric](38, 2) NULL,
			[ESQUEMA_VENTA] [varchar](11) NULL,[ESQUEMA_ORIGEN] [varchar](11) NULL,[SITUACION] [int] NULL,[REINGRESO] [int] NULL)

			CREATE TABLE [dbo].[#SaldoPendiente_InvitadaRetencion](
			[AÑO] [int] NULL,[CAMPAÑA] [int] NULL,
			[CONSEJERA] [numeric](10, 0) NULL,
			[SALDO_PENDIENTE] [numeric](18, 2) NULL)

			   /*
				   TRUNCATE TABLE #VentaTotal_InvitadaRetencion
				   TRUNCATE TABLE #SaldoPendiente_InvitadaRetencion

				   DROP TABLE #VentaTotal_InvitadaRetencion
				   DROP TABLE #SaldoPendiente_InvitadaRetencion
			   */

			DECLARE @DinamicoInvitadasRetencion AS VARCHAR(MAX)=''
			DECLARE @AÑO_E AS INTEGER, @CAMPAÑA_E AS INTEGER, @F_INICO AS VARCHAR(10),@F_FIN AS VARCHAR(10),@PEDIDO_CAL AS NUMERIC(18,2)
			DECLARE cr_VentaCampaña CURSOR FORWARD_ONLY STATIC FOR

			SELECT AÑO, CAMPAÑA, FECHA_INICIO, FECHA_FIN, PEDIDO_CALIFICADO
			FROM StanCasaCentral.DBO.CALENDARIO_VENTA(NOLOCK)
			WHERE AÑO * 100 + CAMPAÑA = @PeriodoTresAtras
			--WHERE AÑO=2024 AND CAMPAÑA IN (13)
			ORDER BY AÑO DESC, CAMPAÑA DESC

			OPEN cr_VentaCampaña
				FETCH NEXT FROM cr_VentaCampaña INTO  @AÑO_E , @CAMPAÑA_E , @F_INICO ,@F_FIN ,@PEDIDO_CAL
				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT 'CAMPAÑA: ' + CAST(@CAMPAÑA_E AS VARCHAR) +'/'+CAST(@AÑO_E AS VARCHAR) + ' --- ' +  CAST(GETDATE() AS VARCHAR)
					CREATE TABLE #VENTA_EN_CAMPAÑA(AÑO INTEGER, CAMPAÑA INTEGER, RECLUTADOR numeric(10, 0),INVITADA numeric (10, 0),FECHA_INGRESO datetime,VENTA_FOLLETO numeric(38, 2),VENTA_MAYOREO numeric(38, 2),EXCEPCIONES_FOLLETO numeric(10, 2),EXCEPCIONES_MAYOREO numeric(10, 2),VENTA_NEGADA_FOLLETO numeric(18, 2),    VENTA_NEGADA_MAYOREO numeric(18, 2),TOTAL_FOLLETO numeric(38,2),TOTAL_MAYOREO numeric(38,2),ESQUEMA_VENTA varchar(11),ESQUEMA_ORIGEN varchar(11))
					CREATE TABLE #VENTA (AÑO INTEGER, CAMPAÑA INTEGER, RECLUTADOR numeric(10, 0),INVITADA numeric (10, 0),FECHA_INGRESO datetime, CONCEPTO NUMERIC(10,0),IMPORTE NUMERIC(38,2))
   
					SET @DinamicoInvitadasRetencion ='
					INSERT INTO #SaldoPendiente_InvitadaRetencion
						SELECT ' + CAST(@AÑO_E AS VARCHAR) +' [AÑO],'+ CAST(@CAMPAÑA_E AS VARCHAR) +' [CAMPAÑA], TOTMOV_DEALER[CONSEJERA],ISNULL(SUM(TOTMOV_IMPTE_VAR),0)[SALDO_PENDIENTE]
						FROM V_MOVIMIENTOS M(NOLOCK) 
						INNER JOIN V_TOTALES_MOVIMIENTOS T(NOLOCK)ON MOVTOS_NUMCIA = TOTMOV_NUMCIA AND MOVTOS_DEALER = TOTMOV_DEALER
						INNER JOIN V_CAT_TOTALES_MOVTOS S(NOLOCK)ON S.CTOTMOV_NUMCIA=1 AND S.CTOTMOV_NUM_TOTAL=T.TOTMOV_NUM_TOTAL AND S.CTOTMOV_AFECTA_SALDO=''S''
						AND MOVTOS_CVE_DOCUMENTO = TOTMOV_CVE_DOCUMENTO AND MOVTOS_FOLIO_SISTEMA = TOTMOV_FOLIO_SISTEMA AND TOTMOV_FECHA_ALTA=MOVTOS_FECHA_ALTA
						WHERE MOVTOS_NUMCIA = 1 AND TOTMOV_NUMCIA = 1 /*AND TOTMOV_NUM_TOTAL=2 se consulta lo que afecta al saldo de V_CAT_TOTALES_MOVTOS*/ 
						AND MOVTOS_FECHA_ALTA BETWEEN '''+ CONVERT(VARCHAR(10),@F_INICO,111) +' 00:00:00'' AND '''+ CONVERT(VARCHAR(10),@F_FIN,111) + ' 23:59:59''
						AND MOVTOS_CVE_DOCUMENTO IN(10) AND TOTMOV_CVE_DOCUMENTO = 10
						GROUP BY TOTMOV_DEALER'
					--PRINT @DINAMICO
					EXEC (@DinamicoInvitadasRetencion)
   
					DECLARE @fechaInicial AS VARCHAR(10),@fechaFinal AS VARCHAR(10)
					SELECT @fechaInicial = FECPER_FECHA_INI, @fechaFinal = FECPER_FECHA_FIN 
					FROM V_PERIODOS(NOLOCK) WHERE FECPER_NUMCIA = 1 AND FECPER_TIPO_PERI = 'CA' AND FECPER_ANO_PERI = @AÑO_E AND FECPER_NUM_PERI = @CAMPAÑA_E

					SET @DinamicoInvitadasRetencion ='
					INSERT INTO #VENTA
									SELECT
										'+ CAST(@AÑO_E AS VARCHAR) +' [AÑO]
										,'+ CAST(@CAMPAÑA_E AS VARCHAR) +'[CAMPAÑA] 
										,CASE WHEN DEA_RECLUTADOR = DEA_DEALER THEN 0 ELSE DEA_RECLUTADOR END [RECLUTADOR]
										,v.DEA_DEALER [INVITADA]
										,CONVERT(VARCHAR(10),DEA_FECHA_ALTA,111) +'' 00:00:00'' [FECHA_INGRESO]
										,TOTMOV_NUM_TOTAL [CONCEPTO]
										,TOTMOV_IMPTE_FIJO[IMPORTE]
									FROM V_TOTALES_MOVIMIENTOS(NOLOCK)
									INNER JOIN V_MOVIMIENTOS(NOLOCK)ON MOVTOS_NUMCIA=1 AND TOTMOV_DEALER = MOVTOS_DEALER AND TOTMOV_CVE_DOCUMENTO = MOVTOS_CVE_DOCUMENTO AND TOTMOV_FOLIO_SISTEMA = MOVTOS_FOLIO_SISTEMA AND TOTMOV_FECHA_ALTA = MOVTOS_FECHA_ALTA
									INNER JOIN V_DEALER v(NOLOCK)ON NUMCIA = 1 AND DEA_DEALER = MOVTOS_DEALER AND DEA_DEALER = TOTMOV_DEALER
									WHERE TOTMOV_NUMCIA = 1 AND MOVTOS_NUMCIA = 1 AND NUMCIA = 1 AND MOVTOS_CANC_X_FAX_ORIG = 0
									AND TOTMOV_CVE_DOCUMENTO = 10 AND MOVTOS_CVE_DOCUMENTO=10 AND TOTMOV_NUM_TOTAL IN (2,13,4,61,27,28,3) --Se consideran todas las que tengas Venta Folleto y/o Venta Neta
									AND MOVTOS_FECHA_ALTA BETWEEN '''+ CONVERT(VARCHAR(10),@fechaInicial,111) +' 00:00:00'' AND '''+ CONVERT(VARCHAR(10),@fechaFinal,111) + ' 23:59:59''
									AND TOTMOV_FECHA_ALTA BETWEEN '''+ CONVERT(VARCHAR(10),@fechaInicial,111) +' 00:00:00'' AND '''+ CONVERT(VARCHAR(10),@fechaFinal,111) + ' 23:59:59'''
					--PRINT @DINAMICO
					EXEC (@DinamicoInvitadasRetencion)
   
					SET @DinamicoInvitadasRetencion ='
					INSERT INTO #VENTA
									SELECT  P.FECPER_ANO_PERI[AÑO]
											,P.FECPER_NUM_PERI[CAMPAÑA] 
											,CASE WHEN DEA_RECLUTADOR = DEA_DEALER THEN 0 ELSE DEA_RECLUTADOR END [RECLUTADOR]
											,v.DEA_DEALER [INVITADA]
											,CONVERT(VARCHAR(10),DEA_FECHA_ALTA,111) +'' 00:00:00'' [FECHA_INGRESO]
											,0[CONCEPTO]
											,0[IMPORTE]
									FROM V_MOVIMIENTOS(NOLOCK)
									INNER JOIN V_DEALER v(NOLOCK)ON NUMCIA = 1 AND DEA_DEALER = MOVTOS_DEALER  
									INNER JOIN V_PERIODOS P(NOLOCK)ON P.FECPER_NUMCIA=1 AND P.FECPER_TIPO_PERI=''CA'' AND P.FECPER_ANO_PERI='+ CAST(@AÑO_E AS VARCHAR) +' AND P.FECPER_NUM_PERI='+ CAST(@CAMPAÑA_E AS VARCHAR) +'
									LEFT JOIN #VENTA VTA(NOLOCK)ON VTA.INVITADA = v.DEA_DEALER  AND  VTA.AÑO = P.FECPER_ANO_PERI AND VTA.CAMPAÑA=P.FECPER_NUM_PERI
									WHERE MOVTOS_NUMCIA = 1 AND NUMCIA = 1 AND MOVTOS_CANC_X_FAX_ORIG = 0 AND MOVTOS_CVE_DOCUMENTO=10 
									AND MOVTOS_FECHA_ALTA BETWEEN '''' + CAST(P.FECPER_FECHA_INI AS VARCHAR) + '' 00:00:00'' AND '''' + CAST(P.FECPER_FECHA_FIN AS VARCHAR) + '' 23:59:59'' 
									AND VTA.INVITADA IS NULL -- ESTAS CONSEJERAS NO TIENEN VENTA FOLLETO NI VENTA NETA EN LA CAMPAÑA'
					--PRINT @DINAMICO
					EXEC (@DinamicoInvitadasRetencion)

					INSERT INTO #VENTA_EN_CAMPAÑA
									SELECT 
										AÑO,CAMPAÑA,RECLUTADOR,INVITADA,FECHA_INGRESO
										,SUM(CASE WHEN CONCEPTO IN(2,13,4,61,27,28) THEN  ABS(IMPORTE) ELSE 0 END)[VENTA_FOLLETO]
										,SUM(CASE WHEN CONCEPTO IN(2,27,28) THEN ABS(IMPORTE) ELSE 0 END) [VENTA_MAYOREO]
										,0 [EXCEPCIONES_FOLLETO]
										,0 [EXCEPCIONES_MAYOREO] 
										,0 [VENTA_NEGADA_FOLLETO],0 [VENTA_NEGADA_MAYOREO],0 [TOTAL_FOLLETO],0 [TOTAL_MAYOREO]
										,'TRADICIONAL'[ESQUEMA_VENTA]
										,'TRADICIONAL'[ESQUEMA_ORIGEN]
									FROM #VENTA(NOLOCK)
									GROUP BY AÑO,CAMPAÑA,INVITADA,RECLUTADOR,FECHA_INGRESO
   
					UPDATE a SET VENTA_NEGADA_FOLLETO = VENTANEGADA.VENTA_FOLLETO_NEGADA, VENTA_NEGADA_MAYOREO = VENTANEGADA.VENTA_MAYOREO_NEGADA
					FROM #VENTA_EN_CAMPAÑA a(NOLOCK)
					INNER JOIN(
									SELECT DEA_DEALER, ISNULL(SUM(isnull(VentaNegada,0)),0) VENTA_FOLLETO_NEGADA,ISNULL(SUM(isnull(VentaNegadaMay,0)),0) VENTA_MAYOREO_NEGADA
									FROM P_VENTANEGADA_HISTORICO b(NOLOCK)
									WHERE AÑO = @AÑO_E AND CAMPAÑA = @CAMPAÑA_E 
									GROUP BY DEA_DEALER
					)VENTANEGADA ON INVITADA = DEA_DEALER

					UPDATE a SET EXCEPCIONES_FOLLETO = FOLLETO , EXCEPCIONES_MAYOREO = MAYOREO
					FROM #VENTA_EN_CAMPAÑA a(NOLOCK)
					INNER JOIN(
									SELECT consejera
									,SUM(Case idTipoExcepcion When 1 Then importeFolleto When 2 Then importeFolleto * -1 END) FOLLETO
									,SUM(Case idTipoExcepcion When 1 Then importeMayoreo When 2 Then (importeMayoreo * -1) End) MAYOREO
									FROM Promociones.dbo.ExcepcionConsejera (NOLOCK)
									WHERE anioCampania = CAST(@AÑO_E AS VARCHAR) + RIGHT('0' + CAST(@CAMPAÑA_E AS VARCHAR),2)
									GROUP BY consejera
					)EXCEPCIONES ON a.INVITADA = EXCEPCIONES.CONSEJERA

					UPDATE a SET EXCEPCIONES_FOLLETO = EXCEPCIONES_FOLLETO + FOLLETO , EXCEPCIONES_MAYOREO = EXCEPCIONES_MAYOREO + MAYOREO
					FROM #VENTA_EN_CAMPAÑA a(NOLOCK)
					INNER JOIN(
									SELECT CONSEJERA,SUM(MONTO_PAGAR) FOLLETO, SUM((MONTO_PAGAR / 1.16) * .7) MAYOREO 
									FROM PAGOS_PARCIALES_PENDIENTES(NOLOCK)
									INNER JOIN Configuracion_fact_parcialidades(NOLOCK) ON ID_CONFIGURACION = ID
									WHERE AÑO = @AÑO_E AND CAMPAÑA = @CAMPAÑA_E  
									GROUP BY CONSEJERA
					)PAGOSPARCIALES ON a.INVITADA = PAGOSPARCIALES.Consejera

					UPDATE a SET EXCEPCIONES_FOLLETO = EXCEPCIONES_FOLLETO - FOLLETO , EXCEPCIONES_MAYOREO = EXCEPCIONES_MAYOREO - MAYOREO
					FROM #VENTA_EN_CAMPAÑA a(NOLOCK)
					INNER JOIN(
									SELECT CONSEJERA,SUM(MONTO_PAGAR) FOLLETO, SUM((MONTO_PAGAR / 1.16) * .7) MAYOREO 
									FROM PAGOS_PARCIALES_PENDIENTES(NOLOCK)
									INNER JOIN V_PERIODOS P(NOLOCK)ON P.FECPER_NUMCIA=1 AND P.FECPER_TIPO_PERI='CA' AND P.FECPER_ANO_PERI=@AÑO_E AND P.FECPER_NUM_PERI=@CAMPAÑA_E
									WHERE FECHA_ASIGNACION BETWEEN '' + CAST(P.FECPER_FECHA_INI AS VARCHAR) + ' 00:00:00' AND '' + CAST(P.FECPER_FECHA_INI AS VARCHAR) + ' 23:59:59'
									GROUP BY CONSEJERA
					)PAGOSPARCIALES ON a.INVITADA = PAGOSPARCIALES.Consejera

					INSERT INTO #VENTA_EN_CAMPAÑA
									SELECT 
									P.AÑO[AÑO]
									,P.CAMPAÑA[CAMPAÑA]
									,CASE WHEN ISNULL(RECLUTADORA,D.DEA_RECLUTADOR)=ISNULL(C.ID,m.ID_CONSEJERA) THEN 0 ELSE ISNULL(RECLUTADORA,D.DEA_RECLUTADOR) END [RECLUTADOR]
									,ISNULL(C.ID,m.ID_CONSEJERA) [INVITADA]
									,CONVERT(VARCHAR(10),ISNULL(C.FECHA_INGRESO,D.DEA_FECHA_ALTA),111) +' 00:00:00'[FECHA_INGRESO]
									,SUM(CASE WHEN dc.ID_CONCEPTO IN (2,13,4,61,27,28)  THEN dc.IMPORTE ELSE 0 END) [VENTA_FOLLETO]--,SUM(dc.IMPORTE) [VENTA_FOLLETO]
									,SUM(CASE WHEN dc.ID_CONCEPTO=2 THEN dc.IMPORTE ELSE 0 END)[VENTA_MAYOREO]
					,0[EXCEPCIONES_FOLLETO],0[EXCEPCIONES_MAYOREO],0[VENTA_NEGADA_FOLLETO],0[VENTA_NEGADA_MAYOREO],0 [TOTAL_FOLLETO],0 [TOTAL_MAYOREO]
									,'STANCASA'[ESQUEMA_VENTA] 
									,CASE WHEN C.ID IS NULL THEN 'TRADICIONAL' ELSE 'STANCASA' END[ESQUEMA_ORIGEN]
									FROM StanCasaCentral.DBO.MOVIMIENTO m(NOLOCK)
									INNER JOIN StanCasaCentral.DBO.DETALLE_MOVIMIENTO_CONCEPTO dc(NOLOCK)ON m.ID = dc.ID_MOVIMIENTO AND m.ID_TIPO_MOVIMIENTO = dc.ID_TIPO_MOVIMIENTO AND m.ID_CV = dc.ID_CV
									LEFT JOIN StanCasaCentral.DBO.CONSEJERA c(NOLOCK)ON m.ID_CONSEJERA = c.ID
									LEFT JOIN DBO.V_DEALER D(NOLOCK)ON D.DEA_DEALER=M.ID_CONSEJERA AND D.NUMCIA=1
									INNER JOIN StanCasaCentral.DBO.CALENDARIO_VENTA P(NOLOCK)ON P.AÑO=@AÑO_E AND P.CAMPAÑA=@CAMPAÑA_E
									WHERE ID_CONCEPTO IN(2,13,4,61,27,28,3) --Se consideran todas las que tengas Venta Folleto y/o Venta Neta
									AND m.ID_CONSEJERA NOT IN (88888,99999) 
									AND FECHA_MOVIMIENTO BETWEEN P.FECHA_INICIO AND P.FECHA_FIN
									GROUP BY P.AÑO,P.CAMPAÑA,RECLUTADORA,D.DEA_RECLUTADOR,C.ID,m.ID_CONSEJERA,C.FECHA_INGRESO,D.DEA_FECHA_ALTA
   
					--CONSEJERAS QUE COMPRARON EN AMBOS ESQUEMAS
					SELECT VT.AÑO,VT.CAMPAÑA,VT.RECLUTADOR,VT.INVITADA,VT.FECHA_INGRESO
									,SUM(ISNULL(VT.VENTA_FOLLETO,0)) + SUM(ISNULL(VT.EXCEPCIONES_FOLLETO,0)) + SUM(ISNULL(VT.VENTA_NEGADA_FOLLETO,0))[TOTAL_FOLLETO]
									,SUM(ISNULL(VT.VENTA_MAYOREO,0)) + SUM(ISNULL(VT.EXCEPCIONES_MAYOREO,0)) + SUM(ISNULL(VT.VENTA_NEGADA_MAYOREO,0))[TOTAL_MAYOREO]
									,SUM(CASE WHEN ESQUEMA_VENTA = 'STANCASA' THEN ISNULL(VT.VENTA_MAYOREO,0) ELSE 0 END)+SUM(CASE WHEN ESQUEMA_VENTA = 'TRADICIONAL' THEN ISNULL(0,0) ELSE 0 END) [TOTAL_EMR]
									,SUM(VT.VENTA_NEGADA_MAYOREO)[VENTA_NEGADA],'MIXTO'[ESQUEMA_VENTA],VT.ESQUEMA_ORIGEN
					INTO #VENTA_TOTAL
									FROM #VENTA_EN_CAMPAÑA VT(NOLOCK)
									GROUP BY VT.AÑO,VT.CAMPAÑA,VT.RECLUTADOR,VT.INVITADA,VT.FECHA_INGRESO,VT.ESQUEMA_ORIGEN
									HAVING COUNT(VT.INVITADA)>1
   
					--GUARDAMOS CONSEJERAS QUE SOLO COMPRARON EN UN ESQUEMA
					INSERT INTO #VentaTotal_InvitadaRetencion
									SELECT VEC.AÑO,VEC.CAMPAÑA,VEC.RECLUTADOR,VEC.INVITADA,VEC.FECHA_INGRESO
									,SUM(ISNULL(VEC.VENTA_FOLLETO,0)) + SUM(ISNULL(VEC.EXCEPCIONES_FOLLETO,0)) + SUM(ISNULL(VEC.VENTA_NEGADA_FOLLETO,0))[TOTAL_FOLLETO]
									,SUM(ISNULL(VEC.VENTA_MAYOREO,0)) + SUM(ISNULL(VEC.EXCEPCIONES_MAYOREO,0)) + SUM(ISNULL(VEC.VENTA_NEGADA_MAYOREO,0))[TOTAL_MAYOREO]
									,(SUM(CASE WHEN VEC.ESQUEMA_VENTA = 'STANCASA' THEN ISNULL(VEC.VENTA_MAYOREO,0) ELSE 0 END))+(SUM(CASE WHEN VEC.ESQUEMA_VENTA='TRADICIONAL' THEN ISNULL(0,0) ELSE 0 END))[TOTAL_EMR]
									,SUM(ISNULL(VEC.VENTA_NEGADA_MAYOREO,0))[VENTA_NEGADA]
									,VEC.ESQUEMA_VENTA,VEC.ESQUEMA_ORIGEN
									,ISNULL(D.DEA_SITUA_NUM,C.ID_SITUACION)[SITUACION]
									,ISNULL(D.DEA_CVE_REINGRESO,C.REINGRESO)[REINGRESO]
									FROM #VENTA_EN_CAMPAÑA VEC(NOLOCK)
									LEFT JOIN #VENTA_TOTAL EVT(NOLOCK)ON EVT.AÑO=@AÑO_E AND EVT.CAMPAÑA=@CAMPAÑA_E AND EVT.INVITADA=VEC.INVITADA
									LEFT JOIN V_DEALER D(NOLOCK)ON D.NUMCIA=1 AND D.DEA_DEALER=VEC.INVITADA
									LEFT JOIN StanCasaCentral.dbo.CONSEJERA C(NOLOCK)ON C.ID=VEC.INVITADA
									WHERE EVT.INVITADA IS NULL -- SOLO GUARDAMOS LOS QUE NO TIENEN VENTA MIXTA
									GROUP BY VEC.AÑO,VEC.CAMPAÑA,VEC.RECLUTADOR,VEC.INVITADA,VEC.FECHA_INGRESO,VEC.ESQUEMA_VENTA,VEC.ESQUEMA_ORIGEN,D.DEA_SITUA_NUM,C.ID_SITUACION,D.DEA_CVE_REINGRESO,C.REINGRESO
   
					INSERT INTO #VentaTotal_InvitadaRetencion
									SELECT EVT.AÑO,EVT.CAMPAÑA,EVT.RECLUTADOR,EVT.INVITADA,EVT.FECHA_INGRESO,EVT.TOTAL_FOLLETO,EVT.TOTAL_MAYOREO
									,EVT.TOTAL_EMR,EVT.VENTA_NEGADA,EVT.ESQUEMA_VENTA,EVT.ESQUEMA_ORIGEN
									,ISNULL(D.DEA_SITUA_NUM,C.ID_SITUACION)[SITUACION]
									,ISNULL(D.DEA_CVE_REINGRESO,C.REINGRESO)[REINGRESO]
									FROM #VENTA_TOTAL EVT(NOLOCK) --GUARDAMOS CONSEJERAS CON VENTA MIXTA
									LEFT JOIN V_DEALER D(NOLOCK)ON D.NUMCIA=1 AND D.DEA_DEALER=EVT.INVITADA
									LEFT JOIN StanCasaCentral.dbo.CONSEJERA C(NOLOCK)ON C.ID=EVT.INVITADA
				   
					DROP TABLE #VENTA_EN_CAMPAÑA
					DROP TABLE #VENTA
					DROP TABLE #VENTA_TOTAL
   
					FETCH NEXT FROM  cr_VentaCampaña INTO @AÑO_E , @CAMPAÑA_E , @F_INICO ,@F_FIN ,@PEDIDO_CAL
				END
			CLOSE cr_VentaCampaña
			DEALLOCATE cr_VentaCampaña

			--Obtenemos la venta de C13
			SELECT * 
			INTO #VentaInvitadas
			FROM (
				SELECT H.RECLUTADOR,H.INVITADA,H.FECHA_INGRESO,H.AÑO,H.CAMPAÑA,H.TOTAL_FOLLETO,H.SITUACION
				FROM #VentaTotal_InvitadaRetencion H(NOLOCK) 
				WHERE H.FECHA_INGRESO>= @FechaInicioTresAtras + ' 00:00:00' AND H.FECHA_INGRESO<= @FechaFinTresAtras + ' 23:59:59'
				UNION
				SELECT H.RECLUTADOR,H.INVITADA,H.FECHA_INGRESO,H.AÑO,H.CAMPAÑA,H.TOTAL_FOLLETO,H.SITUACION
				FROM EMPRENDEDORAS_VENTA_TOTAL H(NOLOCK)
				WHERE H.FECHA_INGRESO>=@FechaInicioTresAtras + ' 00:00:00' AND H.FECHA_INGRESO<=@FechaFinTresAtras + ' 23:59:59'
			)I

			--Saldo pendiente de C13 y C14
			SELECT * 
			INTO #SaldosInvitadas
			FROM (
				SELECT s.* FROM #SaldoPendiente_InvitadaRetencion S(NOLOCK)
				INNER JOIN #VentaInvitadas I (NOLOCK)ON I.INVITADA=S.CONSEJERA
				UNION
				SELECT s.* FROM EMPRENDEDORAS_SALDO_PENDIENTE S(NOLOCK)
				INNER JOIN #VentaInvitadas I (NOLOCK)ON I.INVITADA=S.CONSEJERA
			)s

			SELECT * 
			INTO #HC
			FROM (
				SELECT F.Madre[RECLUTADOR], F.Hija[HIJA],C1.TOTAL_FOLLETO[C1],C2.TOTAL_FOLLETO[C2],C3.TOTAL_FOLLETO[C3],C4.TOTAL_FOLLETO[C4]
				,ISNULL(SP.SALDO_PENDIENTE,0)[SALDO_PENDIENTE]
				,D.DEA_SITUA_NUM [SITUACION],F.ESQUEMA_ORIGEN[ESQUEMA]
				,D.DEA_FECHA_ALTA[FECHA_INGRESO]
				,ISNULL(SP2.SALDO_PENDIENTE,0)[SALDO_PENDIENTE2]
				,CASE WHEN DEA_CVE_REINGRESO<>0 THEN 'REINGRESO' ELSE 'NUEVA' END[REINGRESO]
				FROM EMPRENDEDORAS_FAMILIA F(NOLOCK) 
				LEFT JOIN #VentaInvitadas C1(NOLOCK) ON C1.INVITADA=F.Hija AND C1.AÑO = LEFT(@PeriodoTresAtras, 4) AND C1.CAMPAÑA = RIGHT(@PeriodoTresAtras, 2)
				LEFT JOIN #VentaInvitadas C2(NOLOCK) ON C2.INVITADA=C1.INVITADA AND C2.AÑO = LEFT(@PeriodoDosAtras, 4) AND C2.CAMPAÑA = RIGHT(@PeriodoDosAtras, 2)
				LEFT JOIN #VentaInvitadas C3(NOLOCK) ON C3.INVITADA=C1.INVITADA AND C3.AÑO = LEFT(@PeriodoAnterior, 4) AND C3.CAMPAÑA = RIGHT(@PeriodoAnterior, 2)
				LEFT JOIN #VentaInvitadas C4(NOLOCK) ON C4.INVITADA=C1.INVITADA AND C4.AÑO = LEFT(@PeriodoActual, 4) AND C4.CAMPAÑA = RIGHT(@PeriodoActual, 2)
				LEFT JOIN #SaldosInvitadas SP(NOLOCK) ON SP.CONSEJERA=C1.INVITADA AND SP.AÑO = LEFT(@PeriodoTresAtras, 4) AND SP.CAMPAÑA = RIGHT(@PeriodoTresAtras, 2)
				LEFT JOIN #SaldosInvitadas SP2(NOLOCK) ON SP2.CONSEJERA=C1.INVITADA AND SP2.AÑO = LEFT(@PeriodoDosAtras, 4) AND SP2.CAMPAÑA = RIGHT(@PeriodoDosAtras, 2)
				INNER JOIN V_DEALER D(NOLOCK) ON D.NUMCIA=1 AND D.DEA_DEALER=C1.INVITADA AND DEA_ESTRUC_NUM = 1 
				WHERE F.FECHA_INGRESO BETWEEN @FechaInicioTresAtras + ' 00:00:00'	AND @FechaFinTresAtras + ' 23:59:59'
				--AND F.MADRE=33351008
				UNION
				SELECT F.Madre[RECLUTADOR], F.Hija[HIJA],C1.TOTAL_FOLLETO[C1],C2.TOTAL_FOLLETO[C2],C3.TOTAL_FOLLETO[C3],C4.TOTAL_FOLLETO[C4]
				,ISNULL(SP.SALDO_PENDIENTE,0)[SALDO_PENDIENTE]
				,C.ID_SITUACION [SITUACION],F.ESQUEMA_ORIGEN[ESQUEMA]
				,C.FECHA_INGRESO [FECHA_INGRESO]
				,ISNULL(SP2.SALDO_PENDIENTE,0)[SALDO_PENDIENTE2]
				,CASE WHEN C.REINGRESO<>0 THEN 'REINGRESO' ELSE 'NUEVA' END[REINGRESO]
				FROM EMPRENDEDORAS_FAMILIA F(NOLOCK) 
				LEFT JOIN #VentaInvitadas C1(NOLOCK) ON C1.INVITADA=F.Hija AND C1.AÑO = LEFT(@PeriodoTresAtras, 4) AND C1.CAMPAÑA = RIGHT(@PeriodoTresAtras, 2)
				LEFT JOIN #VentaInvitadas C2(NOLOCK) ON C2.INVITADA=C1.INVITADA AND C2.AÑO = LEFT(@PeriodoDosAtras, 4) AND C2.CAMPAÑA = RIGHT(@PeriodoDosAtras, 2)
				LEFT JOIN #VentaInvitadas C3(NOLOCK) ON C3.INVITADA=C1.INVITADA AND C3.AÑO = LEFT(@PeriodoAnterior, 4) AND C3.CAMPAÑA = RIGHT(@PeriodoAnterior, 2)
				LEFT JOIN #VentaInvitadas C4(NOLOCK) ON C4.INVITADA=C1.INVITADA AND C4.AÑO = LEFT(@PeriodoActual, 4) AND C4.CAMPAÑA = RIGHT(@PeriodoActual, 2)
				LEFT JOIN #SaldosInvitadas SP(NOLOCK) ON SP.CONSEJERA=C1.INVITADA AND SP.AÑO = LEFT(@PeriodoTresAtras, 4) AND SP.CAMPAÑA = RIGHT(@PeriodoTresAtras, 2)
				LEFT JOIN #SaldosInvitadas SP2(NOLOCK) ON SP2.CONSEJERA=C1.INVITADA AND SP2.AÑO = LEFT(@PeriodoDosAtras, 4) AND SP2.CAMPAÑA = RIGHT(@PeriodoDosAtras, 2)
				INNER JOIN StanCasaCentral.DBO.CONSEJERA C(NOLOCK) ON C.ID=C1.INVITADA and c.RECLUTADORA>0 
				INNER JOIN StanCasaCentral.DBO.CAT_SITUACION CS (NOLOCK) ON CS.ID = C.ID_SITUACION
				WHERE F.FECHA_INGRESO BETWEEN @FechaInicioTresAtras + ' 00:00:00'	AND @FechaFinTresAtras + ' 23:59:59'
				--AND F.MADRE=33351008
			)R

			IF OBJECT_ID('tempdb..#GanadorasInvitadasRetencion') IS NOT NULL BEGIN DROP TABLE #GanadorasInvitadasRetencion END;

			CREATE TABLE #GanadorasInvitadasRetencion (GANADORA INT, INVITADAS_CALIFICADAS INT)

			INSERT INTO #GanadorasInvitadasRetencion
			SELECT RECLUTADOR EMPRENDEDORA, COUNT(HIJA_CALIFICADA) INVITADAS_CALIFICADAS
					--,COUNT(HIJA_CALIFICADA) INVITADAS_CALIFICADAS
					--,CASE WHEN COUNT(HIJA_CALIFICADA) BETWEEN 6 AND 9 THEN 1000
					--	WHEN COUNT(HIJA_CALIFICADA) BETWEEN 10 AND 19 THEN 2000
					--	WHEN COUNT(HIJA_CALIFICADA) BETWEEN 20 AND 29 THEN 4500
					--	WHEN COUNT(HIJA_CALIFICADA) >= 30 THEN 7000
					--	ELSE 0 END BONOTOTAL 
			FROM (
				SELECT 
					HC.RECLUTADOR, HC.HIJA[HIJA_CALIFICADA], HC.FECHA_INGRESO[FECHA_INGRESO],HC.REINGRESO
					, HC.C1 [PEDIDO1]
					, HC.C2	[PEDIDO2] 
					, HC.C3	[PEDIDO3] 
					, HC.C4	[PEDIDO4]
					, HC.SALDO_PENDIENTE [SALDO_C13]
					, HC.SALDO_PENDIENTE2[SALDO_C14]
					,CASE WHEN (HC.C1 >= @PedidoCalificadoTresAtras AND HC.C2 >= @PedidoCalificadoDosAtras AND HC.SALDO_PENDIENTE <= 5) THEN 'CALIFICADA' ELSE 'NO CALIFICADA' END [TIPO]
				FROM #HC HC
				INNER JOIN P_ELITE_NUEVO_PREVIO P(NOLOCK)ON P.consejera=HC.RECLUTADOR
				WHERE --HC.RECLUTADOR=11227006
					HC.C1 >= @PedidoCalificadoTresAtras
				AND HC.C2 >= @PedidoCalificadoDosAtras
				--AND HC.C3 >= 860
				AND HC.C4 >= @PedidoCalificadoActual
				AND HC.SALDO_PENDIENTE <= 5
				AND HC.SALDO_PENDIENTE2 <= 5
				AND HC.REINGRESO='NUEVA')R 
			GROUP BY RECLUTADOR
			--HAVING COUNT(HIJA_CALIFICADA) >= 6

			INSERT INTO #ResultadoGanadoras
			SELECT @Año, @campaña, @Id, GANADORA, P_MONTOBONO
			FROM #GanadorasInvitadasRetencion
			INNER JOIN P_RangosInvitadasEmprendedoras (NOLOCK) ON P_BONOID = @Id AND INVITADAS_CALIFICADAS BETWEEN P_INI AND P_FIN

			INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
		END TRY
		BEGIN CATCH
			INSERT INTO EMPRENDEDORAS_BITACORA 
			VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
				'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
		END CATCH	
	END

	IF @tipo = 3
	BEGIN
		IF @tipoConfiguracion = 1
		BEGIN
			BEGIN TRY
				INSERT INTO #ResultadoGanadoras
				SELECT @Año, @campaña, @Id, MADRE, ((COUNT(HIJA)) * @bono)
				FROM SQL_VENTAS.DBO.P_ELITE_NUEVO_PREVIO (NOLOCK)
				INNER JOIN SQL_VENTAS.DBO.EMPRENDEDORAS_FAMILIA (NOLOCK) ON MADRE = consejera
				WHERE Año * 100 + Campaña = @PeriodoActual
				AND HIJA IN (SELECT CONSEJERA FROM SQL_VENTAS.DBO.P_ELITE_NUEVO_PREVIO (NOLOCK) WHERE Año*100+Campaña = @PeriodoActual
								UNION
								SELECT CONSEJERA FROM StanCasaCentral.DBO.EMPRENDEDORAS_GANADORAS (NOLOCK) WHERE Año*100+Campaña = @PeriodoActual)
				AND HIJA NOT IN (SELECT CONSEJERA FROM SQL_VENTAS.DBO.P_HISTORICO_GANADORAS_ELITE (NOLOCK) WHERE Año*100+Campaña < @PeriodoAnterior
									UNION
									SELECT CONSEJERA FROM StanCasaCentral.DBO.EMPRENDEDORAS_GANADORAS_HISTORICO (NOLOCK) WHERE Año*100+Campaña < @PeriodoAnterior)
				AND HIJA IN (SELECT CONSEJERA FROM SQL_VENTAS.DBO.P_HISTORICO_GANADORAS_ELITE (NOLOCK) WHERE Año*100+Campaña = @PeriodoAnterior
								UNION
								SELECT CONSEJERA FROM StanCasaCentral.DBO.EMPRENDEDORAS_GANADORAS_HISTORICO(NOLOCK) WHERE Año*100+Campaña = @PeriodoAnterior)
				AND MADRE IN (SELECT CONSEJERA FROM SQL_VENTAS.DBO.P_HISTORICO_GANADORAS_ELITE (NOLOCK) WHERE Año*100+Campaña = @PeriodoAnterior)
				GROUP BY MADRE	
				
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH
		END
		IF @tipoConfiguracion = 2
		BEGIN
			BEGIN TRY
				DECLARE @PeriodoComparacion INT, @InicioNoCalifico INT, @MontoNoCalifico INT
				SELECT @PeriodoComparacion = P_PERIODO_COMPARACION FROM P_RangosInvitadasEmprendedoras (NOLOCK) WHERE P_BONOID = @Id AND P_PERIODO_COMPARACION <> 0
				SELECT @InicioNoCalifico = P_INICIO, @MontoNoCalifico = P_MONTOBONO FROM P_RangosInvitadasEmprendedoras (NOLOCK) WHERE P_BONOID = @Id AND P_INICIO <> 0

				INSERT INTO #ResultadoGanadoras
				SELECT @Año, @campaña, @Id, E.consejera, P_MONTOBONO
				FROM P_HISTORICO_GANADORAS_ELITE H(NOLOCK) 
				INNER JOIN P_ELITE_NUEVO_PREVIO E (NOLOCK) ON E.consejera = H.consejera
				INNER JOIN P_RangosInvitadasEmprendedoras R (NOLOCK) ON E.Hijas - H.Hijas BETWEEN P_INI AND P_FIN AND P_INI <> 0 AND P_BONOID = @Id
				WHERE (H.Año * 100 + H.Campaña) = @PeriodoComparacion
				AND E.Hijas > H.Hijas
				--AND (E.Hijas - H.Hijas) >= 3

				IF EXISTS(SELECT * FROM P_RangosInvitadasEmprendedoras (NOLOCK) WHERE P_BONOID = @ID AND P_RETENCION = 1)
				BEGIN
					INSERT INTO #ResultadoGanadoras
					SELECT @Año, @campaña, @Id, E.consejera, @MontoNoCalifico
					FROM P_ELITE_NUEVO_PREVIO E(NOLOCK)
					WHERE E.consejera NOT IN (SELECT consejera FROM P_HISTORICO_GANADORAS_ELITE (NOLOCK) WHERE (Año * 100 + Campaña) = @PeriodoComparacion GROUP BY consejera)
					AND (E.Año * 100 + E.Campaña) = @PeriodoActual
					AND E.Hijas >= @InicioNoCalifico
				END
				
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH
		END
	END

	IF @tipo = 4
	BEGIN
		BEGIN TRY
			CREATE TABLE #BaseNivelGanado (PERIODO INT, CONSEJERA INT, NIVELGANADO INT)
			CREATE TABLE #BaseBonoNivelGanado (NivelGanado INT, BonoExtra INT)

			INSERT INTO #BaseNivelGanado
			SELECT (E.Año * 100 + E.Campaña) [Periodo], E.consejera, E.NIVEL_GANADO
				FROM P_HISTORICO_GANADORAS_ELITE H (NOLOCK)
				INNER JOIN P_ELITE_NUEVO_PREVIO E (NOLOCK) ON E.consejera = H.consejera
				WHERE (H.Año * 100 + H.Campaña) = @PeriodoAnterior
				AND E.NIVEL_GANADO > H.NIVEL_GANADO
			UNION
			SELECT (E.Año * 100 + E.Campaña) [Periodo], E.consejera, E.NIVEL_GANADO
				FROM P_ELITE_NUEVO_PREVIO E(NOLOCK)
				WHERE (E.Año * 100 + E.Campaña) = @PeriodoActual
				AND E.consejera NOT IN (SELECT consejera FROM P_HISTORICO_GANADORAS_ELITE (NOLOCK) WHERE (Año * 100 + Campaña) = @PeriodoAnterior)
			UNION
			SELECT (Año * 100 + Campaña) [Periodo], consejera, NIVEL_GANADO
				FROM P_ELITE_NUEVO_PREVIO (NOLOCK)
				WHERE (Año * 100 + Campaña) = @PeriodoActual
				AND consejera NOT IN (SELECT consejera FROM P_HISTORICO_GANADORAS_ELITE (NOLOCK) GROUP BY consejera)

			INSERT INTO #BaseBonoNivelGanado
			SELECT P_INICIO_NIVEL, P_MONTOBONO
			FROM P_RangosInvitadasEmprendedoras (NOLOCK) WHERE P_BONOID = @Id

			INSERT INTO #ResultadoGanadoras
			SELECT @Año, @campaña, @Id, CONSEJERA, BonoExtra
			FROM #BaseNivelGanado A (NOLOCK)
			INNER JOIN #BaseBonoNivelGanado B (NOLOCK) ON A.NIVELGANADO = B.NivelGanado
			
			INSERT INTO EMPRENDEDORAS_BITACORA 
			VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
		END TRY
		BEGIN CATCH
			INSERT INTO EMPRENDEDORAS_BITACORA 
			VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
				'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
		END CATCH
	END

	IF @tipo = 5
	BEGIN
		BEGIN TRY
			SET @Dinamico = '
			INSERT INTO #ResultadoGanadoras
			SELECT ' + CAST(@Año AS VARCHAR) + ',
			' + CAST(@campaña AS VARCHAR) + ',
			' + CAST (@id as varchar) + ',
			consejera,
			' + CAST(@bono AS VARCHAR) + '
			FROM P_ELITE_NUEVO_PREVIO (NOLOCK)
			WHERE consejera NOT IN (SELECT DISTINCT consejera FROM P_HISTORICO_GANADORAS_ELITE (NOLOCK))
			AND Año = ' + CAST(@Año AS VARCHAR) + ' AND Campaña = ' + CAST(@campaña AS VARCHAR) --+ ''
			
			PRINT @Dinamico
			EXEC SP_SQLEXEC @Dinamico

			INSERT INTO EMPRENDEDORAS_BITACORA 
			VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
		END TRY
		BEGIN CATCH
			INSERT INTO EMPRENDEDORAS_BITACORA 
			VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
				'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
		END CATCH
	END

	IF @tipo = 6
	BEGIN
		IF @tipoConfiguracion = 1
		BEGIN
			BEGIN TRY
				SET @Dinamico = '
				INSERT INTO #ResultadoGanadoras
				SELECT ' + CAST(@Año AS VARCHAR) + ',
				' + CAST(@campaña AS VARCHAR) + ',
				' + CAST (@id as varchar) + ',
				P.consejera,
				' + CAST(@bono AS VARCHAR) + '
				FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				INNER JOIN (SELECT consejera FROM P_HISTORICO_GANADORAS_ELITE H1 (NOLOCK)
								WHERE H1.Año * 100 + H1.Campaña = ' + CAST(@PeriodoAnterior AS VARCHAR) + '
								AND H1.consejera NOT IN (SELECT consejera FROM P_HISTORICO_GANADORAS_ELITE H2 (NOLOCK) WHERE H2.Año * 100 + H2.Campaña < ' + CAST(@PeriodoAnterior AS VARCHAR) + ')) A ON A.consejera = P.consejera
				WHERE P.Año * 100 + P.Campaña = ' + CAST(@PeriodoActual AS VARCHAR) --+ ''
			
				PRINT @Dinamico
				EXEC SP_SQLEXEC @Dinamico

				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH

		END

		IF @tipoConfiguracion = 2
		BEGIN
			BEGIN TRY
				CREATE TABLE #BaseNivelRetencion (CONSEJERA INT, NIVELGANADO INT)
				CREATE TABLE #BaseBonoNivelRetencion (NivelGanado INT, BonoExtra INT)

				INSERT INTO #BaseNivelRetencion
				SELECT DISTINCT 
				P.consejera GANADORA
				,P.NIVEL_GANADO 
				--INTO #GANADORAS11820
				FROM P_ELITE_NUEVO_PREVIO P (NOLOCK)
				INNER JOIN P_HISTORICO_GANADORAS_ELITE H (NOLOCK) ON P.consejera = H.consejera AND H.Año * 100 + H.Campaña = @PeriodoAnterior 
				WHERE P.NIVEL_GANADO >= H.NIVEL_GANADO

				INSERT INTO #BaseBonoNivelRetencion
				SELECT P_INICIO_NIVEL, P_MONTOBONO
				FROM P_RangosInvitadasEmprendedoras (NOLOCK) WHERE P_BONOID = @Id

				INSERT INTO #ResultadoGanadoras
				SELECT @Año, @campaña, @Id, CONSEJERA, BonoExtra
				FROM #BaseNivelRetencion A (NOLOCK)
				INNER JOIN #BaseBonoNivelRetencion B (NOLOCK) ON A.NIVELGANADO = B.NivelGanado
			
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'TRADICIONAL', 'spEvaluaBonosExtraEmpTrd', 'Ejecución exitosa de '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'.')
			END TRY
			BEGIN CATCH
				INSERT INTO EMPRENDEDORAS_BITACORA 
				VALUES (GETDATE(), 'Tradicional', 'spEvaluaBonosExtraEmpTrd', 
					'Fallo en '+ @Descripcion +'. Tipo '+CAST(@tipo AS VARCHAR)+' Configuración '+CAST(@tipoConfiguracion AS VARCHAR)+'. Error: ' + ERROR_MESSAGE())
			END CATCH
		END
	END



	--UPDATE P
	--SET P.bono = P.bono + R.Bono
	--FROM P_BonoExtra P
	--INNER JOIN #ResultadoGanadoras R ON P.Consejera = R.EmprendedoraGanadora AND R.Bono > 0

	--Insertamos en la tabla de P_BonoExtra los resultados de esta evaluacion, acá solo se evaluó un ID y no importa que se inserten, jamás habran repetidos porque en el paso
	--anterior se limpio la tabla y se esta recorriendo todos los IDs de esta campaña
	INSERT INTO BonoExtraEmprendedor
	SELECT @Año, @campaña, @Id, EmprendedoraGanadora, Bono
	FROM #ResultadoGanadoras R(NOLOCK) 
	--WHERE EmprendedoraGanadora NOT IN (SELECT Consejera FROM dbo.P_BonoInvitadas_Extra B(NOLOCK) WHERE Año = @Año AND Campaña = @Campaña)

END

--SELECT * FROM P_BonoInvitadas_Extra (NOLOCK)

