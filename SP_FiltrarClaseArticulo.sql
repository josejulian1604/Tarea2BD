SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE FiltrarClaseArticulo
	@inClaseArticulo VARCHAR(64)
	, @outResultCode INT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
		SET @outResultCode = 0 -- Codigo por default que indica que no hubo error

		SELECT A.Id
		, A.Nombre
		, CA.Nombre AS ClaseArticulo
		, A.Precio
		FROM [dbo].[Articulo] A
		INNER JOIN [dbo].[ClaseArticulo] CA ON A.IdClaseArticulo = CA.Id
		WHERE CA.Nombre = @inClaseArticulo
		ORDER BY A.Nombre ASC;
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

END
GO