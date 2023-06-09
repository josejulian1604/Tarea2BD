USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[InsertarArticulo]    Script Date: 4/11/2023 9:29:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertarArticulo]
    @inClaseArticulo VARCHAR(124)	-- Nombre de la clase articulo
    , @inNombre VARCHAR(124)		-- Nuevo articulo
    , @inPrecio MONEY				-- Precio del nuevo articulo
	, @inPostIdUser INT				-- El usuario que lo realiza
	, @inPostIp VARCHAR(64)			-- La IP de la estacion que realiza el acceso
    , @outResultCode INT OUTPUT		-- Codigo de resultado
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

		IF (ISNUMERIC(@inPrecio) = 0) OR (@inPrecio = '')
		BEGIN
			SET @outResultCode = 50003; -- Error: el valor del precio no es un precio monetario correcto
		END;

		ELSE IF (@inNombre = '') OR (@inClaseArticulo = '')
		BEGIN
			SET @outResultCode = 50002; -- Error: nombre mal formado
		END;

		ELSE IF (SELECT COUNT(Nombre) 
			FROM [dbo].[Articulo]
			WHERE (Nombre = @inNombre)) >= 1
		BEGIN
			SET @outResultCode = 50004; -- Error: ya existe un articulo con ese nombre
		END;

		ELSE IF (@outResultCode = 0) -- En caso cumplir con las validaciones
		BEGIN
			
			INSERT INTO @LogDescription
					(TipoAccion
					, ValorDescripcion)
			VALUES ('Insertar articulo exitoso'
					, CONCAT((SELECT CA.Id
								FROM [dbo].[ClaseArticulo] CA
								WHERE CA.Nombre = @inClaseArticulo)
								, ','
								, @inNombre
								, ','
								, @inPrecio))

			SELECT @description = (
				SELECT LD.TipoAccion
					, LD.ValorDescripcion
				FROM @LogDescription LD
				FOR JSON AUTO
			);

			BEGIN TRANSACTION TInsercionExitosa

				INSERT INTO [dbo].[Articulo] 
						(IdClaseArticulo
						, Nombre
						, Precio)
				SELECT CA.Id
						, @inNombre
						, @inPrecio
				FROM [dbo].[ClaseArticulo] CA
				WHERE CA.Nombre = @inClaseArticulo

				INSERT INTO [dbo].[EventLog]
						(LogDescription
						, PostIdUser
						, PostIP
						, PostTime)
				VALUES (@description
						, @inPostIdUser
						, @inPostIp
						, (GETDATE()))

			COMMIT TRANSACTION TInsercionExitosa
		END;

		IF (@outResultCode != 0) -- Si no se cumplio con alguna de las validaciones
		BEGIN
			
			INSERT INTO @LogDescription
					(TipoAccion
					, ValorDescripcion)
			VALUES ('Insercion de articulo no exitosa'
					, CONCAT((SELECT CA.Id 
							FROM [dbo].ClaseArticulo CA
							WHERE CA.Nombre = @inClaseArticulo)
							, ','
							, @inNombre
							, ','
							, @inPrecio))

			SELECT @description = (
				SELECT LD.TipoAccion
					, LD.ValorDescripcion
				FROM @LogDescription LD
				FOR JSON AUTO
			);

			BEGIN TRANSACTION TInsercionNoExitosa

				INSERT INTO [dbo].[EventLog]
						(LogDescription
						, PostIdUser
						, PostIP
						, PostTime)
				VALUES (@description
						, @inPostIdUser
						, @inPostIp
						, (GETDATE()))

			COMMIT TRANSACTION TInsercionNoExitosa
		END;
	END TRY
	BEGIN CATCH
		
		IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION TInsercionExitosa;
			ROLLBACK TRANSACTION TInsercionNoExitosa;
		END;

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