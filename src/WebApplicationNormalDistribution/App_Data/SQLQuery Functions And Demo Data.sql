/****** Object:  UserDefinedFunction [dbo].[fn_Stat_NormalDist]    Script Date: 4/4/2019 5:31:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_Stat_NormalDist] (@x FLOAT)
RETURNS FLOAT
AS
/****************************************************************************************
NAME: udf_NORMSDIST
WRITTEN BY: rajdaksha
http://www.sqlteam.com/forums/topic.asp?TOPIC_ID=135026
DATE: 2009/10/29 
PURPOSE: Mimics Excel's Function NORMSDIST

Usage: SELECT dbo.udf_NORMSDIST(.5)


REVISION HISTORY

Date Developer Details
2010/08/11 LC Posted Function


*****************************************************************************************/
BEGIN
	DECLARE @result FLOAT
	DECLARE @L FLOAT
	DECLARE @K FLOAT
	DECLARE @dCND FLOAT
	DECLARE @pi FLOAT
	DECLARE @a1 FLOAT
	DECLARE @a2 FLOAT
	DECLARE @a3 FLOAT
	DECLARE @a4 FLOAT
	DECLARE @a5 FLOAT

	--SELECT @L = 0.0
	SELECT @K = 0.0

	SELECT @dCND = 0.0

	SELECT @a1 = 0.31938153

	SELECT @a2 = - 0.356563782

	SELECT @a3 = 1.781477937

	SELECT @a4 = - 1.821255978

	SELECT @a5 = 1.330274429

	SELECT @pi = 3.1415926535897932384626433832795

	SELECT @L = Abs(@x)

	IF @L >= 30
	BEGIN
		IF sign(@x) = 1
			SELECT @result = 1
		ELSE
			SELECT @result = 0
	END
	ELSE
	BEGIN
		-- perform calculation
		SELECT @K = 1.0 / (1.0 + 0.2316419 * @L)

		SELECT @dCND = 1.0 - 1.0 / Sqrt(2 * @pi) * Exp(- @L * @L / 2.0) * (@a1 * @K + @a2 * @K * @K + @a3 * POWER(@K, 3.0) + @a4 * POWER(@K, 4.0) + @a5 * POWER(@K, 5.0))

		IF (@x < 0)
			SELECT @result = 1.0 - @dCND
		ELSE
			SELECT @result = @dCND
	END

	RETURN @result
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Stat_NormalDist2]    Script Date: 4/4/2019 5:31:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		https://groups.google.com/forum/#!topic/microsoft.public.sqlserver.programming/4-553n_7wss
-- Create date: <Create Date, ,>
-- Description:	
/*
@X
is the value at which to evaluate the function. @X is an expression of type float or of a type that can be implicitly converted to float. 
@Mean
is the arithmetic mean of the distribution. @Mean is an expression of type float or of a type that can be implicitly converted to float. 
@Standard_dev
is the standard deviation of the distribution. @Standard_dev is an expression of type float or of a type that can be implicitly converted to float. 
@Cumulative
is a logical value that determines if the probability density function (False, 0) or the cumulative distribution function (True, 1) is being calculated.
Return Types
float
Remarks
·         If @Standard_dev ≤ 0, NORMDIST returns an error
·         If @Mean = 0 and @Standard_dev = 1 and @Cumulative = 'False', NORMDIST = NORMSDIST(@X)
*/
-- =============================================
CREATE FUNCTION [dbo].[fn_Stat_NormalDist2] (
	-- Add the parameters for the function here
	 @x FLOAT
	,@xBar FLOAT
	,@Sigma FLOAT
	)
