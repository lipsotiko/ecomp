-- Add exclusions to query.

select distinct e.review_period_id, e.review_month, e.review_year, e.email_address as ce_email, e.user_id, e.party_id, e.lead_element_id, e.component_id, ce_supervisor_id, supervisor_email_addreess, e.grade, e.fiscal_year
into #tmp_issues
from (
    -- All actual data that was saved
    select r.review_period_id, r.element_id, le.lead_element_id, lc.id as component_id, cg.grade, cg.fiscal_year, count(ex.case_data_id) as exclusions
    from review r
    inner join lead_element le
    on r.element_id = le.id
    inner join lead_element_group_component cg
    on cg.component_id = r.component_id
    inner join lead_component lc
    on cg.component_id = lc.id
    left join review_case_exclusion ex
    on r.review_id = ex.review_id
    where review_section = 'TIMELINESS' and lc.manual_entry = 0
    group by r.review_period_id, r.element_id, le.lead_element_id, lc.id, cg.grade, cg.fiscal_year
) opa
right outer join (
    select review_period_id, review_month, review_year, email_address, user_id, party_id, lead_element_id, component_id, ce_supervisor_id, supervisor_email_addreess, a.grade, a.fiscal_year
    from (
        -- All scenarios we should see data for
        select r.review_period_id, rp.review_month, rp.review_year, u.email_address, u.user_id, u.party_id, dash.ce_supervisor_id, sup.email_address as supervisor_email_addreess, re.grade, re.fiscal_year
        from review r
        inner join review_period rp
        on r.review_period_id = rp.id
        inner join review_evaluation re
        on rp.review_evaluation_id = re.id
        inner join [user] u
        on re.user_id = u.user_id
        inner join ce_supervisor_dashboard_user dash
        on u.user_id = dash.claims_examiner_id
        inner join [user] sup
        on dash.ce_supervisor_id = sup.user_id
        where review_section = 'TIMELINESS' and u.party_id is not null
    ) a
    full outer join (
        -- All Element / Component combinations for 2023
        select distinct le.lead_element_id, le.id as element_id, lc.id as component_id, lc.component, cg.fiscal_year, cg.grade
        from lead_element_group_component cg
        inner join lead_element_group eg
        on cg.group_id = eg.group_id
        inner join lead_component lc
        on cg.component_id = lc.id
        and lc.manual_entry = 0
        inner join lead_element le
        on eg.element_id = le.id
    ) b
    on 1 = 1
    and a.fiscal_year = b.fiscal_year
    and a.grade = b.grade
) e
on opa.lead_element_id = e.lead_element_id
and opa.component_id = e.component_id
and opa.review_period_id = e.review_period_id
and opa.grade = e.grade
and opa.fiscal_year = e.fiscal_year
where opa.review_period_id is null and e.review_period_id is not null
order by ce_email

select * from #tmp_issues

DECLARE @REVIEW_PERIOD_ID INT
DECLARE @ELEMENT_ID VARCHAR(255)

DECLARE db_cursor CURSOR FOR 
select distinct review_period_id, lead_element_id from #tmp_issues

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @REVIEW_PERIOD_ID, @ELEMENT_ID

WHILE @@FETCH_STATUS = 0  
BEGIN  
    DECLARE @exclusion_cnt INT
    select @exclusion_cnt = count(*)
    from review_case_exclusion ex
    inner join review r
    on ex.review_id = r.review_id
    inner join lead_element le
    on r.element_id = le.id
    where review_period_id  = 684
    and le.lead_element_id = 'PAY'


    print @exclusion_cnt
    if (@exclusion_cnt > 0) 
    begin
        print 'Review Period ' + @REVIEW_PERIOD_ID
        print 'Review Period ' + @ELEMENT_ID
    end

      FETCH NEXT FROM db_cursor INTO @REVIEW_PERIOD_ID, @ELEMENT_ID
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 
