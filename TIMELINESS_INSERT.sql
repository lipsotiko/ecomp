-- REFERENCE
select re.id, r.review_id, lc.component, lc.[description], lc.metric, le.lead_element_id
into #tmp_components
from review_evaluation re
inner join review_period rp
on re.id = rp.review_evaluation_id
inner join review r
on rp.id = r.review_period_id
inner join lead_component lc
on r.component_id = lc.id
inner join lead_element le
on le.id = r.element_id
where user_id = 3829
and rp.review_month = 8
and rp.review_year = 2023
and r.review_section = 'TIMELINESS'
order by le.lead_element_id, lc.id

-- INSERT
declare @new_timeliness_record_counts table (
    review_id int,
    timely_count int,
    record_count int
)

insert into @new_timeliness_record_counts (review_id, timely_count, record_count)
values((select review_id from #tmp_components where component = 'Traumatic/Reopened Interim'), 4, 5)
,((select review_id from #tmp_components where component = 'Traumatic'), 4, 5)
,((select review_id from #tmp_components where component = 'Reopened'), 4, 5)
,((select review_id from #tmp_components where component ='Basic ODs Interim'), 0, 0)
,((select review_id from #tmp_components where component ='Basic'), 0, 0)
,((select review_id from #tmp_components where component ='Extend'), 0, 0)
,((select review_id from #tmp_components where component ='Remand'), 0, 0)
,((select review_id from #tmp_components where component ='Recurrences'), 0, 0)
,((select review_id from #tmp_components where component ='Mail for UD/UE'), 9, 10)
,((select review_id from #tmp_components where component ='Referral to Staff Nurse'), 0, 0)
,((select review_id from #tmp_components where component ='Post-Nurse Closed TTD Action'), 1,1)
,((select review_id from #tmp_components where component ='Post-SECOP Action'), 1,1)
,((select review_id from #tmp_components where component ='No SECOP Action'), 1,1)
,((select review_id from #tmp_components where component ='SECOP/MSN'), 1,1)
,((select review_id from #tmp_components where component ='Tier 1'), 0, 0)
,((select review_id from #tmp_components where component ='Tier 2'), 2, 2)
,((select review_id from #tmp_components where component ='Tier 3'), 0, 0)
,((select review_id from #tmp_components where component ='Wage loss Payments sent for cert (no dev)'), 3, 3)
,((select review_id from #tmp_components where component ='Payments (all)'), 0, 0)
,((select review_id from #tmp_components where component ='SA sent for cert'), 0, 0)
,((select review_id from #tmp_components where component ='Unreviewed Mail'), 0, 0)
,((select review_id from #tmp_components where component ='Telephonic inquiries'), 1, 3)
,((select review_id from #tmp_components where component ='Written inquiries'), 2, 5)
,((select review_id from #tmp_components where component ='Telephonic inquiries 2'), 0, 0)
,((select review_id from #tmp_components where component ='Escalation inquiries'), 8, 10)

delete tc 
from timeliness_case tc
where review_id in (
    select review_id 
    from @new_timeliness_record_counts
)

SET NOCOUNT ON;  
DECLARE @REVIEW_ID INT, @TIMELY_COUNT INT, @RECORD_COUNT INT;  
DECLARE tmp_cursor CURSOR FOR SELECT review_id, timely_count, record_count FROM @new_timeliness_record_counts
OPEN tmp_cursor
FETCH NEXT FROM tmp_cursor
INTO @REVIEW_ID, @TIMELY_COUNT, @RECORD_COUNT
WHILE @@FETCH_STATUS = 0  
BEGIN
    declare @COMPONENT varchar(255)
    declare @METRIC varchar(255)
    declare @i INT = 0;

    select TOP 1 @COMPONENT = component, @METRIC = metric from lead_component where id = (select component_id from review where review_id = @REVIEW_ID)

    WHILE (@I < @TIMELY_COUNT)
    BEGIN
        INSERT INTO timeliness_case (component, age, review_id)
        VALUES(@COMPONENT, @METRIC, @REVIEW_ID)
        SET @i = @i + 1;
    END

    WHILE (@I < @RECORD_COUNT)
    BEGIN
        INSERT INTO timeliness_case (component, age, review_id)
        VALUES(@COMPONENT, @METRIC + 1, @REVIEW_ID)
        SET @i = @i + 1;
    END

    FETCH NEXT FROM tmp_cursor INTO @REVIEW_ID, @TIMELY_COUNT, @RECORD_COUNT
 
END   
CLOSE tmp_cursor;  
DEALLOCATE tmp_cursor;

drop table #tmp_components
