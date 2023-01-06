


declare @case_id int = 12651

-- delete em
-- from escalation_inquiry_section_metadata em
-- inner join escalation_inquiry_section es
-- on em.section_id = es.id
-- inner join escalation_inquiry ei
-- on es.inquiry_id = ei.id
-- where case_id = @case_id

-- delete es
-- from escalation_inquiry_section es
-- inner join escalation_inquiry ei
-- on es.inquiry_id = ei.id
-- where case_id = @case_id

-- delete e
-- from escalation e
-- inner join escalation_inquiry ei
-- on e.escalation_inquiry_id = ei.id
-- where ei.case_id = @case_id

-- delete ei
-- from escalation_inquiry ei
-- where ei.case_id = @case_id


select em.*
from escalation_inquiry_section_metadata em
inner join escalation_inquiry_section es
on em.id = es.inquiry_id
inner join escalation_inquiry ei
on es.inquiry_id = ei.id
where case_id = @case_id

select es.*
from escalation_inquiry_section es
inner join escalation_inquiry ei
on es.inquiry_id = ei.id
where case_id = @case_id

select e.*
from escalation e
inner join escalation_inquiry ei
on e.escalation_inquiry_id = ei.id
where ei.case_id = @case_id

select ei.*
from escalation_inquiry ei
where ei.case_id = @case_id
