--Assumption is made that a CE SUPERVISOR account exists with the email 'ecomp+cesuper@intevity.com'

create procedure deleteCeData
    @USERNAME VARCHAR(255)
AS
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    delete from ce_supervisor_dashboard_user where claims_examiner_id = @USER_ID
    delete from review where user_id = @USER_ID
    delete from review_summary where user_id = @USER_ID
    delete from [user] where user_id = @USER_ID
    delete from review_period where user_id = @USER_ID
go

create procedure selectCeData
    @USERNAME VARCHAR(255)
AS
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    select * from [user] where user_id = @USER_ID
    select * from [claims_examiner] where user_id = @USER_ID
    select * from ce_supervisor_dashboard_user where claims_examiner_id = @USER_ID
    select * from review where user_id = @USER_ID
    select * from review_summary where user_id  = @USER_ID
    select * from review_period where user_id = @USER_ID
go

create procedure generateTestUser
    @USERNAME VARCHAR(255),
    @FIRSTNAME VARCHAR(255),
    @LASTNAME VARCHAR(255),
    @GRADE INTEGER
as

    exec deleteCeData @USERNAME

    -- Add user as a Claims Examiner
    insert into [user](user_name, first_name, last_name, email_address) values (@USERNAME, @FIRSTNAME, @LASTNAME, @USERNAME + '@example.com');
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    declare @ROLE_ID INT = (select top 1 role_id from [role] where [description] = 'Claims Examiner');
    insert into user_role (role_id, user_id) values (@ROLE_ID, @USER_ID);
    insert into claims_examiner(user_id, grade, party_id) values (@USER_ID, @GRADE, 999);

    declare  @SUPERVISOR_USER_ID INTEGER;
    select @SUPERVISOR_USER_ID = user_id from [user] where user_name in ('ecomp+cesuper@intevity.com')

    -- Assign to supervisor dashboard
    insert into ce_supervisor_dashboard_user(ce_supervisor_id, claims_examiner_id) values(@SUPERVISOR_USER_ID, @USER_ID);

    create table #months (
        review_month INTEGER, 
        review_year INTEGER,
        fiscal_year INTEGER,
        review_status VARCHAR(255),
        grade INTEGER
    )

    insert into #months (review_month, review_year, fiscal_year, review_status)
    select 10, 2020, 2021, 'COMPLETED' union
    select 11, 2020, 2021, 'COMPLETED' union
    select 12, 2020, 2021, 'COMPLETED' union

    select 1, 2021, 2021, 'STARTED' union
    select 2, 2021, 2021, 'STARTED' union
    select 3, 2021, 2021, 'STARTED' union
    select 4, 2021, 2021, 'STARTED' union
    select 5, 2021, 2021, 'STARTED' union
    select 6, 2021, 2021, 'STARTED' union
    select 7, 2021, 2021, 'STARTED' union
    select 8, 2021, 2021, 'STARTED' union
    select 9, 2021, 2021, 'STARTED' union
    select 10, 2021, 2022, 'COMPLETED' union
    select 11, 2021, 2022, 'COMPLETED' union
    select 12, 2021, 2022, 'COMPLETED' union

    select 1, 2021, 2022, 'STARTED' union
    select 2, 2021, 2022, 'STARTED' union
    select 3, 2021, 2022, 'STARTED' union
    select 4, 2021, 2022, 'STARTED' union
    select 5, 2021, 2022, 'STARTED' union
    select 6, 2021, 2022, 'STARTED' union
    select 7, 2021, 2022, 'STARTED' union
    select 8, 2021, 2022, 'STARTED' union
    select 9, 2021, 2022, 'STARTED' union
    select 10, 2021, 2023, 'COMPLETED' union
    select 11, 2021, 2023, 'COMPLETED' union
    select 12, 2021, 2023, 'COMPLETED' union

    select 1, 2022, 2023, 'STARTED' union
    select 2, 2022, 2023, 'STARTED' union
    select 3, 2022, 2023, 'STARTED' union
    select 4, 2022, 2023, 'STARTED' union
    select 5, 2022, 2023, 'STARTED' union
    select 6, 2022, 2023, 'STARTED' union
    select 7, 2022, 2023, 'STARTED' union
    select 8, 2022, 2023, 'STARTED' union
    select 9, 2022, 2023, 'STARTED' union
    select 10, 2022, 2024, 'COMPLETED' union
    select 11, 2022, 2024, 'COMPLETED' union
    select 12, 2022, 2024, 'COMPLETED'

    insert into review(user_id, review_month, review_year, fiscal_year, grade, review_type, review_section, element, component_id, review_status, total, ok)
    select @USER_ID as user_id, m.review_month, m.review_year, legc.fiscal_year, legc.grade, 'CE' as review_type, 'TIMELINESS' as review_section, leg.element_id as element, legc.component_id, m.review_status, 25 as total, 10 as ok
    from lead_element_group_component legc
    inner join lead_element_group leg
    on leg.group_id = legc.group_id
    inner join #months m
    on m.fiscal_year = legc.fiscal_year
    and legc.grade = @GRADE
    UNION ALL
    select distinct @USER_ID as user_id, m.review_month, m.review_year, legc.fiscal_year, legc.grade, 'CE' as review_type, 'QUALITY' as review_section, leg.element_id as element, null, m.review_status, 25 as total, 10 as ok
    from lead_element_group_component legc
    inner join lead_element_group leg
    on leg.group_id = legc.group_id
    inner join #months m
    on m.fiscal_year = legc.fiscal_year
    and legc.grade = @GRADE
    
    drop table #months

    insert into review_summary(user_id, quality_status, review_month, fiscal_year, grade, review_type, updated_by, updated_date)
    select distinct user_id, review_status, review_month, fiscal_year, grade, review_type, @SUPERVISOR_USER_ID, CURRENT_TIMESTAMP
    from review 
    where user_id = @USER_ID
    and review_section = 'QUALITY'

    update rs
    set rs.timeliness_status = r.review_status
    from review_summary rs
    join review r
    on rs.review_type = r.review_type
    and rs.review_month = r.review_month
    and rs.fiscal_year = r.fiscal_year
    and rs.grade = r.grade
    and rs.user_id = r.user_id
    where rs.user_id = @USER_ID
    and review_section = 'TIMELINESS'

    insert into review_period (user_id, fiscal_year, grade, [start_date], review_type, ce_agreement_date, ce_supervisor_agreement_date, reviewing_officer_agreement_date, created_by)
    values(@USER_ID, 2022, @GRADE, CURRENT_TIMESTAMP, 'CE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, @SUPERVISOR_USER_ID);

    exec selectCeData @USERNAME

go

exec generateTestUser @USERNAME = 'jwick7', @FIRSTNAME = 'John7', @LASTNAME = 'Wick', @GRADE = 7;
exec generateTestUser @USERNAME = 'jwick12', @FIRSTNAME = 'John12', @LASTNAME = 'Wick', @GRADE = 12;

go

begin try 
    drop PROCEDURE generateTestUser
end try
begin catch
end catch
go 

begin try 
    drop PROCEDURE selectCeData
end try
begin catch
end catch
go 

begin try 
    drop PROCEDURE deleteCeData
end try
begin catch
end catch
go 
