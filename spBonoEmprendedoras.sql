/****** Object:  StoredProcedure [dbo].[spBonoEmprendedoras]    Script Date: 28/01/2025 07:48:01 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Arturo Vargas Triujeque
-- Create date: 2022-12-22
-- Description:	Bonos emprendedoras

-- Modificador: Gilberto Andrade
-- Create date: 09/09/2024
-- Description:	Se le da formato y justificación a toda la consulta

-- Modificador: Gilberto Andrade
-- Create date: 21/10/2024
-- Description:	Se modifica la parte de insercion de configuracion de un bono, se agrega el inicio y final del nivel a calificar


-- =============================================
--[spBonoEmprendedoras] 7
CREATE PROCEDURE [dbo].[spBonoEmprendedoras]
	
	@opcion int,
	@idBono int = 0,
	@tipo int = 0,
	@ini int = 0,
	@fin int = 0,
	@monto numeric(11,2) = 0.00,
	@anio int = 0,
	@campania int = 0,
	@descripcion varchar(50) = '',
	@usuario varchar(20) = '',
	@estatus int = 0,
	@inicio int = 0,
	@inicioNivel int = 0,
	@finNivel int = 0,
	@tipoConfiguracion int = 0,
	@periodoComparacion int = 0,
	@pedidoMinimo int = 0,
	@retencion int = 0

AS
BEGIN
	--Llena los datos de los bonos
	IF @opcion = 1
	BEGIN
		--SELECT DISTINCT
		--	E_IDBONO AS IdBono, 
		--	E_AÑO AS Anio, 
		--	E_CAMPAÑA AS Campania, 
		--	--CASE 
		--	--	WHEN E_DESCRIPCION = 'BONO_ESP' THEN 'BONO INV. CALIFICADAS' 
		--	--	WHEN E_DESCRIPCION = 'BONO_RET' THEN 'BONO DE RETENCIÓN' 
		--	--	WHEN E_DESCRIPCION = 'BONO_EST' THEN 'BONO DE ESTRUCTURA' 
		--	--	WHEN E_DESCRIPCION = 'BONO_NIVEL' THEN 'BONO POR LOGRO DE NIVEL' 
		--	--	WHEN E_DESCRIPCION = 'BONO_NUEVO_EMPRENDEDOR' THEN 'BONO SER NUEVA EMPRENDEDORA' 
		--	--	WHEN E_DESCRIPCION LIKE 'BONO_PORNIVEL_%' THEN 
		--	--		'BONO POR LOGRO DE NIVEL ' + (
		--	--			SELECT P_NOMBRENIVEL 
		--	--			FROM SQL_Ventas.dbo.P_PARAMETROSELITE(NOLOCK) 
		--	--			WHERE P_NIVEL = SUBSTRING(E_DESCRIPCION, 15, LEN(E_DESCRIPCION) - 14)
		--	--		) 
		--	--END AS Bono, 
		--	--E_DESCRIPCION AS Bono,
		--	CTB.DESCRIPCION Bono,
		--	CASE 
		--		WHEN E_DESCRIPCION = 'BONO_RET' THEN CAST(E_ESTATUS AS VARCHAR) 
		--		ELSE '----' 
		--	END AS CampaniaRetencion, 
		--	CASE 
		--		WHEN E_DESCRIPCION = 'BONO_EST' THEN CAST(E_ESTATUS AS VARCHAR) 
		--		ELSE '----' 
		--	END AS CampaniaEvaluacion, 
		--	CONVERT(VARCHAR(10), E_FECHA, 111) AS FechaAlta,
		--	ISNULL(P_TIPO, 0) AS TipoBono,
		--	ISNULL(P_TIPO_CONFIGURACION, 0) AS TipoBonoConfiguracion
		--FROM 
		--	SQL_Ventas.dbo.P_ESTATUS_EMPRENDEDORA(NOLOCK) 
		--LEFT JOIN 
		--	SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras (NOLOCK) ON P_BONOID = E_IDBONO
		--LEFT JOIN
		--	SQL_Ventas.dbo.P_Cat_TipoBono CTB (NOLOCK) ON P_TIPO = CTB.IDTipoBono
		----LEFT JOIN
		----	SQL_Ventas.dbo.P_Cat_TipoBonoConfiguracion CTBC (NOLOCK) ON P_TIPO_CONFIGURACION = CTBC.IDTipoBonoConfiguracion
		--WHERE 
		--	E_DESCRIPCION LIKE 'BONO_%' --and P_BONOID IN (3052, 3042, 2781, 3045)
		--ORDER BY 
		--	E_IDBONO DESC;
		--	--E_AÑO DESC, 
		--	--E_CAMPAÑA DESC;

		SELECT 
		E_IDBONO IdBono,
		E_AÑO Anio,
		E_CAMPAÑA Campania,
		CONCAT(C.Descripcion, ' ', ISNULL(C2.Descripcion, '')) Bono,
		CONVERT(VARCHAR(10), E_FECHA, 111) FechaAlta,
		ISNULL(P_TIPO, 0) TipoBono,
		ISNULL(P_TIPO_CONFIGURACION, 0) TipoBonoConfiguracion,
		isnull(E_DESCRIPCION_BONO, '') DescripcionBono
		--,E.*, R.P_TIPO, R.P_TIPO_CONFIGURACION, C.Descripcion, C2.Descripcion
		FROM SQL_Ventas.dbo.P_Estatus_Emprendedora E (NOLOCK)
		INNER JOIN SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras R (NOLOCK) ON E_IDBONO = P_BONOID
		INNER JOIN SQL_Ventas.dbo.P_Cat_TipoBono C (NOLOCK) ON C.IDTipoBono = P_TIPO
		LEFT JOIN SQL_Ventas.dbo.P_Cat_TipoBonoConfiguracion C2 (NOLOCK) ON P_TIPO_CONFIGURACION = IDTipoBonoConfiguracion AND P_TIPO = C2.IDTipoBono
		WHERE E_DESCRIPCION LIKE 'BONO_%'
		GROUP BY E_IDBONO, E_AÑO, E_CAMPAÑA, CONCAT(C.Descripcion, ' ', ISNULL(C2.Descripcion, '')), E_FECHA, P_TIPO, P_TIPO_CONFIGURACION, E_DESCRIPCION_BONO
		ORDER BY 1 DESC, 2 DESC

	END

	IF @opcion = 2
	BEGIN
		SELECT 
			E_IDBONO AS IdBono, 
			E_AÑO AS Anio, 
			E_CAMPAÑA AS Campania, 
			CASE 
				WHEN E_DESCRIPCION = 'BONO_ESP' THEN 'BONO INV. CALIFICADAS' 
				WHEN E_DESCRIPCION = 'BONO_RET' THEN 'BONO DE RETENCIÓN' 
				WHEN E_DESCRIPCION = 'BONO_EST' THEN 'BONO DE ESTRUCTURA' 
				WHEN E_DESCRIPCION = 'BONO_NIVEL' THEN 'BONO POR LOGRO DE NIVEL' 
				WHEN E_DESCRIPCION LIKE 'BONO_PORNIVEL_%' THEN 
					'BONO POR LOGRO DE NIVEL ' + (
						SELECT P_NOMBRENIVEL 
						FROM SQL_Ventas.dbo.P_PARAMETROSELITE(NOLOCK) 
						WHERE P_NIVEL = SUBSTRING(E_DESCRIPCION, 15, LEN(E_DESCRIPCION) - 14)
					) 
			END AS Bono, 
			CASE 
				WHEN E_DESCRIPCION = 'BONO_RET' THEN CAST(E_ESTATUS AS VARCHAR) 
				ELSE '----' 
			END AS CampaniaRetencion, 
			CASE 
				WHEN E_DESCRIPCION = 'BONO_EST' THEN CAST(E_ESTATUS AS VARCHAR) 
				ELSE '----' 
			END AS CampaniaEvaluacion, 
			CONVERT(VARCHAR(10), E_FECHA, 111) AS FechaAlta
		FROM 
			SQL_Ventas.dbo.P_ESTATUS_EMPRENDEDORA_HISTORICO(NOLOCK) 
		WHERE 
			E_DESCRIPCION LIKE 'BONO_%' 
		ORDER BY 
			E_AÑO DESC, 
			E_CAMPAÑA DESC;
	END

	IF @opcion = 3
	BEGIN
		IF EXISTS (SELECT * FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras(NOLOCK) WHERE P_BONOID = @idBono)
		BEGIN
			SELECT 
				P_BONOID AS IdBono, 
				P_INI AS Ini, 
				P_FIN AS Fin, 
				P_TIPO AS Tipo, 
				P_MONTOBONO AS Monto,
				P_INICIO AS Inicio, 
				ISNULL(P_INICIO_NIVEL, 0) AS InicioNivel, 
				ISNULL(P_FIN_NIVEL, 0) AS FinNivel,
				ISNULL(I.P_NOMBRENIVEL, '') AS NombreInicioNivel,
				ISNULL(F.P_NOMBRENIVEL, '') AS NombreFinNivel,
				ISNULL(P_tipo_configuracion, 0) AS TipoConfiguracion,
				ISNULL(P_PERIODO_COMPARACION, 0) AS PeriodoComparacion,
				ISNULL(P_PEDIDO_MINIMO, 0) AS PedidoMinimo,
				ISNULL(P_RETENCION, 0) AS Retencion
			FROM 
				SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras(NOLOCK) 
			LEFT JOIN
				SQL_Ventas.dbo.P_ParametrosElite I (NOLOCK) ON I.P_Nivel = P_INICIO_NIVEL
			LEFT JOIN
				SQL_Ventas.dbo.P_ParametrosElite F (NOLOCK) ON F.P_Nivel = P_FIN_NIVEL
			WHERE 
				P_BONOID = @idBono;
		END
		ELSE
		BEGIN
			SELECT 
				IdBono = 0, 
				Ini = 0, 
				Fin = 0, 
				Tipo = 0, 
				Monto = 0,
				Inicio = 0, 
				InicioNivel = 0, 
				FinNivel = 0,
				TipoConfiguracion = 0,
				PeriodoComparacion = 0,
				PedidoMinimo = 0,
				Retencion = 0
		END
	END

	IF @opcion = 4
	BEGIN
		DELETE FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras WHERE P_BONOID = @idBono;

		SELECT 
			Respuesta = 1, 
			Mensaje = 'Bono eliminado';
	END

	--Inserta
	IF @opcion = 5
	BEGIN
		INSERT INTO SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras(P_BONOID, P_INI, P_FIN, P_TIPO, P_MONTOBONO, P_INICIO, P_INICIO_NIVEL, P_FIN_NIVEL, P_TIPO_CONFIGURACION, P_PERIODO_COMPARACION, P_PEDIDO_MINIMO, P_RETENCION) 
		VALUES(@idBono, @ini, @fin, @tipo, @monto, @inicio, @inicioNivel, @finNivel, @tipoConfiguracion, @periodoComparacion, @pedidoMinimo, @retencion);

		IF @tipo = 1
		BEGIN
			DECLARE @DescripcionBono VARCHAR(MAX) = ''
			IF @tipoConfiguracion = 1
			BEGIN
				SET @DescripcionBono = 'Bono Extra Invitadas Calificadas, gana $' + CAST(@monto as varchar) + ' por cada '+CAST(@ini AS VARCHAR)+' invitadas calificadas, iniciando desde '+CAST(@inicio AS VARCHAR)+' invitadas calificadas.'
			END
			IF @tipoConfiguracion IN (2, 3)
			BEGIN
				IF @tipoConfiguracion = 2 BEGIN SET @DescripcionBono = 'Bono Extra Meta Especifica por Intervalo </br>' END
				IF @tipoConfiguracion = 3 BEGIN SET @DescripcionBono = 'Bono Extra Meta Especifica por Intervalo Acumulable </br>' END
				--SET @DescripcionBono = 'Bono Extra Meta Especifica por Intervalo'
				DECLARE MetaEspecificaIntervalo CURSOR FOR
				SELECT P_INI, P_FIN, P_MONTOBONO FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras WHERE P_BONOID = @idBono
				DECLARE @MEI_INICIO INT
				DECLARE @MEI_FIN INT
				DECLARE @MEI_BONO INT

				OPEN MetaEspecificaIntervalo
				FETCH NEXT FROM MetaEspecificaIntervalo INTO @MEI_INICIO, @MEI_FIN, @MEI_BONO

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @DescripcionBono += 'DE ' +CAST(@MEI_INICIO AS VARCHAR)+ ' A ' +CAST(@MEI_FIN AS VARCHAR)+ ' GANA $'+CAST(@MEI_BONO AS varchar)+' </br>'
					FETCH NEXT FROM MetaEspecificaIntervalo INTO @MEI_INICIO, @MEI_FIN, @MEI_BONO
				END
				CLOSE MetaEspecificaIntervalo
				DEALLOCATE MetaEspecificaIntervalo
			END
			IF @tipoConfiguracion = 4
			BEGIN
				SET @DescripcionBono = 'Bono Extra Invitadas Calificadas por Nivel de Emprendedor </br>'
				DECLARE MetaInvitadasNivel CURSOR FOR
				SELECT P_INI, P_FIN, P_MONTOBONO, P1.P_NombreNivel, P2.P_NombreNivel 
				FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras R 
				LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P1 ON P1.P_Nivel = R.P_INICIO_NIVEL
				LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P2 ON P2.P_Nivel = R.P_FIN_NIVEL
				WHERE P_BONOID = @idBono
				DECLARE @MIN_INICIO INT
				DECLARE @MIN_FIN INT
				DECLARE @MIN_BONO INT
				DECLARE @MIN_INICIO_NIVEL VARCHAR(MAX)
				DECLARE @MIN_FIN_NIVEL VARCHAR(MAX)

				OPEN MetaInvitadasNivel
				FETCH NEXT FROM MetaInvitadasNivel INTO @MIN_INICIO, @MIN_FIN, @MIN_BONO, @MIN_INICIO_NIVEL, @MIN_FIN_NIVEL

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @MIN_INICIO_NIVEL = @MIN_FIN_NIVEL
					BEGIN
						SET @DescripcionBono += 'PARA NIVEL ' + @MIN_INICIO_NIVEL
					END
					ELSE
					BEGIN
						SET @DescripcionBono += 'PARA NIVEL ' + @MIN_INICIO_NIVEL + ' A '+@MIN_FIN_NIVEL
					END
					SET @DescripcionBono += ' DE ' +CAST(@MIN_INICIO AS VARCHAR)+ ' A ' +CAST(@MIN_FIN AS VARCHAR)+ ' GANA $'+CAST(@MIN_BONO AS varchar) +' </br>'

					FETCH NEXT FROM MetaInvitadasNivel INTO @MIN_INICIO, @MIN_FIN, @MIN_BONO, @MIN_INICIO_NIVEL, @MIN_FIN_NIVEL
				END
				CLOSE MetaInvitadasNivel
				DEALLOCATE MetaInvitadasNivel
			END
		END

		IF @tipo = 2 
		BEGIN 
			SET @DescripcionBono = 'Bono Extra por Retención de Invitadas </br>'
			--SET @DescripcionBono = 'Bono Extra Meta Especifica por Intervalo'
			DECLARE MetaRetencionInvitadas CURSOR FOR
			SELECT P_INI, P_FIN, P_MONTOBONO FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras WHERE P_BONOID = @idBono
			DECLARE @RI_INICIO INT
			DECLARE @RI_FIN INT
			DECLARE @RI_BONO INT

			OPEN MetaRetencionInvitadas
			FETCH NEXT FROM MetaRetencionInvitadas INTO @RI_INICIO, @RI_FIN, @RI_BONO

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @DescripcionBono += 'DE ' +CAST(@RI_INICIO AS VARCHAR)+ ' A ' +CAST(@RI_FIN AS VARCHAR)+ ' GANA $'+CAST(@RI_BONO AS varchar)+' </br>'
				FETCH NEXT FROM MetaRetencionInvitadas INTO @RI_INICIO, @RI_FIN, @RI_BONO
			END
			CLOSE MetaRetencionInvitadas
			DEALLOCATE MetaRetencionInvitadas
		END

		IF @tipo = 3
		BEGIN
			IF @tipoConfiguracion = 1
			BEGIN
				SET @DescripcionBono = 'Bono Extra por cada Nuevo Desarrollo de Hija, gana $' + CAST(@monto as varchar)
			END
			IF @tipoConfiguracion = 2 
			BEGIN 
				SET @DescripcionBono = 'Bono Extra por Incremento de Hijos Activos comparado con C'+CAST(RIGHT(@periodoComparacion,2) as varchar)+' del '+CAST(LEFT(@periodoComparacion,4) as varchar)+' </br>'
				--SET @DescripcionBono = 'Bono Extra Meta Especifica por Intervalo'
				DECLARE MetaIncrementoHijos CURSOR FOR
				SELECT P_INI, P_FIN, P_MONTOBONO, P_INICIO, P_PERIODO_COMPARACION, P_RETENCION FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras WHERE P_BONOID = @idBono
				DECLARE @IH_INICIO INT
				DECLARE @IH_FIN INT
				DECLARE @IH_BONO INT
				DECLARE @IH_DESDE INT
				DECLARE @IH_PERIODO INT
				DECLARE @IH_RETENCION INT

				OPEN MetaIncrementoHijos
				FETCH NEXT FROM MetaIncrementoHijos INTO @IH_INICIO, @IH_FIN, @IH_BONO, @IH_DESDE, @IH_PERIODO, @IH_RETENCION

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @IH_INICIO <> 0 AND @IH_FIN <> 0
					BEGIN
						SET @DescripcionBono += 'DE ' +CAST(@IH_INICIO AS VARCHAR)+ ' A ' +CAST(@IH_FIN AS VARCHAR)+ ' GANA $'+CAST(@IH_BONO AS varchar)+' </br>'
					END
					IF @IH_RETENCION = 1
					BEGIN
						SET @DescripcionBono += 'Además si no calificó en la campaña C'+CAST(RIGHT(@periodoComparacion,2) as varchar)+' del '+CAST(LEFT(@periodoComparacion,4) as varchar)+', Y tiene a partir de ' + CAST(@IH_DESDE AS VARCHAR) + ' hijas, GANA $'+CAST(@IH_BONO AS varchar)+' </br>'
					END
					FETCH NEXT FROM MetaIncrementoHijos INTO @IH_INICIO, @IH_FIN, @IH_BONO, @IH_DESDE, @IH_PERIODO, @IH_RETENCION
				END
				CLOSE MetaIncrementoHijos
				DEALLOCATE MetaIncrementoHijos
			END
		END

		IF @tipo = 4
		BEGIN
			SET @DescripcionBono = 'Bono Extra por Logro de Nivel </br>'
				DECLARE MetaLogroNivel CURSOR FOR
				SELECT P_MONTOBONO, P1.P_NombreNivel 
				FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras R 
				LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P1 ON P1.P_Nivel = R.P_INICIO_NIVEL
				LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P2 ON P2.P_Nivel = R.P_FIN_NIVEL
				WHERE P_BONOID = @idBono
				DECLARE @LOGRO_NIVEL_BONO INT
				DECLARE @LOGRO_NIVEL_INICIO_NIVEL VARCHAR(MAX)

				OPEN MetaLogroNivel
				FETCH NEXT FROM MetaLogroNivel INTO @LOGRO_NIVEL_BONO, @LOGRO_NIVEL_INICIO_NIVEL

				WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @DescripcionBono += 'PARA NIVEL ' + @LOGRO_NIVEL_INICIO_NIVEL
					SET @DescripcionBono += ' RECIBE $' +CAST(@LOGRO_NIVEL_BONO AS varchar) +' </br>'

					FETCH NEXT FROM MetaLogroNivel INTO @LOGRO_NIVEL_BONO, @LOGRO_NIVEL_INICIO_NIVEL
				END
				CLOSE MetaLogroNivel
				DEALLOCATE MetaLogroNivel
		END

		IF @tipo = 5
		BEGIN
			SET @DescripcionBono = 'Bono Extra por ser Emprendedora por primera vez, gana $' + CAST(@monto as varchar)
		END

		IF @tipo = 6
		BEGIN
			IF @tipoConfiguracion = 1
			BEGIN
				DECLARE @CampaniaBono INT, @AnioBono INT
				SELECT @CampaniaBono = E_CAMPAÑA, @AnioBono = E_AÑO FROM SQL_Ventas.dbo.P_Estatus_Emprendedora (NOLOCK) WHERE E_IDBONO = @idBono
				SET @DescripcionBono = 'Bono Extra por ser Emprendedora por primera vez y retenerte en campaña C' + CAST(@CampaniaBono as varchar) + ' ' + CAST(@AnioBono as varchar) + '. Gana $' + CAST(@monto as varchar)
			END

			IF @tipoConfiguracion = 2
			BEGIN
				BEGIN
					SET @DescripcionBono = 'Bono Extra por Retención de Nivel </br>'
					DECLARE MetaRetencionNivel CURSOR FOR
					SELECT P_MONTOBONO, P1.P_NombreNivel 
					FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras R 
					LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P1 ON P1.P_Nivel = R.P_INICIO_NIVEL
					LEFT JOIN SQL_Ventas.dbo.P_ParametrosElite P2 ON P2.P_Nivel = R.P_FIN_NIVEL
					WHERE P_BONOID = @idBono
					DECLARE @RETENCION_NIVEL_BONO INT
					DECLARE @RETENCION_NIVEL_INICIO_NIVEL VARCHAR(MAX)

					OPEN MetaRetencionNivel
					FETCH NEXT FROM MetaRetencionNivel INTO @RETENCION_NIVEL_BONO, @RETENCION_NIVEL_INICIO_NIVEL

					WHILE @@FETCH_STATUS = 0
					BEGIN

						SET @DescripcionBono += 'PARA NIVEL ' + @RETENCION_NIVEL_INICIO_NIVEL
						SET @DescripcionBono += ' RECIBE $' +CAST(@RETENCION_NIVEL_BONO AS varchar) +' </br>'

						FETCH NEXT FROM MetaRetencionNivel INTO @RETENCION_NIVEL_BONO, @RETENCION_NIVEL_INICIO_NIVEL
					END
					CLOSE MetaRetencionNivel
					DEALLOCATE MetaRetencionNivel
				END
			END
		END

		UPDATE SQL_Ventas.dbo.P_Estatus_Emprendedora SET E_DESCRIPCION_BONO = @DescripcionBono WHERE E_IDBONO = @idBono	 

		SELECT 
			Respuesta = 1, 
			Mensaje = 'Bono ingresado';
	END
	
	IF @opcion = 6
	BEGIN
		IF EXISTS (
			SELECT FECPER_FECHA_FIN 
			FROM SQL_Ventas.dbo.V_PERIODOS(NOLOCK) 
			WHERE 
				FECPER_NUMCIA = 1 
				AND FECPER_TIPO_PERI = 'CA' 
				AND FECPER_ANO_PERI = @anio 
				AND FECPER_NUM_PERI = @campania 
				AND FECPER_FECHA_FIN <= CONVERT(VARCHAR, GETDATE(), 111)
		)
		BEGIN
			SELECT 
				Respuesta = 0, 
				Mensaje = 'Ya se ha realizado la calificación de este bono y ya no podrá ser eliminado';
		END
		ELSE
		BEGIN
			DELETE FROM SQL_Ventas.dbo.P_Estatus_Emprendedora WHERE E_IDBONO = @idBono;
			DELETE FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras WHERE P_BONOID = @idBono;

			SELECT 
				Respuesta = 1, 
				Mensaje = 'Bono correctamente Eliminado';
		END
	END

	IF @opcion = 7
	BEGIN

	------------------------------------------------------------------------------------------hay que volver a activar esto para revisar que lo que se este configurando este vigente
		--IF EXISTS (
		--	SELECT FECPER_FECHA_FIN 
		--	FROM SQL_Ventas.dbo.V_PERIODOS(NOLOCK) 
		--	WHERE 
		--		FECPER_NUMCIA = 1 
		--		AND FECPER_TIPO_PERI = 'CA' 
		--		AND FECPER_ANO_PERI = @anio 
		--		AND FECPER_NUM_PERI = @campania 
		--		AND FECPER_FECHA_FIN <= CONVERT(VARCHAR, GETDATE(), 111)
		--)
		--BEGIN
		--	SELECT 
		--		Respuesta = 0, 
		--		Mensaje = 'No puedes programar una calificación para campañas anteriores a la actual';
		--END
		----ELSE IF EXISTS (
		----	SELECT * 
		----	FROM SQL_Ventas.dbo.P_ESTATUS_EMPRENDEDORA(NOLOCK) 
		----	WHERE 
		----		E_DESCRIPCION = @descripcion 
		----		AND E_AÑO = @anio 
		----		AND E_CAMPAÑA = @campania
		----)
		----BEGIN
		----	SELECT 
		----		Respuesta = 0, 
		----		Mensaje = 'Ya existe un bono con las mismas características favor de revisar';
		----END
		--ELSE
		BEGIN

				--WHEN E_DESCRIPCION = 'BONO_ESP' THEN 'BONO INV. CALIFICADAS' 
				--WHEN E_DESCRIPCION = 'BONO_RET' THEN 'BONO DE RETENCIÓN' 
				--WHEN E_DESCRIPCION = 'BONO_EST' THEN 'BONO DE ESTRUCTURA' 
				--WHEN E_DESCRIPCION = 'BONO_NIVEL' THEN 'BONO POR LOGRO DE NIVEL' 

			SET @descripcion = CASE WHEN @tipo = 1 THEN 'BONO_ESP'
									WHEN @tipo = 2 THEN 'BONO_RET'
									WHEN @tipo = 3 THEN 'BONO_EST'
									WHEN @tipo = 4 THEN 'BONO_NIVEL'
									WHEN @tipo = 5 THEN 'BONO_NUEVO_EMPRENDEDOR'
									WHEN @tipo = 6 THEN 'BONO_RETENCION_EMPRENDEDOR'
									ELSE 'HOLA' END

			INSERT INTO SQL_Ventas.dbo.P_ESTATUS_EMPRENDEDORA(E_DESCRIPCION, E_AÑO, E_CAMPAÑA, E_ESTATUS, E_FECHA, E_USUARIO) 
			VALUES(@descripcion, @anio, @campania, @estatus, GETDATE(), @usuario);

			--SELECT SCOPE_IDENTITY() AS UltimoID;

			--SELECT 
			--	Respuesta = 1, 
			--	Mensaje = 'Bono correctamente ingresado';

			SELECT Respuesta = 1, Mensaje = 'Bono correctamente ingresado', E_IDBONO AS IdBono FROM SQL_Ventas.dbo.P_ESTATUS_EMPRENDEDORA (NOLOCK) WHERE E_IDBONO = SCOPE_IDENTITY();
		END
	END

	IF @opcion = 8
	BEGIN
		SELECT 	P_BONOID AS IdBono, 
				P_INI AS Ini, 
				P_FIN AS Fin, 
				P_TIPO AS Tipo, 
				P_MONTOBONO AS Monto,
				P_INICIO AS Inicio,
				P_INICIO_NIVEL AS InicioNivel,
				P_FIN_NIVEL AS FinNivel,
				P_TIPO_CONFIGURACION AS TipoConfiguracion,
				P_PERIODO_COMPARACION AS PeriodoComparacion, 
				P_PEDIDO_MINIMO  AS PedidoMinimo,
				P_RETENCION AS Retencion
		FROM SQL_Ventas.dbo.P_RangosInvitadasEmprendedoras (NOLOCK) ORDER BY P_BONOID DESC
	END
END
GO