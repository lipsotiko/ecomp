declare @case_id int = (select case_id from ifecs_case where case_number = 'XE0123844')
declare @created_by int = (select user_id from [user] where user_name = 'ecomp+cesuper@intevity.com' and application_id = 0 )
declare @created_at datetime = DATEADD(day, -10, CURRENT_TIMESTAMP)

delete eism
from escalation_inquiry_section_metadata eism
inner join escalation_inquiry_section eis
on eism.section_id = eis.id
inner join escalation_inquiry ei
on eis.inquiry_id = ei.id
where case_id = @case_id

delete eis
from escalation_inquiry_section eis
inner join escalation_inquiry ei
on eis.inquiry_id = ei.id
where case_id = @case_id

delete e
from escalation e
inner join escalation_inquiry ei
on e.escalation_inquiry_id = ei.id
where case_id = @case_id

delete from ei
from escalation_inquiry ei
where case_id = @case_id

insert into escalation_inquiry([type], case_id, phone_number, extension)
VALUES('DISABILITY_PAYMENT_FOR_WORK_LOSS', @case_id, '+15555555555', 345),
    ('PROBLEMS_WITH_MEDICAL_BILL_PAYMENTS', @case_id, '+15555555555', 345),
    ('AUTHORIZATION_FOR_MEDICAL_PROCEDURE', @case_id, '+15555555555', 345),
    ('AUTHORIZATION_FOR_MEDICATION', @case_id, '+15555555555', 345),
    ('HEALTH_BENEFITS_OR_INSURANCE_ISSUE', @case_id, '+15555555555', 345),
    ('OVERPAYMENT', @case_id, '+15555555555', 345)

insert into escalation(created_at, created_by, escalation_inquiry_id)
values(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'DISABILITY_PAYMENT_FOR_WORK_LOSS')),
(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'PROBLEMS_WITH_MEDICAL_BILL_PAYMENTS')),
(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICAL_PROCEDURE')),
(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICATION')),
(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'HEALTH_BENEFITS_OR_INSURANCE_ISSUE')),
(@created_at, @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'OVERPAYMENT'))

declare @tmp_section_ids table ([id] int);

insert into escalation_inquiry_section(inquiry_id, id)
OUTPUT inserted.id
into @tmp_section_ids
values((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'DISABILITY_PAYMENT_FOR_WORK_LOSS'), NEXT VALUE FOR escalation_inquiry_section_sequence),
((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'PROBLEMS_WITH_MEDICAL_BILL_PAYMENTS'), NEXT VALUE FOR escalation_inquiry_section_sequence),
((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICAL_PROCEDURE'), NEXT VALUE FOR escalation_inquiry_section_sequence),
((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICATION'), NEXT VALUE FOR escalation_inquiry_section_sequence),
((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'HEALTH_BENEFITS_OR_INSURANCE_ISSUE'), NEXT VALUE FOR escalation_inquiry_section_sequence),
((select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'OVERPAYMENT'), NEXT VALUE FOR escalation_inquiry_section_sequence)

declare @tmp_metadata table ([prompt_text] VARCHAR(255), [response_text] VARCHAR(255));
insert into @tmp_metadata (prompt_text, response_text)
values('A. Sample Date: Out of work', '10/5/2022'),
    ('B. More Stuff', 'Neat'),
    ('C. More Things', 'Sailboats')

insert into escalation_inquiry_section_metadata(prompt_text, response_text, section_id)
select a.prompt_text, a.response_text, b.id
from @tmp_metadata a
full outer join @tmp_section_ids b
on 1=1



insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'DISABILITY_PAYMENT_FOR_WORK_LOSS')

insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'PROBLEMS_WITH_MEDICAL_BILL_PAYMENTS')

insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICAL_PROCEDURE')

insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'AUTHORIZATION_FOR_MEDICATION')

insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'HEALTH_BENEFITS_OR_INSURANCE_ISSUE')

insert into escalation(created_at, created_by, escalation_inquiry_id)
select DATEADD(day, -5, CURRENT_TIMESTAMP), @created_by, (select top 1 id from escalation_inquiry where case_id = @case_id and [type] = 'OVERPAYMENT')
