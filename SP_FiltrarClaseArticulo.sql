USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[FiltrarClaseArticulo]    Script Date: 4/7/2023 4:45:14 PM ******/
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

		SET @outResultCode = 0; -- Codigo por default que indica que no hubo error

		SELECT A.Id
		, A.Nombre
		, CA.Nombre AS ClaseArticulo
		, A.Precio
		FROM [dbo].[Articulo] A
		INNER JOIN [dbo].[ClaseArticulo] CA ON A.IdClaseArticulo = CA.Id
		WHERE CA.Nombre = @inClaseArticulo
		ORDER BY A.Nombre ASC;

		BEGIN TRANSACTION TConsultaClaseArticulo

			DELETE [dbo].[LogDescription]

			INSERT INTO [dbo].[LogDescription]
					(TipoAccion
					, ValorDescripcion)
			VALUES ('Consulta por clase de articulo'
					, @inClaseArticulo)

			SELECT @description = (
				SELECT LD.TipoAccion
					, LD.ValorDescripcion
				FROM [dbo].[LogDescription] LD
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
					, (SELECT GETDATE()))

		COMMIT TRANSACTION TConsultaClaseArticulo

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION TConsultaClaseArticulo;
		END;
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