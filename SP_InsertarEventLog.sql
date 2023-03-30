SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE InsertEventLog
	@inLogDescription VARCHAR(2000)
    , @inPostIdUser INT
    , @inPostIP VARCHAR(64)
    , @inPostTime DATETIME
	, @outResultCode INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;

    BEGIN TRY
		
		SET @outResultCode = 0

		INSERT INTO [dbo].[EventLog]
           ([LogDescription]
           ,[PostIdUser]
           ,[PostIP]
           ,[PostTime])
     VALUES
           (@inLogDescription
			, @inPostIdUser
			, @inPostIP
			, @inPostTime)
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

END;
GO