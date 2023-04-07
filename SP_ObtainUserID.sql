GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE UserID
	
	@inNombre VARCHAR(16)
	, @outResultCode INT
AS
BEGIN
	
	SET NOCOUNT ON;

    BEGIN TRY
		
		SET @outResultCode = 0

		IF EXISTS (SELECT U.Id
				FROM [dbo].[Usuario] U
				WHERE BINARY_CHECKSUM(UserName) = BINARY_CHECKSUM(@inNombre))
		BEGIN

			SELECT U.Id AS Id
			FROM [dbo].[Usuario] U
			WHERE UserName = @inNombre

		END;

		ELSE
		BEGIN

			SELECT -1 AS Id
			SET @outResultCode = 50006

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

	SELECT @outResultCode AS CodigoResultado

	SET NOCOUNT OFF;
END;
GO