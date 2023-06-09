USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[FiltrarClaseArticulo]    Script Date: 4/11/2023 9:16:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- SP FiltrarClaseArticulo no valida el nombre de entrada
-- ya desde capa logica siempre va a haber un nombre de 
-- clase articulo seleccionado
-- =======================================================
ALTER PROCEDURE [dbo].[FiltrarClaseArticulo]
	@inClaseArticulo VARCHAR(64)	-- Nombre de entrada de la clase
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

		SET @outResultCode = 0; -- Codigo por default que indica que no hubo error

		SELECT A.Id
			, CA.Nombre AS ClaseArticulo
			, A.Nombre
			, A.Precio
		FROM [dbo].[Articulo] A
		INNER JOIN [dbo].[ClaseArticulo] CA ON A.IdClaseArticulo = CA.Id
		WHERE (CA.Nombre = @inClaseArticulo)
		ORDER BY A.Nombre ASC;


		INSERT INTO @temp
				(TipoAccion
				, ValorDescripcion)
		VALUES ('Consulta por clase de articulo'
				, @inClaseArticulo)

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
		
		INSERT INTO [dbo].[DBErrors]	
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

	SELECT @outResultCode AS CodigoResultado

	SET NOCOUNT OFF;

END;