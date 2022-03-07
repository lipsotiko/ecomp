--Assumption is made that a CE SUPERVISOR account exists with the email 'ecomp+cesuper@intevity.com'

create procedure deleteCeData
    @USERNAME VARCHAR(255),
    @GRADE INT,
    @FISCAL_YEAR INT
AS
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    delete from ce_supervisor_dashboard_user where claims_examiner_id = @USER_ID;
    delete from [user] where user_id = @USER_ID;
    delete from review where user_id = @USER_ID;
    delete from review_summary where user_id = @USER_ID;
    declare @EVAL_ID INT;
    select @EVAL_ID = [id] from review_evaluation where user_id = @USER_ID and grade = @GRADE and fiscal_year = @FISCAL_YEAR;
    delete rp
    from dbo.review_period rp
    join dbo.review_evaluation re
        on rp.review_evaluation_id = @EVAL_ID;
    delete from review_evaluation where [id] = @EVAL_ID;
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
    select * from review_evaluation where user_id = @USER_ID
go

create procedure generateTestUser
    @USERNAME VARCHAR(255),
    @FIRSTNAME VARCHAR(255),
    @LASTNAME VARCHAR(255),
    @GRADE INTEGER,
    @FISCAL_YEAR INTEGER,
    @PARTY_ID INTEGER
as

    exec deleteCeData @USERNAME, @GRADE, @FISCAL_YEAR

    -- Add user as a Claims Examiner
    insert into [user](user_name, first_name, last_name, email_address) values (@USERNAME, @FIRSTNAME, @LASTNAME, 'ecomp+' + @USERNAME + '@intevity.com');
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    declare @ROLE_ID INT = (select top 1 role_id from [role] where [description] = 'Claims Examiner');
    insert into user_role (role_id, user_id) values (@ROLE_ID, @USER_ID);
    insert into claims_examiner(user_id, party_id) values (@USER_ID, @PARTY_ID);

    declare  @SUPERVISOR_USER_ID INTEGER;
    select @SUPERVISOR_USER_ID = user_id from [user] where user_name in ('ecomp+cesuper@intevity.com');

    -- Add review evaluation for fiscal year and user
    insert into review_evaluation (user_id, fiscal_year, grade, [start_date], review_type, ce_agreement_date, ce_supervisor_agreement_date, reviewing_officer_agreement_date, created_by)
    values(@USER_ID, @FISCAL_YEAR, @GRADE, CURRENT_TIMESTAMP, 'CE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, @SUPERVISOR_USER_ID);
    declare @EVAL_ID INT;
    select @EVAL_ID = [id] from dbo.review_evaluation where [grade] = @GRADE and [user_id] = @USER_ID and [fiscal_year] = @FISCAL_YEAR and [close_date] IS NULL;

    -- Assign to supervisor dashboard
    insert into ce_supervisor_dashboard_user(ce_supervisor_id, claims_examiner_id) values(@SUPERVISOR_USER_ID, @USER_ID);

    create table #months (
        review_month INTEGER, 
        review_year INTEGER,
        fiscal_year INTEGER,
        review_status VARCHAR(255),
        grade INTEGER
    )

    insert into #months (review_month, review_year, fiscal_year, review_status, grade)
   
    select 10, 2021, @FISCAL_YEAR, 'COMPLETED', @GRADE union
    select 11, 2021, @FISCAL_YEAR, 'COMPLETED', @GRADE union
    select 12, 2021, @FISCAL_YEAR, 'COMPLETED', @GRADE union
    select 1, 2022, @FISCAL_YEAR, 'COMPLETED', @GRADE union
    select 2, 2022, @FISCAL_YEAR, 'COMPLETED', @GRADE union
    select 3, 2022, @FISCAL_YEAR, 'STARTED', @GRADE

    -- Add review periods
    insert into dbo.review_period
    select review_month, review_year, @EVAL_ID
    from #months;
    select * from dbo.review_period;

    -- Add reviews
    insert into review(user_id, review_month, review_year, fiscal_year, grade, review_type, review_section, element, component_id, review_status, review_period_id, total, ok)
    select @USER_ID as user_id, m.review_month, m.review_year, m.fiscal_year, m.grade, 'CE' as review_type, 'TIMELINESS' as review_section, c.element_id as element, c.id, m.review_status, rp.id, 25 as total, 10 as ok
    from dbo.lead_component c
    join dbo.lead_element_group eg on eg.element_id = c.element_id
    join dbo.lead_element_group_component egc on egc.component_id = c.id and egc.group_id = eg.group_id
    join dbo.review_evaluation re on re.user_id = @USER_ID and re.grade = @GRADE and re.fiscal_year = @FISCAL_YEAR
    join dbo.review_period rp on rp.review_evaluation_id = re.id
    full outer join #months m
    on m.fiscal_year = egc.fiscal_year
    and m.grade = egc.grade
    where c.element_id is not null and m.grade = @GRADE
    UNION ALL
    select distinct @USER_ID as user_id, m.review_month, m.review_year, m.fiscal_year, m.grade, 'CE' as review_type, 'QUALITY' as review_section, a.lead_element_id as element, null, m.review_status, re.id, 25 as total, 10 as ok
    from lead_element a
    join dbo.review_evaluation re on re.user_id = @USER_ID and re.grade = @GRADE and re.fiscal_year = @FISCAL_YEAR
    join dbo.review_period rp on rp.review_evaluation_id = re.id
    cross join #months m

    drop table #months

    -- Add reivew summaries
    insert into review_summary(user_id, quality_status, review_month, fiscal_year, grade, review_type, review_period_id, updated_by, updated_date)
    select distinct user_id, review_status, review_month, fiscal_year, grade, review_type, review_period_id, @SUPERVISOR_USER_ID, CURRENT_TIMESTAMP
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

    exec selectCeData @USERNAME

go

exec generateTestUser @USERNAME = 'jwick', @FIRSTNAME = 'John', @LASTNAME = 'Wick', @GRADE = 9, @FISCAL_YEAR = 2022, @PARTY_ID = 999;
exec generateTestUser @USERNAME = 'jwick12', @FIRSTNAME = 'John12', @LASTNAME = 'Wick', @GRADE = 12, @FISCAL_YEAR = 2022, @PARTY_ID = 999;
exec generateTestUser @USERNAME = 'jwick7', @FIRSTNAME = 'John7', @LASTNAME = 'Wick', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 999;
exec generateTestUser @USERNAME = 'bwayne', @FIRSTNAME = 'Bruce', @LASTNAME = 'Wayne', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 888;
exec generateTestUser @USERNAME = 'nromanov', @FIRSTNAME = 'Natasha', @LASTNAME = 'Romanov', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 333;
exec generateTestUser @USERNAME = 'tanderson', @FIRSTNAME = 'Thomas', @LASTNAME = 'Anderson', @GRADE = 12, @FISCAL_YEAR = 2022, @PARTY_ID = 777;
exec generateTestUser @USERNAME = 'nportman', @FIRSTNAME = 'Natalie', @LASTNAME = 'Portman', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 111;

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