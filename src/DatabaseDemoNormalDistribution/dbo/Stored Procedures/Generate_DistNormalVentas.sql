-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Generate_DistNormalVentas] 
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
	SET @tablename = 'RPMES_DistNormalVentas_Mensual_' + CONVERT(CHAR(4), YEAR(@fechaIni)) + '_' + RIGHT(REPLICATE('0', 2) + CONVERT(VARCHAR(2), MONTH(@fechaIni)), 2); ;
END
ELSE
BEGIN
	IF(MONTH(@fechaIni) = 1 AND DAY(@fechaIni) = 1)
	BEGIN
		SELECT
		 @fechaIni = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni) -1) + '-01-01' )
		,@fechaFin = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni)) + '-12-31' )
		;
		SET @tablename = 'RPANO_DistNormalVentas_Anual_' + CONVERT(CHAR(4), YEAR(@fechaIni));
	END
	ELSE
	-- si es primero de cada mes, genera acumulado hasta el mes anterior
	BEGIN
		SELECT
		 @fechaIni = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni) ) + '-01-01' )
		,@fechaFin = CONVERT(DATE, CONVERT(CHAR(4), YEAR(@fechaIni) ) + '-12-31' )
		;
		SET @tablename = 'RPANO_DistNormalVentas_Anual_' + CONVERT(CHAR(4), YEAR(@fechaIni));
	END
	;

END;

-- if exist, drop table?
IF Exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = @tablename)
	EXEC('DROP TABLE ' + @tablename)
;


SET @tsql ='
DECLARE 
	     @SUM MONEY
		,@Min MONEY
		,@Max MONEY
		,@Average FLOAT
		,@StandardDev FLOAT
 ;

	SELECT 	     
	      Fecha
		 ,SUM(ValorBrutoM) SUMValorBruto
	INTO #groups
	FROM [dbo].[Apuestas]
	WHERE 
	  [Fecha] BETWEEN ''' + CONVERT(CHAR(10), @fechaIni, 126) + ''' AND ''' + CONVERT(CHAR(10), @fechaFin, 126) + '''
--		AND [Empresa] = COALESCE(@Empresa, [Empresa])
--		AND [Departamento] = COALESCE(@Departamento, [Departamento])
--		AND [Sorteo] = COALESCE(@Sorteo, [Sorteo])
--		AND Signo = COALESCE(@Signo, Signo)
   GROUP BY 
	Fecha
 ;

SELECT
   		 @SUM = ISNULL(SUM(SUMValorBruto), 0)
		,@Min = ISNULL(MIN(SUMValorBruto), 0) 
		,@Max = ISNULL(MAX(SUMValorBruto), 0) 
		,@Average = ISNULL(AVG(SUMValorBruto), 0) 
		,@StandardDev = ISNULL(STDEV(SUMValorBruto), 0)  
FROM #groups
 ;

DECLARE @prevVal FLOAT = @Average - (PI() * @StandardDev);

	SELECT 
	     ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) Rn
	    ,[Fecha]
	    ,SUM(ValorBrutoM) SUMValorBruto
		,min(ValorBrutoM) AS [Min]
		,max(ValorBrutoM) AS [Max]
		,avg(ValorBrutoM) AS [Average]
		,CASE ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
			WHEN 1 THEN @prevVal
			ELSE PI()
		END Y
		INTO #dates
	FROM [dbo].[Apuestas]
	WHERE 
	  [Fecha] BETWEEN ''' + CONVERT(CHAR(10), @fechaIni, 126) + ''' AND ''' + CONVERT(CHAR(10), @fechaFin, 126) + '''
--		AND [Empresa] = COALESCE(@Empresa, [Empresa])
--		AND [Departamento] = COALESCE(@Departamento, [Departamento])
--		AND [Sorteo] = COALESCE(@Sorteo, [Sorteo])
--		AND Signo = COALESCE(@Signo, Signo)
	GROUP BY Fecha
 ;

SELECT 
   #dates.*
 ,PERCENT_RANK() OVER (ORDER BY SUMValorBruto) AS Rank 
 --,SUM(Y) OVER(ORDER BY SUMValorBruto) YAxis
 --,[dbo].[fn_Stat_NormalDist2](SUM(Y) OVER(ORDER BY SUMValorBruto),@Average,@StandardDev) DistNormal
 INTO #finaldata
FROM #dates 
 ;

SELECT 
     N.* 
    ,#finaldata.Rank
	,#finaldata.SUMValorBruto
	INTO [' + @tablename + ']
FROM [dbo].[fn_Stat_Table_NormalDist]( @Average,  @StandardDev) N
LEFT JOIN #finaldata ON N.Rn = #finaldata.Rn 
 ;
'
;

PRINT @tsql; 
EXEC(@tsql); 

-- CREATE PK INDEX FOR QUERIES
SET @tsql ='
ALTER TABLE [' + @tablename + '] ALTER COLUMN Rn INTEGER NOT NULL;'
;
PRINT @tsql; 
EXEC(@tsql); 

SET @tsql ='
ALTER TABLE [' + @tablename + '] ADD  CONSTRAINT [PK_' + @tablename + '] PRIMARY KEY CLUSTERED 
(
	[Rn] ASC
);
'
;
PRINT @tsql; 
EXEC(@tsql); 



END

