-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Generate_DistNormalAcumVentas] 
	-- Add the parameters for the stored procedure here
		 @fechaIni DATE
		,@Mensual BIT = 1 -- 1 para mes 0 para anual

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SET DATEFORMAT YMD;

DECLARE @fechaFin DATE;

-- determinar nombre tabla
DECLARE @tablename varchar(100), @tsql varchar(MAX);

IF(@Mensual = 1) 
BEGIN
	SELECT
	 @fechaIni = dbo.fnGetFirstDayCurrentMonth(@fechaIni)
	,@fechaFin = dbo.fnGetLastDayCurrentMonth(@fechaIni)
	;
	SET @tablename = 'RPMES_DistNormalAcumVentas_Mensual_' + CONVERT(CHAR(4), YEAR(@fechaIni)) + '_' + RIGHT(REPLICATE('0', 2) + CONVERT(VARCHAR(2), MONTH(@fechaIni)), 2); ;
END
ELSE
BEGIN
	IF(MONTH(@fechaIni) = 1 AND DAY(@fechaIni) = 1)
	BEGIN
		SELECT
		 @fechaIni = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni) -1) + '-01-01' )
		,@fechaFin = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni)) + '-12-31' )
		;
		SET @tablename = 'RPANO_DistNormalAcumVentas_Anual_' + CONVERT(CHAR(4), YEAR(@fechaIni));
	END
	ELSE
	-- si es primero de cada mes, genera acumulado hasta el mes anterior
	BEGIN
		SELECT
		 @fechaIni = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni)) + '-01-01' )
		,@fechaFin = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni)) + '-12-31' )
		;
		SET @tablename = 'RPANO_DistNormalAcumVentas_Anual_' + CONVERT(CHAR(4), YEAR(@fechaIni));
	END
	;

END;

-- if exist, drop table?
IF Exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @tablename)
	EXEC('DROP TABLE ' + @tablename)
;

SET @tsql ='
SELECT 
       [Fecha]
 	  ,SUM([ValorBrutoM]) [ValorBruto]
  INTO #CE
  FROM [dbo].[Apuestas]
WHERE
	  [Fecha] BETWEEN ''' + CONVERT(CHAR(10), @fechaIni, 126) + ''' AND ''' + CONVERT(CHAR(10), @fechaFin, 126) + '''
--    AND	[Empresa] = COALESCE(@Empresa,[Empresa])
--    AND	[Departamento]  = COALESCE(@Departamento,[Departamento])
--    AND	[Sorteo]  = COALESCE(@Sorteo,[Sorteo])
--    AND	Signo  = COALESCE(@Signo,Signo)
 GROUP BY
		  Fecha
		  ;

SELECT 
       Fecha
      ,[ValorBruto]
	  ,CUME_DIST () OVER (ORDER BY [ValorBruto]) AS DistNormalAc
	  ,PERCENT_RANK() OVER (ORDER BY [ValorBruto]) AS Rank  
	INTO [' + @tablename + ']
FROM  #CE
ORDER BY Fecha
 ;
';

PRINT @tsql; 
EXEC(@tsql); 

-- CREATE PK INDEX FOR QUERIES
SET @tsql ='
ALTER TABLE [' + @tablename + '] ADD  CONSTRAINT [PK_' + @tablename + '] PRIMARY KEY CLUSTERED 
(
	[Fecha] ASC

)'
;

PRINT @tsql; 
EXEC(@tsql); 






END

