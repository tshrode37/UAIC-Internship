SELECT ref_num.policy_symbol, ref_num.policy_num, dates.*,
	DATEDIFF(day, dates.[Start Date], dates.[End Date]) as [Days Owned], ref_num.[Min_EventDate], ref_num.[Max_EventDate]
FROM (
	SELECT [VIN], 
	[Owner Seq Num], 
	[Accident Event],
	CAST([Owner Start Date] AS date) as [Start Date],
	CASE WHEN [Owner End Date] = '' THEN '2021-12-31' 
		ELSE CAST([Owner End Date] AS date) 
	END as [End Date]
	FROM [Production400].[dbo].[RMT_OwnerHistory]) dates --2,283,120

LEFT JOIN (
	SELECT VIN, 
	CASE WHEN LEN(ReferenceNumber) = 12 THEN Substring(ReferenceNumber, 1, 3) 
		ELSE Substring(ReferenceNumber, 0, 0) 
	END AS policy_symbol,
	CASE WHEN LEN(ReferenceNumber) = 12 THEN Substring(ReferenceNumber, 4, LEN(ReferenceNumber))
		ELSE Substring(ReferenceNumber, 1, LEN(ReferenceNumber)) 
		END AS policy_num, 
	MIN(EventDate) as Min_EventDate, 
	MAX(EventDate) as Max_EventDate
	FROM #full_history
	GROUP BY VIN, ReferenceNumber) ref_num

	ON dates.VIN = ref_num.VIN 

	and ref_num.Min_EventDate <= dates.[End Date] 
	and ref_num.Min_EventDate >= dates.[Start Date]

ORDER BY dates.VIN;
