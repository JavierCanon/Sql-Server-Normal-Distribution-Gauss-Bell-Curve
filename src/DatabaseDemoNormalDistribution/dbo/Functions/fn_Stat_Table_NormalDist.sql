-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Return necesary Rows for can make Chart
-- =============================================
CREATE FUNCTION [dbo].[fn_Stat_Table_NormalDist] 
(
	-- Add the parameters for the function here
	 @AvgMean FLOAT = 0
	,@StdDev FLOAT = 0
)
RETURNS 
@TableResult TABLE 
(
	-- Add the column definitions for the TABLE variable here
	 Rn INT 
	,YAxis FLOAT
	,NormalDist FLOAT
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	
	-- how many rows we need?: @AvgMean + (PI * @StdDev)

DECLARE @Table TABLE 
(
	-- Add the column definitions for the TABLE variable here
	 Rn INT 
	,YAxis FLOAT
	,NormalDist FLOAT
);

	
	DECLARE @totrows INT;
	SELECT @totrows = ABS(@AvgMean + (PI() * @StdDev));

	INSERT INTO @Table(Rn, YAxis, NormalDist)
	SELECT TOP (@totrows) 
	     n = ROW_NUMBER() OVER (ORDER BY number) --Rn
		,CASE ROW_NUMBER() OVER(ORDER BY number) 
			WHEN 1 THEN @AvgMean - (PI() * @StdDev)
			ELSE PI() -- YAxis
		END 
		,0  --NormalDist
	FROM [master]..spt_values  		
	ORDER BY n
  ;

	INSERT INTO @TableResult(Rn, YAxis, NormalDist)
   SELECT 
	  Rn
     ,SUM(YAxis) OVER(ORDER BY Rn) SUMY
     ,[dbo].[fn_Stat_NormalDist2](SUM(YAxis) OVER(ORDER BY Rn),@AvgMean,@StdDev) DistNormal
	 FROM @Table
   ;


	-- first row 
	/*
	INSERT INTO @Table(Rn, YAxis, NormalDist)	
	SELECT 1, @AvgMean - (PI() * @StdDev)
	,[dbo].[fn_Stat_NormalDist2](@AvgMean - (PI() * @StdDev), @AvgMean, @StdDev)
	;*/

	/*
	INSERT INTO @Table(Rn, YAxis, NormalDist)
	SELECT TOP (@totrows) 
	      n = ROW_NUMBER() OVER (ORDER BY number) --Rn
		,CASE ROW_NUMBER() OVER(ORDER BY number) 
			WHEN 1 THEN @AvgMean - (PI() * @StdDev)
			ELSE PI() -- YAxis
		END 
		,0  --NormalDist
	FROM [master]..spt_values  		
	ORDER BY n
  ;

  WITH ce AS(
   SELECT 
	  Rn
     ,SUM(YAxis) OVER(ORDER BY Rn) SUMY
     ,[dbo].[fn_Stat_NormalDist2](SUM(YAxis) OVER(ORDER BY Rn),@AvgMean,@StdDev) DistNormal
	 FROM @Table
)
  UPDATE @Table SET
    YAxis = ce.SUMY
   ,NormalDist = ce.DistNormal
   FROM ce INNER JOIN @Table T ON T.Rn = ce.Rn
  ;
  */


/*

	DELETE FROM @Table WHERE Rn > 1;
	
	INSERT INTO @Table(Rn, YAxis, NormalDist)
	SELECT
		 Rn
		,SUMY
		,DistNormal
	FROM ce


;WITH n(n) AS
(
    SELECT 1
    UNION ALL
    SELECT n+1 FROM n WHERE n < 1000
)
SELECT n FROM n ORDER BY n
OPTION (MAXRECURSION 1000);

SELECT TOP (1000) n = ROW_NUMBER() OVER (ORDER BY number) 
  FROM [master]..spt_values ORDER BY n;

*/


	RETURN 
END
