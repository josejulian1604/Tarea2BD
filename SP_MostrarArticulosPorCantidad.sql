USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[MostrarArticulosPorCantidad]    Script Date: 4/11/2023 10:20:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MostrarArticulosPorCantidad]
    @inCantidad INT					-- Cantidad de articulos por mostrar
	, @inPostIdUser INT				-- Id del usuario 
	, @inPostIp VARCHAR(64)			-- Direccion IP del usuario
	, @outResultCode INT OUTPUT		-- Codigo de resultado del SP
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @description VARCHAR(2000);

		DECLARE @LogDescription TABLE (
			TipoAccion VARCHAR(64)
			, ValorDescripcion VARCHAR(128)
		);

		SET @outResultCode = 0;

		IF (@inCantidad = 0) -- Equivalente a que el usuario no ingrese nada
		BEGIN

			SELECT A.Id
				, C.Nombre AS ClaseArticulo
				, A.Nombre
				, A.Precio
			FROM [dbo].[Articulo] A
			INNER JOIN [dbo].[ClaseArticulo] C ON A.IdClaseArticulo = C.Id
			ORDER BY A.Nombre ASC;

		END;

		ELSE IF (@inCantidad > 0)
		BEGIN

			SELECT TOP(@inCantidad) 
				A.Id
				, C.Nombre AS ClaseArticulo
				, A.Nombre
				, A.Precio
			FROM [dbo].[Articulo] A
			INNER JOIN [dbo].[ClaseArticulo] C ON A.IdClaseArticulo = C.Id
			ORDER BY A.Nombre ASC;

		END;

		ELSE
		BEGIN
			SET @outResultCode = 50006; -- Numero mal formado
		END;

		INSERT INTO @LogDescription
				(TipoAccion
				, ValorDescripcion)
		VALUES ('Consulta por cantidad'
				, @inCantidad)

		SELECT @description = (
			SELECT LD.TipoAccion
				, LD.ValorDescripcion
			FROM @LogDescription LD
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