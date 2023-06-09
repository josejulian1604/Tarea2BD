USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[BuscarArticuloPorNombre]    Script Date: 4/11/2023 8:29:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BuscarArticuloPorNombre]
    @inNombreArticulo VARCHAR(128)	-- Nombre articulo ingresado
	, @inPostIdUser INT				-- Id del usuario 
	, @inPostIp VARCHAR(64)			-- Direccion IP del usuario
	, @outResultCode INT OUTPUT		-- Codigo de resultado del SP

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @description VARCHAR(2000);

		DECLARE @temp TABLE (
			TipoAccion VARCHAR(64)
			, ValorDescripcion VARCHAR(128)
		);
	
		SET @outResultCode = 0;	-- Codigo por default que indica no hubo error

		IF (@inNombreArticulo IS NOT NULL) AND (@inNombreArticulo != '') AND (ISNUMERIC(@inNombreArticulo) = 0)
		BEGIN

		   SELECT A.Id
				, C.Nombre AS ClaseArticulo
				, A.Nombre
				, A.Precio
			FROM [dbo].[Articulo] A
			INNER JOIN [dbo].[ClaseArticulo] C ON A.IdClaseArticulo = C.Id
			WHERE (A.Nombre LIKE '%' + @inNombreArticulo + '%') AND (ISNUMERIC(A.Nombre) = 0)
			ORDER BY A.Nombre ASC;

        
			IF (@@ROWCOUNT = 0)
				BEGIN
					SET @outResultCode = 50001; -- No se encontro el nombre
				END;
		END;

		ELSE IF @inNombreArticulo = ''
			BEGIN

				SELECT A.Id
					, C.Nombre AS ClaseArticulo
					, A.Nombre
					, A.Precio
				FROM [dbo].[Articulo] A
				INNER JOIN [dbo].[ClaseArticulo] C ON A.IdClaseArticulo = C.Id
				ORDER BY A.Nombre ASC;

			END;

		ELSE
			BEGIN
				SET @outResultCode = 50002; -- Nombre invalido
			END;

		INSERT INTO @temp
				(TipoAccion
				, ValorDescripcion)
		VALUES ('Consulta por Nombre'
				, @inNombreArticulo)

		SELECT @description = (
			SELECT LD.TipoAccion
				, LD.ValorDescripcion
			FROM @temp LD
			FOR JSON AUTO
		);

		INSERT INTO [dbo].[EventLog]
				(LogDescription
				, PostIdUser
				, PostIP
				, PostTime)
		VALUES (@description
				, @inPostIdUser
				, @inPostIp
				, (GETDATE()))
	
	END TRY
	BEGIN CATCH
		
		INSERT INTO dbo.DBErrors	
		VALUES (
				SUSER_SNAME(),
				ERROR_NUMBER(),
				ERROR_STATE(),
				ERROR_SEVERITY(),
				ERROR_LINE(),
				ERROR_PROCEDURE(),
				ERROR_MESSAGE(),
				GETDATE()
			);

			SET @outResultCode=50005; -- Error en el try-catch

	END CATCH

	SELECT @outResultCode AS ResultCode

	SET NOCOUNT OFF;
END;