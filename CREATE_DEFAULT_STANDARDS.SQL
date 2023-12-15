declare @2024 VARCHAR(255) = 'Default standards 2024'
declare @STANDARDS_ID_TBL table (ID int)
declare @STANDARDS_ID INT

insert into review_standards (fiscal_year, active, [effective_date], [description], required_reviews, created_at, editable)
output inserted.id into @STANDARDS_ID_TBL
values (2024, 1, CURRENT_TIMESTAMP, @2024, 2, CURRENT_TIMESTAMP, 0)

select top 1 @STANDARDS_ID = ID from @STANDARDS_ID_TBL

insert into lead_element (lead_element_id, [description], action_type_label, action_date_label, [weight], display_acronym, [enabled], review_standards_id)
values
('ADJ','Adjudication',' Decision Type','Decision Date', 20, 'ADJ', 1, @STANDARDS_ID),
('COM','Customer Service','Communication Type','Date of Action','20', 'CX', 1, @STANDARDS_ID),
('PAY','Payments','Payment Type','Certification Date',	25, 'PAY', 1, @STANDARDS_ID),
('PRM','Periodic Roll Management','Per Type','PER Action Date',	20,'PRM', 1, @STANDARDS_ID),
('QCM','Quality Case Management','Action Type','Action Date', 15, 'QCM', 1, @STANDARDS_ID)

