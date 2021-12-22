SELECT 
    [Doctor]
    ,[Professor]
    ,[Singer]
    ,[Actor]
FROM (
    SELECT 
    row_number() over (Partition by Occupation order by Name) as RN 
    ,*
    from Occupations
    ) as temp
PIVOT (
    max(Name)
    For [Occupation]
    In ([Doctor],[Professor],[Singer],[Actor])
      ) as Pivot_table
