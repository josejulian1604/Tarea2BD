USE [Tarea1_2023]
GO
/****** Object:  StoredProcedure [dbo].[Logout]    Script Date: 4/11/2023 10:16:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Logout]
	@inPostIdUser INT				-- El usuario que lo realiza
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


		INSERT INTO @LogDescription
				(TipoAccion
				, ValorDescripcion)
		VALUES ('Logout'
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

	SELECT @outResultCode AS resultCode;

    SET NOCOUNT OFF;
END