insert into lead_question(element_id, question_text, question_number, is_stop_question)
select le.id, q.question_text, q.question_number, q.is_stop_question
from (
    select 'ADJ' as lead_element_id,'If developed, was development necessary?' as question_text,1 as question_number,0 as is_stop_question UNION ALL
    select 'ADJ','Was any challenge and/or controversion acknowledged?',2,0 UNION ALL
    select 'ADJ','Was the challenge and/or controversion addressed correctly?',3,0 UNION ALL
    select 'ADJ','Was the development clear and correct?',4,0 UNION ALL
    select 'ADJ','Are traumatic injury, administratively reopened and basic occupational disease claims acted on within 5 work days of receipt/reopening, and is the case accepted within 5 work days of receipt of a document that allows the case to be accepted?',5,0 UNION ALL
    select 'ADJ','If the CE issued an interim notice to the claimant advising the case could not be accepted, was the action accurate and did the CE explain why case could not yet be accepted?',6,0 UNION ALL
    select 'ADJ','Are extended occupational disease claims and remands acted upon within 14 calendar days of receipt, follow-up actions taken every 45 days until a decision is made (if the claim is in posture for an action), and if the claim is in posture for a decision is it made within 45 days of the last follow-up action regardless of the age of the claim?',7,0 UNION ALL
    select 'ADJ','If case has 3rd party potential were all appropriate actions taken?',8,0 UNION ALL
    select 'ADJ','Was decision issued? And if the decision was issued, the following actions are also evaluated.',9,1 UNION ALL
    select 'ADJ','Was decision to accept or deny correct?',10,0 UNION ALL
    select 'ADJ','Were the ICD-10 codes correct?',11,0 UNION ALL
    select 'ADJ','Was COP denied if needed?',12,0 UNION ALL
    select 'ADJ','Was the claim denial based on the correct element?',13,0 UNION ALL
    select 'ADJ','Was the explanation for denial plain and clear?',14,0 UNION ALL
    select 'ADJ','Was the ADJ and PAY status correct?',15,0 UNION ALL
    select 'COM','Was there a response issued or 110 in the file?',1,0 UNION ALL
    select 'COM','Was the response to the right person (written)?',2,0 UNION ALL
    select 'COM','Was the response accurate and all necessary actions completed (written or CA-110)?',3,0 UNION ALL
    select 'COM','Did the response use plain language (written)?',4,0 UNION ALL
    select 'COM','Did the response address all issues (written or CA-110)?',5,0 UNION ALL
    select 'COM','Were other correct parties copied (written)?',6,0 UNION ALL
    select 'COM','Was appropriate follow up action taken if promised (written, CA-110 or medical authorization)?',7,0 UNION ALL
    select 'COM','Was the response courteous and professional (written or CA-110)?',8,0 UNION ALL
    select 'COM','Was medical authorization decision appropriate?',9,0 UNION ALL
    select 'COM','Was medical authorization initial action taken if needed?',10,0 UNION ALL
    select 'COM','Was iFECS updated if needed (written, CA-110 or medical authorization)?',11,0 UNION ALL
    select 'COM','Was acceptance letter issued if needed?',12,0 UNION ALL
    select 'PAY','Was claim developed if needed?',1,0 UNION ALL
    select 'PAY','Was development action appropriate?',2,0 UNION ALL
    select 'PAY','Was development action taken within 14 calendar days?',3,0 UNION ALL
    select 'PAY','Was follow up action to resolve the claim taken every 45 days until the claim is complete?',4,0 UNION ALL
    select 'PAY','Was period supported by medical?',5,0 UNION ALL
    select 'PAY','Was there a complete pay rate memo in file that matches the payment type?',6,0 UNION ALL
    select 'PAY','Was HB transfer initiated within 10 days of certification on PR payment?',7,0 UNION ALL
    select 'PAY','Was payrate accurate in the payment?',8,0 UNION ALL
    select 'PAY','Was payrate effective date accurate in the payment?',9,0 UNION ALL
    select 'PAY','Was compensation rate accurate in payment?',10,0 UNION ALL
    select 'PAY','Were deductions accurate in payment?',11,0 UNION ALL
    select 'PAY','Were work days/calendar days/number of hours/WEC info accurate in payment? And if the payment was accurate, the following actions are also evaluated.',12,1 UNION ALL
    select 'PAY','Was the schedule award payment for the correct percent/number of days?',13,0 UNION ALL
    select 'PAY','Was CA-1049 sent timely (10 days of payment certification)? Was it accurate?',14,0 UNION ALL
    select 'PAY','Was CA-181 sent timely (5 days of payment certification)?',15,0 UNION ALL
    select 'PAY','Was the CA-181 accurate?',16,0 UNION ALL
    select 'PRM','Was CA-1032 or CA-12 received? If not, was the claimant /beneficiary suspended /compensation terminated? And if the form was received, the following actions are also evaluated.',1,1 UNION ALL
    select 'PRM','Does the CA-1032 support current benefit level with regard to earnings (TTD/WEC), third party and fraud, or was appropriate action taken if needed?',2,0 UNION ALL
    select 'PRM','Does CA-1032 or CA-12 support the compensation rate, or was appropriate action taken?',3,0 UNION ALL
    select 'PRM','Does the CA-1032 support current benefits level with regard to dual benefits, or was appropriate action taken if needed?',4,0 UNION ALL
    select 'PRM','Does the address on the submitted CA-1032 or CA-12 match the address on file, or was appropriate action taken?',5,0 UNION ALL
    select 'PRM','Was correct CA-1032 or CA-12 received date entered in the PER?',6,0 UNION ALL
    select 'PRM','Does medical support causal relationship, or was appropriate action taken?',7,0 UNION ALL
    select 'PRM','Does medical support current level of disability, or was appropriate action taken?',8,0 UNION ALL
    select 'PRM','Was the medical report to support causal relationship and disability correctly linked?',9,0 UNION ALL
    select 'PRM','Was case developed for job offer with agency and/or referred to rehab if WTLs on file?',10,0 UNION ALL
    select 'PRM','If there was a rehab communication, was appropriate action taken?',11,0 UNION ALL
    select 'PRM','If there was a rehab closure, was appropriate action taken?',12,0 UNION ALL
    select 'PRM','If there was a rehab communication, was action taken within 14 days?',13,0 UNION ALL
    select 'PRM','If there was a rehab closure, was action taken within 30 days?',14,0 UNION ALL
    select 'PRM','Did CE use correct code and date for the PER actions taken?',15,0 UNION ALL
    select 'QCM','Is track date accurate for newly created QCM cases?',1,0 UNION ALL
    select 'QCM','In QCM cases, in which the claimant is totally disabled (TTD), did CE take an initial action to refer to nurse, refer to rehab, or schedule a second opinion within 14 days of Disability Management start date?',2,0 UNION ALL
    select 'QCM','Was initial action appropriate?',3,0 UNION ALL
    select 'QCM','Did CE take appropriate action after nurse closure?',4,0 UNION ALL
    select 'QCM','Following the initial substantive action after nurse closure, did the CE take appropriate actions (every 90 days where the claimant was receiving benefits for total disability and every 180 days where the claimant is receiving partial or no wage loss benefits?',5,0 UNION ALL
    select 'QCM','Did CE take appropriate action after SECOP/IME report?',6,0 UNION ALL
    select 'QCM','Was case developed for job offer with agency and/or referred to rehab, if appropriate WTLs on file?',7,0 UNION ALL
    select 'QCM','Was case developed for job offer with agency if WTLs on file?',8,0 UNION ALL
    select 'QCM','If no job offer, was the referral to vocational rehabilitation made within 45 days of the request where appropriate?',9,0 UNION ALL
    select 'QCM','If no job offer was made in a light duty case, is the CNC memo completed within 180 days of the job offer request when appropriate?',10,0 UNION ALL
    select 'QCM','If there was an actual RTW, was compensation adjusted appropriately?',11,0 UNION ALL
    select 'QCM','If there was a closure that required an adjustment to compensation, were all actions taken appropriately?',12,0 UNION ALL
    select 'QCM','If there was a vocational rehabilitation communication, was appropriate action taken?',13,0 UNION ALL
    select 'QCM','If there was a vocational rehabilitation closure, was appropriate action taken?',14,0 UNION ALL
    select 'QCM','If there was a vocational rehabilitation communication, was action taken within 14 days?',15,0 UNION ALL
    select 'QCM','If there was a vocational rehabilitation closure, was action taken within 30 days?',16,0 UNION ALL
    select 'QCM','Were all mandatory QCM actions coded?',17,0 UNION ALL
    select 'QCM','Were correct dates entered for mandatory QCM codes?',18,0
) q
inner join lead_element le
on le.lead_element_id = q.lead_element_id
and le.review_standards_id = @STANDARDS_ID

