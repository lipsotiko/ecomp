select le.lead_element_id, sg.[description], eg.weighting, eg.sort_order,lc.component, egc.sort_order, RANK() OVER (ORDER BY sg.[description], eg.sort_order ASC) as distinct_group_id
from lead_standards_group sg
inner join lead_element_group eg
on sg.id = eg.standards_group_id
inner join lead_element_group_component egc
on eg.id = egc.group_id
inner join lead_component lc
on egc.component_id = lc.id
inner join lead_element le
on sg.element_id = le.id
where sg.review_standards_id = 37
order by sg.[description], eg.sort_order, egc.sort_order

select le.lead_element_id, lq.question_text, lq.question_number, lq.is_stop_question
from lead_question lq
inner join lead_element le
on lq.element_id = le.id
where le.review_standards_id = 37
order by le.lead_element_id, lq.question_number


select grade, rating, low, high
from review_grade_rating 
where review_standards_id = 37