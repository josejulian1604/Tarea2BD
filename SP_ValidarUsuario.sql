SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE ValidarUsuario
	@inUserName VARCHAR(16)
	, @inPassword VARCHAR(16)
	, @outResultCode INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	BEGIN TRY
		IF NOT EXISTS (
		SELECT U.UserName
		FROM [dbo].[Usuario] U
		WHERE BINARY_CHECKSUM(U.UserName) = BINARY_CHECKSUM(@inUserName) 
		AND BINARY_CHECKSUM(U.Password) = BINARY_CHECKSUM(@inPassword)
		)
		BEGIN
			SET @outResultCode = 50006 -- Datos incorrectos
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
    
	SELECT @outResultCode AS ResultCode

	SET NOCOUNT OFF;
END;
GO