RETURNS FLOAT
AS
BEGIN
	DECLARE @ProbDensity AS FLOAT

	IF(@Sigma > 0) 
		--SELECT @ProbDensity = ROUND((1 / sqrt(2 * pi() * square(@Sigma))) * exp(- (square((@x - @xBar)) / (2 * square(@sigma)))), 5);
		SELECT @ProbDensity = (1 / sqrt(2 * pi() * square(@Sigma))) * exp(- (square((@x - @xBar)) / (2 * square(@sigma))));
	ELSE
		SET @ProbDensity = 0;
	
	RETURN @ProbDensity;
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_Stat_Table_NormalDist]    Script Date: 4/4/2019 5:31:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  Table [dbo].[RPANO_DistNormalAcumVentas_Anual_2017]    Script Date: 4/4/2019 5:31:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPANO_DistNormalAcumVentas_Anual_2017](
	[Fecha] [date] NOT NULL,
	[ValorBruto] [float] NULL,
	[DistNormalAc] [float] NULL,
	[Rank] [float] NULL,
 CONSTRAINT [PK_RPANO_DistNormalAcumVentas_Anual_2017] PRIMARY KEY CLUSTERED 
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RPANO_DistNormalVentas_Anual_2017]    Script Date: 4/4/2019 5:31:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPANO_DistNormalVentas_Anual_2017](
	[Rn] [int] NOT NULL,
	[YAxis] [float] NULL,
	[NormalDist] [float] NULL,
	[Rank] [float] NULL,
	[SUMValorBruto] [float] NULL,
 CONSTRAINT [PK_RPANO_DistNormalVentas_Anual_2017] PRIMARY KEY CLUSTERED 
(
	[Rn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10]    Script Date: 4/4/2019 5:31:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10](
	[Fecha] [date] NOT NULL,
	[ValorBruto] [float] NULL,
	[DistNormalAc] [float] NULL,
	[Rank] [float] NULL,
 CONSTRAINT [PK_RPMES_DistNormalAcumVentas_Mensual_2017_10] PRIMARY KEY CLUSTERED 
(
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RPMES_DistNormalVentas_Mensual_2017_10]    Script Date: 4/4/2019 5:31:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RPMES_DistNormalVentas_Mensual_2017_10](
	[Rn] [int] NOT NULL,
	[YAxis] [float] NULL,
	[NormalDist] [float] NULL,
	[Rank] [float] NULL,
	[SUMValorBruto] [float] NULL,
 CONSTRAINT [PK_RPMES_DistNormalVentas_Mensual_2017_10] PRIMARY KEY CLUSTERED 
(
	[Rn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-01' AS Date), 8.9183000000000661, 0.22580645161290322, 0.2)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-02' AS Date), 19.807199999999956, 0.61290322580645162, 0.6)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-03' AS Date), 21.003699999999846, 0.64516129032258063, 0.6333333333333333)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-04' AS Date), 31.20439999999941, 0.80645161290322576, 0.8)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-05' AS Date), 27.907399999999576, 0.74193548387096775, 0.73333333333333328)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-06' AS Date), 32.231699999999464, 0.83870967741935487, 0.83333333333333337)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-07' AS Date), 39.850900000000173, 1, 1)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-08' AS Date), 17.890899999999942, 0.54838709677419351, 0.53333333333333333)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-09' AS Date), 36.945799999999934, 0.967741935483871, 0.96666666666666667)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-10' AS Date), 36.565599999999961, 0.93548387096774188, 0.93333333333333335)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-11' AS Date), 35.94299999999955, 0.90322580645161288, 0.9)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-12' AS Date), 35.8421999999993, 0.87096774193548387, 0.8666666666666667)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-13' AS Date), 26.292599999999616, 0.70967741935483875, 0.7)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-14' AS Date), 19.4968, 0.58064516129032262, 0.56666666666666665)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-15' AS Date), 9.2127000000000656, 0.29032258064516131, 0.26666666666666666)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-16' AS Date), 10.611800000000127, 0.5161290322580645, 0.5)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-17' AS Date), 28.383399999999583, 0.77419354838709675, 0.76666666666666672)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-18' AS Date), 25.294899999999625, 0.67741935483870963, 0.66666666666666663)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-19' AS Date), 9.8464000000001466, 0.45161290322580644, 0.43333333333333335)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-20' AS Date), 9.9415000000000688, 0.4838709677419355, 0.46666666666666667)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-21' AS Date), 9.7265000000000814, 0.38709677419354838, 0.36666666666666664)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-22' AS Date), 4.6271999999999922, 0.16129032258064516, 0.13333333333333333)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-23' AS Date), 9.206200000000063, 0.25806451612903225, 0.23333333333333334)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-24' AS Date), 9.5104000000000717, 0.35483870967741937, 0.33333333333333331)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-25' AS Date), 9.4234000000001, 0.32258064516129031, 0.3)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-26' AS Date), 6.3368999999999955, 0.19354838709677419, 0.16666666666666666)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-27' AS Date), 1.2120999999999915, 0.064516129032258063, 0.033333333333333333)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-28' AS Date), 9.8121000000000773, 0.41935483870967744, 0.4)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-29' AS Date), 4.1880999999999906, 0.0967741935483871, 0.066666666666666666)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-30' AS Date), 4.210299999999993, 0.12903225806451613, 0.1)
