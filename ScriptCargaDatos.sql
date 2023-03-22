ALTER PROCEDURE [dbo].[CargarXML]
    -- Parametro de entrada
    @inRutaXML NVARCHAR(500)
AS

DECLARE @Datos xml/*Declaramos la variable Datos como un tipo XML*/

 -- Para cargar el archivo con una variable, CHAR(39) son comillas simples
DECLARE @Comando NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK '  + CHAR(39) + @inRutaXML + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' -- comando que va a ejecutar el sql dinamico

DECLARE @Parametros NVARCHAR(500)
SET @Parametros = N'@Datos xml OUTPUT' --parametros del sql dinamico

EXECUTE sp_executesql @Comando, @Parametros, @Datos OUTPUT -- ejecutamos el comando que hicimos dinamicamente
    
DECLARE @hdoc int /*Creamos hdoc que va a ser un identificador*/
    
EXEC sp_xml_preparedocument @hdoc OUTPUT, @Datos/*Toma el identificador y a la variable con el documento y las asocia*/


INSERT INTO [dbo].[Usuario]
           (
		   [UserName]
		   , [Password]
		   )/*Inserta en la tabla TipoDocIdent*/
SELECT 
	U.Nombre
	, U.Password
FROM OPENXML (@hdoc, '/root/Usuarios/Usuario' , 1)/*Lee los contenidos del XML y para eso necesita un identificador,el 
PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
	Nombre VARCHAR(16)
	, Password VARCHAR(16)
    ) AS U


INSERT INTO [dbo].[ClaseArticulo]
				(
				[Nombre]
				)/*Inserta en la tabla Puestos*/
SELECT 
	C.Nombre
FROM OPENXML (@hdoc, '/root/ClasesdeArticulos/ClasesdeArticulo' , 1)/*Lee los contenidos del XML y 
para eso necesita un identificador,el PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Nombre VARCHAR(64)
    ) AS C


INSERT INTO [dbo].[Articulo]
           (
		   [IdClaseArticulo]
		   , [Nombre]
		   , [Precio]
		   )/*Inserta en la tabla Departamentos*/
SELECT 
	CA.Id
	, A.Nombre
	, A.Precio
FROM OPENXML (@hdoc, '/root/Articulos/Articulo' , 1)/*Lee los contenidos del XML y para eso necesita un 
identificador,el PATH del nodo y el 1 que sirve para retornar solo atributos*/
WITH(/*Dentro del WITH se pone el nombre y el tipo de los atributos a retornar*/
    Nombre VARCHAR(128)
	, ClasesdeArticulo VARCHAR(64)
	, precio MONEY
    ) AS A
	INNER JOIN [dbo].[ClaseArticulo] CA ON A.ClasesdeArticulo = CA.Nombre;
    
EXEC sp_xml_removedocument @hdoc/*Remueve el documento XML de la memoria*/