ALTER PROCEDURE InsertarArticulo
    @inClaseArticulo VARCHAR(124)
    ,@inNombre VARCHAR(124)
    ,@inPrecio MONEY
    ,@outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY

		IF (ISNUMERIC(@inPrecio) = 0 OR @inPrecio = '')
		BEGIN
			SET @outResultCode = 50003 -- Error: el valor del precio no es un precio monetario correcto
		END;

		ELSE IF (@inNombre = '' OR @inClaseArticulo = '')
		BEGIN
			SET @outResultCode = 50002 -- Error: nombre mal formado
		END;

		ELSE IF (SELECT COUNT(Nombre) 
			FROM [dbo].[Articulo]
			WHERE Nombre = @inNombre) >= 1
		BEGIN
			SET @outResultCode = 50004 -- Error: ya existe un articulo con ese nombre
		END;

		ELSE IF (@outResultCode >= 0)
		BEGIN

			INSERT INTO [dbo].[Articulo] 
					(IdClaseArticulo
					, Nombre
					, Precio)
			SELECT CA.Id
			, @inNombre
			, @inPrecio
			FROM [dbo].[ClaseArticulo] CA
			WHERE CA.Nombre = @inClaseArticulo

		END;
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

    SELECT @outResultCode AS resultCode;

	SET NOCOUNT OFF;
END;