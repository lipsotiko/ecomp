declare @ID INT = 100000000
begin try drop table #tmp end try begin catch end catch
select a.Component, b.actionType, @ID + RANK() over (order by a.sort, b.actionType) as case_id
into #tmp
from (
    select 'Reopened' as Component, 1 as sort UNION ALL
    select 'Basic' as Component, 2 as sort UNION ALL
    select 'Extend' as Component, 3 as sort UNION ALL
    select 'Remand' as Component, 4 as sort UNION ALL
    select 'Recurrences' as Component, 5 as sort UNION ALL
    select 'Traumatic' as Component, 6 as sort UNION ALL
    select 'Reopened' as Component, 7 as sort UNION ALL
    select 'Traumatic' as Component, 8 as sort UNION ALL
    select 'Basic' as Component, 9 as sort
) a
inner join (
    select 'ACCEPTED' as actionType UNION ALL
    select 'DENIED' as actionType UNION ALL
    select 'SUSPENDED' as actionType
) b
on 1 = 1
order by a.sort

delete from ifecs_case where case_id between 100000000 and 110000000
insert into ifecs_case (case_id, case_number, last_name, first_name, agency_cd, building_cd)
select case_id, 'Z' + SUBSTRING(CAST(case_id as char(9)), 2, 8), 'John ' + t.Component, 'Doe ' + t.actionType, 2570, '00'
from #tmp t

select * from ifecs_case where case_id between 100000000 and 110000000