insert into review_grade_rating (grade, rating, low, high, review_standards_id)
select q.grade, q.rating, q.low, q.high, @STANDARDS_ID
from (
    select 7 as grade,'EFS' as rating, 83.5 as low, 90.5 as high UNION ALL
    select 7,'FS',76.5,83.5 UNION ALL
    select 7,'MS',66.5,76.5 UNION ALL
    select 7,'O',90.5,100.0 UNION ALL
    select 7,'U',0.0,66.5 UNION ALL
    select 9,'EFS',84.5,91.5 UNION ALL
    select 9,'FS',77.5,84.5 UNION ALL
    select 9,'MS',67.5,77.5 UNION ALL
    select 9,'O',91.5,100.0 UNION ALL
    select 9,'U',0.0,67.5 UNION ALL
    select 11,'EFS',85.5,92.5 UNION ALL
    select 11,'FS',78.5,85.5 UNION ALL
    select 11,'MS',68.5,78.5 UNION ALL
    select 11,'O',92.5,100.0 UNION ALL
    select 11,'U',0.0,68.5 UNION ALL
    select 12,'EFS',86.5,93.5 UNION ALL
    select 12,'FS',79.5,86.5 UNION ALL
    select 12,'MS',69.5,79.5 UNION ALL
    select 12,'O',93.5,100.0 UNION ALL
    select 12,'U',0.0,69.5
) q

insert into lead_standards_group ([description], [element_id], [review_standards_id])
select q.[description], le.id, le.review_standards_id
from lead_element le
inner join (
    select 'ADJ Group 1' as [description], 'ADJ' as lead_element_id union
    select 'QCM Group 1', 'QCM' union
    select 'PRM Group 1', 'PRM' union
    select 'COM Group 1', 'COM' union
    select 'PAY Group 1', 'PAY' union
    select 'PAY Group 2', 'PAY'
) q
on 1 = 1
and le.lead_element_id = q.lead_element_id
where le.review_standards_id = @STANDARDS_ID

insert into lead_standards_group_grade (standards_group_id, grade)
select groups.id, q.grade
from lead_standards_group groups
inner join (
    select 7 as grade union
    select 9 union
    select 11 union
    select 12
) q
on 1 = 1
where groups.description not like 'PAY Group%' and groups.review_standards_id = @STANDARDS_ID
union
select groups.id, q.grade
from lead_standards_group groups
inner join (
    select 7 as grade union
    select 9 union
    select 11
) q
on 1 = 1
where groups.description = 'PAY Group 1'
union
select groups.id, 12
from lead_standards_group groups
where groups.description = 'PAY Group 2' and groups.review_standards_id = @STANDARDS_ID

