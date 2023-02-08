DECLARE @DESTINATION_USER_ID INT = 5036
select * from [user] where user_id = @DESTINATION_USER_ID

delete re from review_evaluation re where re.user_id = @DESTINATION_USER_ID

insert into review_evaluation (user_id, fiscal_year, grade, [start_date], close_date, review_type, ce_agreement_date, ce_supervisor_agreement_date, reviewing_officer_agreement_date, completed_by, created_by, pip_start_date, final_rating, last_review_period_date)
select @DESTINATION_USER_ID, fiscal_year, grade, [start_date], close_date, review_type, ce_agreement_date, ce_supervisor_agreement_date, reviewing_officer_agreement_date, completed_by, created_by, pip_start_date, final_rating, last_review_period_date
from stg_review_evaluation

select * from review_evaluation where user_id = @DESTINATION_USER_ID

declare @NEW_EVALUATION_ID INT
select top 1 @NEW_EVALUATION_ID = id from review_evaluation where user_id = @DESTINATION_USER_ID

delete from review_period where review_evaluation_id not in (select id from review_evaluation)

insert into review_period(review_month, review_year, review_evaluation_id, closed)
select review_month, review_year, @NEW_EVALUATION_ID, closed
from stg_review_period

select * from review_period where review_evaluation_id = @NEW_EVALUATION_ID

delete from review_summary where review_period_id not in (select id from review_period)

insert into review_summary (rating, quality_status, timeliness_status, updated_by, updated_date, review_period_id)
select rs.rating, rs.quality_status, rs.timeliness_status, rs.updated_by, rs.updated_date, nrp.id as review_period_id
from stg_review_summary rs
inner join stg_review_period rp
on rs.review_period_id  = rp.id
inner join (
    select * from review_period where review_evaluation_id = @NEW_EVALUATION_ID
) nrp
on rp.review_year = nrp.review_year
and rp.review_month = nrp.review_month

select * from review_summary where review_period_id in (select id from review_period where review_evaluation_id = @NEW_EVALUATION_ID)

delete from review where review_period_id not in (select id from review_period)

insert into review (review_section, component_id, review_status, total, ok, details, action_type, action_date, review_date, case_number, case_id, element_id, review_period_id)
select r.review_section, r.component_id, r.review_status, r.total, r.ok, r.details, r.action_type, r.action_date, r.review_date, r.case_number, r.case_id, r.element_id, nrp.id as review_period_id
from stg_review r
inner join stg_review_period rp
on r.review_period_id  = rp.id
inner join (
    select * from review_period where review_evaluation_id = @NEW_EVALUATION_ID
) nrp
on rp.review_year = nrp.review_year
and rp.review_month = nrp.review_month

select * from review where review_period_id in (select id from review_period where review_evaluation_id = @NEW_EVALUATION_ID)

delete from timeliness_case where review_id not in (select review_id from review)

insert into timeliness_case(id, component, age, case_data, case_id, review_id)
select tc.id, tc.component, tc.age, tc.case_data, tc.case_id, nr.review_id
from stg_timeliness_case tc
inner join stg_review r
on tc.review_id = r.review_id
inner join stg_review_period rp
on r.review_period_id = rp.id
inner join (
    select r.review_id, r.component_id, rp.review_month, rp.review_year
    from review r
    inner join review_period rp
    on r.review_period_id = rp.id
    where rp.review_evaluation_id = @NEW_EVALUATION_ID
) nr
on nr.component_id = r.component_id
and nr.review_month = rp.review_month
and nr.review_year = rp.review_year

select * 
from timeliness_case where review_id in (
    select review_id from review where review_period_id in (select id from review_period where review_evaluation_id = @NEW_EVALUATION_ID)
)

delete from review_case_exclusion where review_id not in (select review_id from review)

insert into review_case_exclusion(review_id, excluded_by_id, reason, case_number, case_data_id)
select nr.review_id, ex.excluded_by_id, ex.reason, ex.case_number, ex.case_data_id
from stg_review_case_exclusion ex
inner join stg_review r
on ex.review_id = r.review_id
inner join stg_review_period rp
on r.review_period_id = rp.id
inner join (
    select r.review_id, r.component_id, rp.review_month, rp.review_year
    from review r
    inner join review_period rp
    on r.review_period_id = rp.id
    where rp.review_evaluation_id = @NEW_EVALUATION_ID
) nr
on nr.component_id = r.component_id
and nr.review_month = rp.review_month
and nr.review_year = rp.review_year

select * 
from review_case_exclusion where review_id in (
    select review_id from review where review_period_id in (select id from review_period where review_evaluation_id = @NEW_EVALUATION_ID)
)