GO
INSERT [dbo].[RPANO_DistNormalAcumVentas_Anual_2017] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-31' AS Date), 0.42889999999999961, 0.032258064516129031, 0)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (1, -20.802511267953758, 0.00023348576833130759, 0.2, 8.9183000000000661)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (2, -17.660918614363965, 0.00050452170121480634, 0.6, 19.807199999999956)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (3, -14.519325960774172, 0.0010212065624643758, 0.6333333333333333, 21.003699999999846)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (4, -11.377733307184379, 0.0019362509805817118, 0.8, 31.20439999999941)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (5, -8.2361406535945854, 0.0034389353594313533, 0.73333333333333328, 27.907399999999576)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (6, -5.0945480000047922, 0.0057213785401944578, 0.83333333333333337, 32.231699999999464)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (7, -1.9529553464149991, 0.0089164434792793831, 1, 39.850900000000173)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (8, 1.188637307174794, 0.013016581663823886, 0.53333333333333333, 17.890899999999942)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (9, 4.3302299607645871, 0.017799858178243429, 0.96666666666666667, 36.945799999999934)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (10, 7.47182261435438, 0.022800818886509096, 0.93333333333333335, 36.565599999999961)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (11, 10.613415267944173, 0.027358901502988385, 0.9, 35.94299999999955)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (12, 13.755007921533967, 0.030751136785150068, 0.8666666666666667, 35.8421999999993)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (13, 16.89660057512376, 0.032377104162857287, 0.7, 26.292599999999616)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (14, 20.038193228713553, 0.031932221861414728, 0.56666666666666665, 19.4968)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (15, 23.179785882303346, 0.029500853561218485, 0.26666666666666666, 9.2127000000000656)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (16, 26.321378535893139, 0.025530206861238237, 0.5, 10.611800000000127)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (17, 29.462971189482932, 0.020696094267850004, 0.76666666666666672, 28.383399999999583)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (18, 32.604563843072725, 0.015715809729065753, 0.66666666666666663, 25.294899999999625)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (19, 35.746156496662522, 0.01117890945848587, 0.43333333333333335, 9.8464000000001466)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (20, 38.887749150252318, 0.007448630368922609, 0.46666666666666667, 9.9415000000000688)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (21, 42.029341803842115, 0.00464908745895482, 0.36666666666666664, 9.7265000000000814)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (22, 45.170934457431912, 0.0027181493608195435, 0.13333333333333333, 4.6271999999999922)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (23, 48.312527111021708, 0.001488652141598264, 0.23333333333333334, 9.206200000000063)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (24, 51.454119764611505, 0.00076370818291928561, 0.33333333333333331, 9.5104000000000717)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (25, 54.5957124182013, 0.00036700837058685606, 0.3, 9.4234000000001)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (26, 57.7373050717911, 0.00016521094044850358, 0.16666666666666666, 6.3368999999999955)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (27, 60.878897725380895, 6.96652091635414E-05, 0.033333333333333333, 1.2120999999999915)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (28, 64.020490378970692, 2.7517399914931555E-05, 0.4, 9.8121000000000773)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (29, 67.162083032560489, 1.0181532547443231E-05, 0.066666666666666666, 4.1880999999999906)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (30, 70.303675686150285, 3.5288501800839748E-06, 0.1, 4.210299999999993)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (31, 73.445268339740082, 1.1456912471785609E-06, 0, 0.42889999999999961)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (32, 76.586860993329879, 3.4843059144217087E-07, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (33, 79.728453646919675, 9.926114240398403E-08, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (34, 82.870046300509472, 2.64884513829718E-08, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (35, 86.011638954099269, 6.6213748664942318E-09, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (36, 89.153231607689065, 1.5504368847284444E-09, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (37, 92.294824261278862, 3.4007469364466443E-10, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (38, 95.436416914868659, 6.9872912706447128E-11, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (39, 98.578009568458455, 1.3447999607456825E-11, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (40, 101.71960222204825, 2.4244924506947623E-12, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (41, 104.86119487563805, 4.0944756505963517E-13, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (42, 108.00278752922785, 6.47724101936188E-14, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (43, 111.14438018281764, 9.5983400156409145E-15, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (44, 114.28597283640744, 1.3323444330584968E-15, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (45, 117.42756548999724, 1.7324120704745583E-16, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (46, 120.56915814358703, 2.1100862063607622E-17, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (47, 123.71075079717683, 2.4074845250265879E-18, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (48, 126.85234345076663, 2.5730078909614949E-19, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (49, 129.99393610435641, 2.575923968776465E-20, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (50, 133.13552875794619, 2.4156792589606718E-21, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (51, 136.27712141153597, 2.1220705042325226E-22, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (52, 139.41871406512576, 1.7462027006586432E-23, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (53, 142.56030671871554, 1.3459961274479661E-24, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (54, 145.70189937230532, 9.7186797927567486E-26, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (55, 148.8434920258951, 6.57332408105634E-27, NULL, NULL)
GO
INSERT [dbo].[RPANO_DistNormalVentas_Anual_2017] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (56, 151.98508467948489, 4.16463671961806E-28, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-01' AS Date), 8.9183000000000661, 0.22580645161290322, 0.2)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-02' AS Date), 19.807199999999956, 0.61290322580645162, 0.6)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-03' AS Date), 21.003699999999846, 0.64516129032258063, 0.6333333333333333)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-04' AS Date), 31.20439999999941, 0.80645161290322576, 0.8)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-05' AS Date), 27.907399999999576, 0.74193548387096775, 0.73333333333333328)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-06' AS Date), 32.231699999999464, 0.83870967741935487, 0.83333333333333337)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-07' AS Date), 39.850900000000173, 1, 1)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-08' AS Date), 17.890899999999942, 0.54838709677419351, 0.53333333333333333)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-09' AS Date), 36.945799999999934, 0.967741935483871, 0.96666666666666667)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-10' AS Date), 36.565599999999961, 0.93548387096774188, 0.93333333333333335)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-11' AS Date), 35.94299999999955, 0.90322580645161288, 0.9)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-12' AS Date), 35.8421999999993, 0.87096774193548387, 0.8666666666666667)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-13' AS Date), 26.292599999999616, 0.70967741935483875, 0.7)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-14' AS Date), 19.4968, 0.58064516129032262, 0.56666666666666665)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-15' AS Date), 9.2127000000000656, 0.29032258064516131, 0.26666666666666666)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-16' AS Date), 10.611800000000127, 0.5161290322580645, 0.5)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-17' AS Date), 28.383399999999583, 0.77419354838709675, 0.76666666666666672)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-18' AS Date), 25.294899999999625, 0.67741935483870963, 0.66666666666666663)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-19' AS Date), 9.8464000000001466, 0.45161290322580644, 0.43333333333333335)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-20' AS Date), 9.9415000000000688, 0.4838709677419355, 0.46666666666666667)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-21' AS Date), 9.7265000000000814, 0.38709677419354838, 0.36666666666666664)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-22' AS Date), 4.6271999999999922, 0.16129032258064516, 0.13333333333333333)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-23' AS Date), 9.206200000000063, 0.25806451612903225, 0.23333333333333334)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-24' AS Date), 9.5104000000000717, 0.35483870967741937, 0.33333333333333331)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-25' AS Date), 9.4234000000001, 0.32258064516129031, 0.3)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-26' AS Date), 6.3368999999999955, 0.19354838709677419, 0.16666666666666666)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-27' AS Date), 1.2120999999999915, 0.064516129032258063, 0.033333333333333333)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-28' AS Date), 9.8121000000000773, 0.41935483870967744, 0.4)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-29' AS Date), 4.1880999999999906, 0.0967741935483871, 0.066666666666666666)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-30' AS Date), 4.210299999999993, 0.12903225806451613, 0.1)
GO
INSERT [dbo].[RPMES_DistNormalAcumVentas_Mensual_2017_10] ([Fecha], [ValorBruto], [DistNormalAc], [Rank]) VALUES (CAST(N'2017-10-31' AS Date), 0.42889999999999961, 0.032258064516129031, 0)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (1, -20.802511267953758, 0.00023348576833130759, 0.2, 8.9183000000000661)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (2, -17.660918614363965, 0.00050452170121480634, 0.6, 19.807199999999956)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (3, -14.519325960774172, 0.0010212065624643758, 0.6333333333333333, 21.003699999999846)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (4, -11.377733307184379, 0.0019362509805817118, 0.8, 31.20439999999941)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (5, -8.2361406535945854, 0.0034389353594313533, 0.73333333333333328, 27.907399999999576)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (6, -5.0945480000047922, 0.0057213785401944578, 0.83333333333333337, 32.231699999999464)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (7, -1.9529553464149991, 0.0089164434792793831, 1, 39.850900000000173)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (8, 1.188637307174794, 0.013016581663823886, 0.53333333333333333, 17.890899999999942)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (9, 4.3302299607645871, 0.017799858178243429, 0.96666666666666667, 36.945799999999934)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (10, 7.47182261435438, 0.022800818886509096, 0.93333333333333335, 36.565599999999961)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (11, 10.613415267944173, 0.027358901502988385, 0.9, 35.94299999999955)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (12, 13.755007921533967, 0.030751136785150068, 0.8666666666666667, 35.8421999999993)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (13, 16.89660057512376, 0.032377104162857287, 0.7, 26.292599999999616)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (14, 20.038193228713553, 0.031932221861414728, 0.56666666666666665, 19.4968)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (15, 23.179785882303346, 0.029500853561218485, 0.26666666666666666, 9.2127000000000656)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (16, 26.321378535893139, 0.025530206861238237, 0.5, 10.611800000000127)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (17, 29.462971189482932, 0.020696094267850004, 0.76666666666666672, 28.383399999999583)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (18, 32.604563843072725, 0.015715809729065753, 0.66666666666666663, 25.294899999999625)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (19, 35.746156496662522, 0.01117890945848587, 0.43333333333333335, 9.8464000000001466)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (20, 38.887749150252318, 0.007448630368922609, 0.46666666666666667, 9.9415000000000688)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (21, 42.029341803842115, 0.00464908745895482, 0.36666666666666664, 9.7265000000000814)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (22, 45.170934457431912, 0.0027181493608195435, 0.13333333333333333, 4.6271999999999922)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (23, 48.312527111021708, 0.001488652141598264, 0.23333333333333334, 9.206200000000063)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (24, 51.454119764611505, 0.00076370818291928561, 0.33333333333333331, 9.5104000000000717)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (25, 54.5957124182013, 0.00036700837058685606, 0.3, 9.4234000000001)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (26, 57.7373050717911, 0.00016521094044850358, 0.16666666666666666, 6.3368999999999955)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (27, 60.878897725380895, 6.96652091635414E-05, 0.033333333333333333, 1.2120999999999915)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (28, 64.020490378970692, 2.7517399914931555E-05, 0.4, 9.8121000000000773)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (29, 67.162083032560489, 1.0181532547443231E-05, 0.066666666666666666, 4.1880999999999906)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (30, 70.303675686150285, 3.5288501800839748E-06, 0.1, 4.210299999999993)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (31, 73.445268339740082, 1.1456912471785609E-06, 0, 0.42889999999999961)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (32, 76.586860993329879, 3.4843059144217087E-07, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (33, 79.728453646919675, 9.926114240398403E-08, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (34, 82.870046300509472, 2.64884513829718E-08, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (35, 86.011638954099269, 6.6213748664942318E-09, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (36, 89.153231607689065, 1.5504368847284444E-09, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (37, 92.294824261278862, 3.4007469364466443E-10, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (38, 95.436416914868659, 6.9872912706447128E-11, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (39, 98.578009568458455, 1.3447999607456825E-11, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (40, 101.71960222204825, 2.4244924506947623E-12, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (41, 104.86119487563805, 4.0944756505963517E-13, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (42, 108.00278752922785, 6.47724101936188E-14, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (43, 111.14438018281764, 9.5983400156409145E-15, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (44, 114.28597283640744, 1.3323444330584968E-15, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (45, 117.42756548999724, 1.7324120704745583E-16, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (46, 120.56915814358703, 2.1100862063607622E-17, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (47, 123.71075079717683, 2.4074845250265879E-18, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (48, 126.85234345076663, 2.5730078909614949E-19, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (49, 129.99393610435641, 2.575923968776465E-20, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (50, 133.13552875794619, 2.4156792589606718E-21, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (51, 136.27712141153597, 2.1220705042325226E-22, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (52, 139.41871406512576, 1.7462027006586432E-23, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (53, 142.56030671871554, 1.3459961274479661E-24, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (54, 145.70189937230532, 9.7186797927567486E-26, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (55, 148.8434920258951, 6.57332408105634E-27, NULL, NULL)
GO
INSERT [dbo].[RPMES_DistNormalVentas_Mensual_2017_10] ([Rn], [YAxis], [NormalDist], [Rank], [SUMValorBruto]) VALUES (56, 151.98508467948489, 4.16463671961806E-28, NULL, NULL)
GO
/****** Object:  StoredProcedure [dbo].[Generate_DistNormalAcumVentas]    Script Date: 4/4/2019 5:31:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
/****** Object:  StoredProcedure [dbo].[Generate_DistNormalVentas]    Script Date: 4/4/2019 5:31:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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

GO