insert into lead_component(component, [description], manual_entry, metric, percent_threshold, review_standards_id)
select 'Escalation inquiries','ECOMP Escalation inquiries/CA-110s are responded to within 2 workdays or less',0,2,NULL, @STANDARDS_ID UNION ALL
select 'Reopened','Reopened SFC Cases in 75 days',0,75,NULL,@STANDARDS_ID UNION ALL
select 'Remand','Remands in 120 days',0,120,NULL,@STANDARDS_ID UNION ALL
select 'Post-SECOP Action','Post-SECOP Action in 30 days',0,30,NULL,@STANDARDS_ID UNION ALL
select 'Basic ODs Interim','Basic ODs Interim',0,45,NULL,@STANDARDS_ID UNION ALL
select 'Recurrences','Recurrences in 90 days',0,90,NULL,@STANDARDS_ID UNION ALL
select 'Basic','Basic ODs in 90 days',0,90,NULL,@STANDARDS_ID UNION ALL
select 'Traumatic/Reopened Interim','Traumatic/Reopened Interim',0,45,NULL,@STANDARDS_ID UNION ALL
select 'Certified or returned','Certified or returned in 2 days',0,2,NULL,@STANDARDS_ID UNION ALL
select 'Traumatic','Traumatics in 75 days',0,75,NULL,@STANDARDS_ID UNION ALL
select 'No SECOP Action','No SECOP Action in 90 days',0,90,NULL,@STANDARDS_ID UNION ALL
select 'Referral to Staff Nurse','Referral to Staff Nurse in 7 days',0,7,NULL,@STANDARDS_ID UNION ALL
select 'Written inquiries','Written Inquiries and Correspondence Tracking acted upon by the program due date',0,30,NULL,@STANDARDS_ID UNION ALL
select 'Medical Auths','Medical authorization requests are responded to within 3 work days',1,NULL,NULL,@STANDARDS_ID UNION ALL
select 'Telephonic inquiries 2','95% of CA110s received from the IVR are responded to within 2 workdays or less',0,2,95,@STANDARDS_ID UNION ALL
select 'SECOP/MSN','SECOP/MSN in 365 days',0,365,NULL,@STANDARDS_ID UNION ALL
select 'Tier 1','Tier 1 - PERs are closed or developed within 60 days',0,60,NULL,@STANDARDS_ID UNION ALL
select 'Mail for UD/UE','Mail for UD/UE',0,5,NULL,@STANDARDS_ID UNION ALL
select 'Tier 2','Tier 2 - PERs are closed or developed within 180 days',0,180,NULL,@STANDARDS_ID UNION ALL
select 'Payments (all)','Payments (all) in 85 days',0,85,NULL,@STANDARDS_ID UNION ALL
select 'Extend','Extended ODs in 180 days',0,180,NULL,@STANDARDS_ID UNION ALL
select 'Post-Nurse Closed TTD Action','Post-Nurse Closed TTD Action in 60 days',0,60,NULL,@STANDARDS_ID UNION ALL
select 'Unreviewed Mail','"Unreviewed" Mail (for cases not UD/UE) is indexed within 5 work days',0,5,NULL,@STANDARDS_ID UNION ALL
select 'Tier 3','Tier 3 - PERs are closed within 300 days',0,300,NULL,@STANDARDS_ID UNION ALL
select 'Wage loss Payments sent for cert (no dev)','Payments (no dev) in 10 days',0,10,NULL,@STANDARDS_ID UNION ALL
select 'Telephonic inquiries','90% of CA110s received from the IVR are responded to within 1 workday or less',0,1,90,@STANDARDS_ID UNION ALL
select 'SA sent for cert','SA sent for cert within 175 days',0,175,NULL,@STANDARDS_ID;

declare @TIMELINESS_GROUPS table (lead_element_id varchar(255), standards_group varchar(255), [weighting] int, eg_sort_order int, component varchar(255), sort_order int)

