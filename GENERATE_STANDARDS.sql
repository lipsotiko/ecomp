select distinct le.lead_element_id, cg.grade, eg.sort_order, eg.group_id, 'insert into lead_element_group([weighting], [sort_order], [element_id]) output inserted.group_id into @tmp_group_id values(' + cast(eg.weighting as varchar) + ', ' + cast(eg.sort_order as varchar) + ', ' + vars.[var] + ')' 
from lead_element_group_component cg
inner join lead_component lc
on cg.component_id = lc.id
inner join lead_element_group eg
on cg.group_id = eg.group_id
inner join lead_element le
on eg.element_id = le.id
inner join (
    select 'ADJ' as lead_element_id, '@ADJ_ELEMENT_ID' as var UNION
    select 'COM', '@COM_ELEMENT_ID' UNION
    select 'QCM', '@QCM_ELEMENT_ID' UNION
    select 'PRM', '@PRM_ELEMENT_ID' UNION
    select 'PAY', '@PAY_ELEMENT_ID'
) vars
on le.lead_element_id = vars.lead_element_id
where cg.fiscal_year = 2023 
order by le.lead_element_id, cg.grade, eg.sort_order, eg.group_id


select le.lead_element_id, cg.grade, eg.sort_order, eg.group_id, 'insert into lead_element_group_component (group_id, component_id, grade, sort_order, review_configuration_id) values ((select top 1 id from @tmp_group_id), (select id from lead_component where component = ''' + lc.component + ''' and element_id =  '+ vars.[var] +'), @GRADE, ' + cast(cg.sort_order as varchar) + ', @REVIEW_CONFIGURATION_ID)' 
from lead_element_group_component cg
inner join lead_component lc
on cg.component_id = lc.id
inner join lead_element_group eg
on cg.group_id = eg.group_id
inner join lead_element le
on eg.element_id = le.id
inner join (
    select 'ADJ' as lead_element_id, '@ADJ_ELEMENT_ID' as var UNION
    select 'COM', '@COM_ELEMENT_ID' UNION
    select 'QCM', '@QCM_ELEMENT_ID' UNION
    select 'PRM', '@PRM_ELEMENT_ID' UNION
    select 'PAY', '@PAY_ELEMENT_ID'
) vars
on le.lead_element_id = vars.lead_element_id
where cg.fiscal_year = 2023 
order by le.lead_element_id, cg.grade, eg.sort_order, eg.group_id