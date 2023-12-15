delete from review_evaluation where user_id = 3341
delete from review_period where review_evaluation_id not in (select id from review_evaluation)
delete from review where review_period_id not in (select id from review_period)
delete from review_summary where review_period_id not in (select id from review_period)
delete from review_case_exclusion where review_id not in (select review_id from review)

begin try drop table #tmp_counts end try begin catch end catch
create table #tmp_counts (
    element varchar(10),
    component varchar(250),
    timely int, 
    total int
)

insert into #tmp_counts values
('ADJ', 'Traumatic/Reopened Interim', 0, 0),
('ADJ', 'Traumatic', 4, 4),
('ADJ', 'Reopened', 2, 2),
('ADJ', 'Basic ODs Interim', 0, 0),
('ADJ', 'Basic', 0, 0),
('ADJ', 'Extend', 2, 3),
('ADJ', 'Remand', 1, 1),
('ADJ', 'Recurrences', 0, 0),
('ADJ', 'Mail for UD/UE', 0, 0),

('QCM', 'Referral to Staff Nurse', 0, 0),
('QCM', 'Post-Nurse Closed TTD Action', 2, 2),
('QCM', 'Post-SECOP Action', 0, 0),
('QCM', 'No SECOP Action', 0, 0),
('QCM', 'SECOP/MSN', 0, 1),

('PRM', 'Tier 1', 0, 0),
('PRM', 'Tier 2', 0, 0),
('PRM', 'Tier 3', 0, 0),

('PAY', 'Wage loss Payments sent for cert (no dev)', 13, 17),
('PAY', 'Payments (all)', 2, 3),
('PAY', 'SA sent for cert', 0, 0),

('COM', 'Unreviewed Mail', 316, 316),
('COM', 'Telephonic inquiries', 67, 74),
('COM', 'Written inquiries', 5, 5),


declare @USER_ID INT = 2464;
declare @ELEMENT VARCHAR(10);
declare @COMPONENT VARCHAR(250);
declare @TIMELY INT;
declare @TOTAL INT;

DECLARE vend_cursor CURSOR  
    FOR SELECT * FROM #tmp_counts
OPEN vend_cursor  
FETCH NEXT FROM vend_cursor INTO @ELEMENT, @COMPONENT, @TIMELY, @TOTAL;  

WHILE @@FETCH_STATUS = 0  
BEGIN
    declare @REVIEW_ID INT
    declare @METRIC INT

    select @REVIEW_ID = r.review_id, @METRIC = lc.metric, @COMPONENT = lc.component
    from review_evaluation re
    inner join review_period rp
    on rp.review_evaluation_id = re.id
    inner join review r
    on r.review_period_id = rp.id
    left join timeliness_case tc
    on r.review_id = tc.review_id
    inner join lead_element le
    on r.element_id = le.id
    inner join lead_component lc
    on r.component_id = lc.id
    where re.user_id = 2464
    and r.review_section = 'TIMELINESS'
    and lc.manual_entry = 0
    and lc.component = @COMPONENT
    and le.lead_element_id = @ELEMENT

    delete from timeliness_case where review_id = @REVIEW_ID

    declare @I INT = 0

    while (@I < @TOTAL)
    BEGIN
        IF (@I >= @TIMELY)
        BEGIN
            INSERT INTO timeliness_case (component, age, review_id, id)
            VALUES(@COMPONENT, @METRIC + 1, @REVIEW_ID, @I)
        END
        ELSE
        BEGIN
            INSERT INTO timeliness_case (component, age, review_id, id)
            VALUES(@COMPONENT, @METRIC - 1, @REVIEW_ID, @I)
        END

        set @I = @I + 1
    END

    FETCH NEXT FROM vend_cursor INTO @ELEMENT, @COMPONENT, @TIMELY, @TOTAL;  

END
CLOSE vend_cursor
DEALLOCATE vend_cursor