insert into @TIMELINESS_GROUPS(lead_element_id, standards_group, [weighting], eg_sort_order, component, sort_order)
select *
from (
    -- distinct group ID was not needed, but keeping it for reference.
    select 'ADJ' as lead_element_id,'ADJ Group 1' as standards_group,70 as [weighting],1 as [eg_sort_order],'Traumatic/Reopened Interim' as component,1 as sort_order,1 as distinct_group_id UNION ALL
    select 'ADJ','ADJ Group 1',70,1,'Traumatic',2,1 UNION ALL
    select 'ADJ','ADJ Group 1',70,1,'Reopened',3,1 UNION ALL
    select 'ADJ','ADJ Group 1',25,2,'Basic ODs Interim',1,4 UNION ALL
    select 'ADJ','ADJ Group 1',25,2,'Basic',2,4 UNION ALL
    select 'ADJ','ADJ Group 1',25,2,'Extend',3,4 UNION ALL
    select 'ADJ','ADJ Group 1',25,2,'Remand',4,4 UNION ALL
    select 'ADJ','ADJ Group 1',25,2,'Recurrences',5,4 UNION ALL
    select 'ADJ','ADJ Group 1',5,3,'Mail for UD/UE',1,9 UNION ALL
    select 'COM','COM Group 1',5,1,'Unreviewed Mail',1,10 UNION ALL
    select 'COM','COM Group 1',20,2,'Telephonic inquiries',1,11 UNION ALL
    select 'COM','COM Group 1',10,3,'Telephonic inquiries 2',1,12 UNION ALL
    select 'COM','COM Group 1',25,4,'Escalation inquiries',1,13 UNION ALL
    select 'COM','COM Group 1',20,5,'Written inquiries',1,14 UNION ALL
    select 'COM','COM Group 1',20,6,'Medical Auths',1,15 UNION ALL
    select 'PAY','PAY Group 1',45,1,'Wage loss Payments sent for cert (no dev)',1,16 UNION ALL
    select 'PAY','PAY Group 1',55,2,'Payments (all)',1,17 UNION ALL
    select 'PAY','PAY Group 1',55,2,'SA sent for cert',2,17 UNION ALL
    select 'PAY','PAY Group 2',45,1,'Wage loss Payments sent for cert (no dev)',1,19 UNION ALL
    select 'PAY','PAY Group 2',40,2,'Payments (all)',1,20 UNION ALL
    select 'PAY','PAY Group 2',40,2,'SA sent for cert',2,20 UNION ALL
    select 'PAY','PAY Group 2',15,3,'Certified or returned',1,22 UNION ALL
    select 'PRM','PRM Group 1',50,1,'Tier 1',1,23 UNION ALL
    select 'PRM','PRM Group 1',35,2,'Tier 2',1,24 UNION ALL
    select 'PRM','PRM Group 1',15,3,'Tier 3',1,25 UNION ALL
    select 'QCM','QCM Group 1',50,1,'Referral to Staff Nurse',1,26 UNION ALL
    select 'QCM','QCM Group 1',50,2,'Post-Nurse Closed TTD Action',1,27 UNION ALL
    select 'QCM','QCM Group 1',50,2,'Post-SECOP Action',2,27 UNION ALL
    select 'QCM','QCM Group 1',50,2,'No SECOP Action',3,27 UNION ALL
    select 'QCM','QCM Group 1',50,2,'SECOP/MSN',4,27
) q

insert into lead_element_group(weighting, sort_order, standards_group_id)
select distinct a.weighting, a.eg_sort_order, sg.id
from @TIMELINESS_GROUPS a
inner join lead_standards_group sg
on sg.[description] = a.standards_group
where sg.review_standards_id = @STANDARDS_ID

insert into lead_element_group_component(group_id, component_id, sort_order, review_standards_id)
select eg.id, lc.id, g.sort_order, lc.review_standards_id
from lead_element_group eg
inner join lead_standards_group sg
on eg.standards_group_id = sg.id
inner join @TIMELINESS_GROUPS g
on sg.[description] = g.standards_group
and eg.sort_order = g.eg_sort_order
and eg.weighting = g.weighting
inner join lead_component lc
on g.component = lc.component
where sg.review_standards_id = @STANDARDS_ID and lc.review_standards_id = @STANDARDS_ID

select * from review_standards where id = @STANDARDS_ID
select * from lead_element where review_standards_id = @STANDARDS_ID
select * from lead_question where element_id in (select id from lead_element where review_standards_id = @STANDARDS_ID)
select * from lead_component where review_standards_id = @STANDARDS_ID
select * from lead_standards_group where review_standards_id = @STANDARDS_ID
select * from lead_standards_group_grade where standards_group_id in (select id from lead_standards_group where review_standards_id = @STANDARDS_ID)
select * from lead_element_group where standards_group_id in (select id from lead_standards_group where review_standards_id = @STANDARDS_ID)
select * from lead_element_group_component where review_standards_id = @STANDARDS_ID
