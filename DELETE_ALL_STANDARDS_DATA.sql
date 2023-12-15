DECLARE @LOW_ID INT = 106
DECLARE @HIGH_ID INT = 106

delete q
from review r
inner join review_quality_responses q
on q.parent_review_id = r.review_id
where review_period_id in (
select id from review_period where review_evaluation_id in (
 select id from review_evaluation where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID
)
)

delete from review_summary where review_period_id in (
select id from review_period where review_evaluation_id in (
 select id from review_evaluation where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID
)
)

delete from review where review_period_id in (
    select id from review_period where review_evaluation_id in (
    select id from review_evaluation where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID
    )
)


delete from review_period where review_evaluation_id in (
    select id from review_evaluation where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID
)

delete from review_evaluation where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete from lead_element_group_component where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete from lead_element_group where standards_group_id not in (select id from lead_standards_group)

delete from lead_standards_group where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete from review_grade_rating where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete from lead_component where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete from lead_question where element_id in (
    select id from lead_element where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID
)

delete from lead_element where review_standards_id BETWEEN @LOW_ID AND @HIGH_ID

delete 
from review_standards 
where id BETWEEN @LOW_ID AND @HIGH_ID
