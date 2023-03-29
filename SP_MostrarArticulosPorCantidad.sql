SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MostrarArticulosPorCantidad]
    @inCantidad INT
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

	SET @outResultCode = 0

	IF @inCantidad = 0
    BEGIN
        SELECT A.Id, A.Nombre, A.Precio, C.Nombre AS ClaseArticulo
        FROM Articulo A
        INNER JOIN ClaseArticulo C ON A.IdClaseArticulo = C.Id
        ORDER BY A.Nombre ASC;
    END
    ELSE IF @inCantidad > 0
    BEGIN
        SELECT TOP(@inCantidad) 
			A.Id
			, A.Nombre
			, A.Precio
			, C.Nombre AS ClaseArticulo
        FROM [dbo].[Articulo] A
        INNER JOIN [dbo].[ClaseArticulo] C ON A.IdClaseArticulo = C.Id
        ORDER BY A.Nombre ASC;
    END
    ELSE
    BEGIN
        SET @outResultCode = 50006 -- Numero mal formado
    END

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
END
GO

EXEC MostrarArticulosPorCantidad 10, 0