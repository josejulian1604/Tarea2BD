USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[InsertarArticulo]    Script Date: 4/5/2023 2:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[InsertarArticulo]
    @inClaseArticulo VARCHAR(124)	-- Nombre de la clase articulo
    ,@inNombre VARCHAR(124)			-- Nuevo articulo
    ,@inPrecio MONEY				-- Precio del nuevo articulo
	,@inPostIdUser INT				-- El usuario que lo realiza
	,@inPostIp VARCHAR(64)			-- La IP de la estacion que realiza el acceso
	,@inPostTime DATETIME			-- Fecha, hora, minuto, segundo y milesima de segundo del acceso
    ,@outResultCode INT OUTPUT		-- Codigo de resultado
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @description VARCHAR(2000);
		
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

		ELSE IF (@outResultCode = 0) -- En caso cumplir con las validaciones
		BEGIN							
			BEGIN TRANSACTION InsercionExitosa

				INSERT INTO [dbo].[Articulo] 
						(IdClaseArticulo
						, Nombre
						, Precio)
				SELECT CA.Id
				, @inNombre
				, @inPrecio
				FROM [dbo].[ClaseArticulo] CA
				WHERE CA.Nombre = @inClaseArticulo

				DELETE [dbo].[LogDescription]

				INSERT INTO [dbo].[LogDescription]
						(TipoAccion
						, ValorDescripcion)
				VALUES ('Insertar articulo exitoso'
						, CONCAT((SELECT TOP 1 IdClaseArticulo 
									FROM [dbo].[Articulo] ORDER BY Id DESC)
									, ','
									, @inNombre
									, ','
									, @inPrecio))

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
						, @inPostTime)

			COMMIT TRANSACTION InsercionExitosa
		END;

		IF (@outResultCode != 0) -- Si no se cumplio con alguna de las validaciones
		BEGIN
			BEGIN TRANSACTION InsercionNoExitosa

			DELETE [dbo].[LogDescription]

			INSERT INTO [dbo].[LogDescription]
					(TipoAccion
					, ValorDescripcion)
			VALUES ('Insercion de articulo no exitosa'
					, CONCAT((SELECT CA.Id 
							FROM [dbo].ClaseArticulo CA
							WHERE CA.Nombre = @inClaseArticulo)
							, ','
							, @inNombre
							, ','
							,@inPrecio))

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
						, @inPostTime)

			COMMIT TRANSACTION InsercionNoExitosa
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