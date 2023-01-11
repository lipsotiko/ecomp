declare @ELEMENT_ID VARCHAR(255) = 'COM'
declare @REVIEW_PERIOD_ID INT = 610
declare @REVIEW_EVALUATION_ID VARCHAR(255) = 403

delete from timeliness_case 
where review_id in (
    select r.review_id
    from review r
    inner join lead_element le
    on r.element_id = le.id
    inner join lead_component lc
    on r.component_id = lc.id
    inner join review_period rp
    on r.review_period_id = rp.id
    inner join review_evaluation re
    on rp.review_evaluation_id = re.id
    where lc.manual_entry = 0
    and le.lead_element_id = @ELEMENT_ID
    and r.review_period_id = @REVIEW_PERIOD_ID
    and re.id = @REVIEW_EVALUATION_ID
)

delete from review_case_exclusion 
where review_id in (
    select r.review_id
    from review r
    inner join lead_element le
    on r.element_id = le.id
    inner join lead_component lc
    on r.component_id = lc.id
    inner join review_period rp
    on r.review_period_id = rp.id
    inner join review_evaluation re
    on rp.review_evaluation_id = re.id
    where lc.manual_entry = 0
    and le.lead_element_id = @ELEMENT_ID
    and r.review_period_id = @REVIEW_PERIOD_ID
    and re.id = @REVIEW_EVALUATION_ID
)

delete r
from review r
inner join lead_element le
on r.element_id = le.id
inner join lead_component lc
on r.component_id = lc.id
inner join review_period rp
on r.review_period_id = rp.id
inner join review_evaluation re
on rp.review_evaluation_id = re.id
where lc.manual_entry = 0
and le.lead_element_id = @ELEMENT_ID
and r.review_period_id = @REVIEW_PERIOD_ID
and re.id = @REVIEW_EVALUATION_ID

update review_summary set timeliness_status = 'STARTED' where review_period_id = @REVIEW_PERIOD_ID
