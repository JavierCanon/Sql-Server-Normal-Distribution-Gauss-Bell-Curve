
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
