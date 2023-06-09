USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[ValidarUsuario]    Script Date: 4/11/2023 10:27:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ValidarUsuario]
	@inUserName VARCHAR(16)			-- Nombre de usuario ingresado
	, @inPassword VARCHAR(16)		-- Password ingresado
	, @inPostIdUser INT				-- El usuario que lo realiza
	, @inPostIp VARCHAR(64)			-- La IP de la estacion que realiza el acceso
	, @outResultCode INT OUTPUT		-- Codigo de resultado
AS
BEGIN
	
	SET NOCOUNT ON;
	
	BEGIN TRY
		
		DECLARE @description VARCHAR(2000); -- Almacena el json
		DECLARE @LoginStatus VARCHAR(64); -- Indica si el login fue o no exitoso

		DECLARE @LogDescription TABLE (
			TipoAccion VARCHAR(64)
			, ValorDescripcion VARCHAR(128)
		);

		IF NOT EXISTS (
		SELECT U.UserName
		FROM [dbo].[Usuario] U
		WHERE BINARY_CHECKSUM(U.UserName) = BINARY_CHECKSUM(@inUserName) 
		AND BINARY_CHECKSUM(U.Password) = BINARY_CHECKSUM(@inPassword)
		)
		BEGIN
			SET @outResultCode = 50006; -- Datos incorrectos
			SET @LoginStatus = 'Login no exitoso';
		END;

		ELSE
		BEGIN
			SET @LoginStatus = 'Login exitoso';
		END;


		INSERT INTO @LogDescription
				(TipoAccion
				, ValorDescripcion)
		VALUES (@LoginStatus
				, '')

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