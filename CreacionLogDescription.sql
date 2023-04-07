CREATE TABLE dbo.LogDescription
(
		Id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY
		, TipoAccion VARCHAR(64)
		, ValorDescripcion VARCHAR(128)
);