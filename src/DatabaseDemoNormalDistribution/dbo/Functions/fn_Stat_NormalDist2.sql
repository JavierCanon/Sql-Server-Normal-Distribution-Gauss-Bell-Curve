
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

