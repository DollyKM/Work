CREATE or ALTER PROCEDURE usp_userCount
@StartDate date='',
@EndDate date='',
@Mode nvarchar(20)='',
@filter nvarchar(50)=''
as 
begin
	create table #TempVisit (ResultDate date)
	DECLARE @sqlQuery nvarchar(MAX)
	--SET @sqlQuery='select ResultDate, count(distinct UserId) from Tbl_UserVisits'

	

	begin
	;WITH cte
	AS 
	(
		SELECT @StartDate AS n --anchor member
		UNION ALL
		SELECT DATEADD(day,1,n) --recursive member
		FROM cte
		WHERE n < @EndDate --terminator
	)
	
	INSERT INTO #TempVisit 
	SELECT * FROM cte
	
OPTION (MAXRECURSION 700);


		if @Mode='Daily'

		SET @sqlQuery='SELECT COUNT(DISTINCT Tbl_UserVisits.UserId) AS UserCount, 
		Temp.ResultDate  as days FROM Tbl_UserVisits 
		RIGHT JOIN #TempVisit AS Temp 
		ON Tbl_UserVisits.VisitDate=Temp.ResultDate 
		GROUP BY YEAR(Temp.ResultDate),MONTH(Temp.ResultDate),Temp.ResultDate' 

		else if @Mode='Monthly'
		SET @sqlQuery='SELECT COUNT(DISTINCT Tbl_UserVisits.UserId) AS UserCount,  
		 DATENAME(month,Temp.ResultDate) as months  FROM Tbl_UserVisits 
		RIGHT JOIN #TempVisit AS Temp 
		ON Tbl_UserVisits.VisitDate=Temp.ResultDate 
		GROUP BY YEAR(Temp.ResultDate),MONTH(Temp.ResultDate), DATENAME(month,Temp.ResultDate)' 

		else if @Mode='Yearly'
		SET @sqlQuery='SELECT COUNT(DISTINCT Tbl_UserVisits.UserId) AS UserCount,  
		 YEAR(Temp.ResultDate) as years  FROM Tbl_UserVisits 
		RIGHT JOIN #TempVisit AS Temp 
		ON Tbl_UserVisits.VisitDate=Temp.ResultDate 
		GROUP BY YEAR(Temp.ResultDate) ' 
		else if @Mode='weekly'
		SET @sqlQuery='SELECT COUNT(DISTINCT Tbl_UserVisits.UserId) AS UserCount,  
		 DATEPART(week,Temp.ResultDate) as weeks FROM Tbl_UserVisits 
		RIGHT JOIN #TempVisit AS Temp 
		ON Tbl_UserVisits.VisitDate=Temp.ResultDate 
		GROUP BY DATEPART(week,Temp.ResultDate) '

--SET @sqlQuery='SELECT COUNT(DISTINCT Tbl_UserVisits.UserId) AS UserCount, ' + 
--@filter +' FROM Tbl_UserVisits 
--RIGHT JOIN #TempVisit AS Temp 
--ON Tbl_UserVisits.VisitDate=Temp.ResultDate 
--GROUP BY ' + @filter 


end
	print(@sqlQuery)
	execute(@sqlQuery)
end







Execute usp_userCount;
Execute usp_userCount @StartDate='2019-01-01',@EndDate='2020-01-01',@Mode='Daily'
Execute usp_userCount @StartDate='2019-01-01',@EndDate='2020-02-05',@Mode='Monthly'

Execute usp_userCount @StartDate='2019-01-01',@EndDate='2020-01-01',@Mode='Yearly'
Execute usp_userCount @StartDate='2020-01-01',@EndDate='2020-01-10',@Mode='Weekly'