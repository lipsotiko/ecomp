--Assumption is made that a CE SUPERVISOR account exists with the email 'ecomp+cesuper@intevity.com'

create procedure deleteCeData
    @USERNAME VARCHAR(255)
AS
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    delete from ce_supervisor_dashboard_user where claims_examiner_id = @USER_ID;
    delete from [user] where user_id = @USER_ID;

    delete from timeliness_case where id in (select timelinessCases_ID from REVIEW_timeliness_case where Review_REVIEWID in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))))
    delete from REVIEW_timeliness_case where Review_REVIEWID in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID)))
    delete from review_case_exclusion where review_id in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID)))
    delete from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))
    delete from review_summary where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))
    delete from review_period_reopen where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))
    delete from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID)
    delete from review_evaluation where user_id = @USER_ID

    declare @EVAL_ID INT;
    select @EVAL_ID = [id] from review_evaluation where user_id = @USER_ID;
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
    select * from timeliness_case where id in (select id from REVIEW_timeliness_case where Review_REVIEWID in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))))
    select * from review_case_exclusion where review_id in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID)))
    select * from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))
    select * from review_summary where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID))
    select * from review_period where review_evaluation_id in (select id from review_evaluation where user_id = @USER_ID)
    select * from review_evaluation where user_id = @USER_ID
go

create procedure generateTestUser
    @USERNAME VARCHAR(255),
    @FIRSTNAME VARCHAR(255),
    @LASTNAME VARCHAR(255),
    @GRADE INTEGER,
    @FISCAL_YEAR INTEGER,
    @PARTY_ID INTEGER,
    @CREATE_TEST_DATA bit = 1
as

    exec deleteCeData @USERNAME

    -- Add user as a Claims Examiner
    insert into [user](user_name, first_name, last_name, email_address) values (@USERNAME, @FIRSTNAME, @LASTNAME, 'ecomp+' + @USERNAME + '@intevity.com');
    declare @USER_ID INT = (select top 1 user_id from [user] where [user_name] = @USERNAME);
    declare @ROLE_ID INT = (select top 1 role_id from [role] where [description] = 'Claims Examiner');
    insert into user_role (role_id, user_id) values (@ROLE_ID, @USER_ID);
    insert into claims_examiner(user_id, party_id) values (@USER_ID, @PARTY_ID);

    declare  @SUPERVISOR_USER_ID INTEGER;
    select @SUPERVISOR_USER_ID = user_id from [user] where user_name in ('ecomp+cesuper@intevity.com');

    if(@CREATE_TEST_DATA = 1)
    begin
        -- Add review evaluation for fiscal year and user
        insert into review_evaluation (user_id, fiscal_year, grade, [start_date], review_type, ce_agreement_date, ce_supervisor_agreement_date, reviewing_officer_agreement_date, created_by)
        values(@USER_ID, @FISCAL_YEAR, @GRADE, CURRENT_TIMESTAMP, 'CE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, @SUPERVISOR_USER_ID);
        declare @EVAL_ID INT = (select TOP 1 [id] from dbo.review_evaluation where user_id = @USER_ID);

        -- Assign to supervisor dashboard
        insert into ce_supervisor_dashboard_user(ce_supervisor_id, claims_examiner_id) values(@SUPERVISOR_USER_ID, @USER_ID);

        create table #months (
            review_month INTEGER, 
            review_year INTEGER,
            review_status VARCHAR(255)
        )

        insert into #months (review_month, review_year, review_status)
        select 10, 2021, 'COMPLETED' union
        select 11, 2021, 'COMPLETED' union
        select 12, 2021, 'COMPLETED' union
        select 1, 2022, 'COMPLETED' union
        select 2, 2022, 'COMPLETED' union
        select 3, 2022, 'STARTED'

        -- Add Review Periods
        insert into dbo.review_period
        select review_month, review_year, @EVAL_ID
        from #months;

        -- Add reviews
        insert into review(review_section, element, component_id, review_status, total, ok, review_period_id)
        select distinct 'TIMELINESS' as review_section, c.element_id as element, c.id, m.review_status, 25 as total, 10 as ok, rp.id
        from dbo.lead_component c
        join dbo.lead_element_group eg on eg.element_id = c.element_id
        join dbo.lead_element_group_component egc on egc.component_id = c.id and egc.group_id = eg.group_id
        join dbo.review_evaluation re on re.user_id = @USER_ID and re.grade = @GRADE and re.fiscal_year = @FISCAL_YEAR
        full outer join #months m
        on 1 = 1
        inner join review_period rp
        on m.review_month = rp.review_month
        and m.review_year = rp.review_year
        and rp.review_evaluation_id = @EVAL_ID
        where c.element_id is not null
        UNION ALL
        select distinct 'QUALITY' as review_section, a.lead_element_id as element, null, m.review_status, 25 as total, 10 as ok, rp.id
        from lead_element a
        join dbo.review_evaluation re on re.user_id = @USER_ID and re.grade = @GRADE and re.fiscal_year = @FISCAL_YEAR
        full outer join #months m
        on 1 = 1
        inner join review_period rp
        on m.review_month = rp.review_month
        and m.review_year = rp.review_year
        and rp.review_evaluation_id = @EVAL_ID

        drop table #months

        -- Add review summaries
        insert into review_summary(quality_status, review_period_id, updated_by, updated_date)
        select distinct review_status, review_period_id, @SUPERVISOR_USER_ID, CURRENT_TIMESTAMP
        from review 
        where review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where id = @EVAL_ID))
        and review_section = 'QUALITY'

        update rs
        set rs.timeliness_status = r.review_status
        from review_summary rs
        join review r
        on rs.review_period_id = r.review_period_id
        where rs.review_period_id in (select id from review_period where review_evaluation_id in (select id from review_evaluation where id = @EVAL_ID))
        and review_section = 'TIMELINESS'
    end

    exec selectCeData @USERNAME

go

/*
exec deleteCeData @USERNAME = 'epon8'
exec deleteCeData @USERNAME = 'jwick7'
exec deleteCeData @USERNAME = 'bwayne'
exec deleteCeData @USERNAME = 'nromanov'
exec deleteCeData @USERNAME = 'tanderson'
exec deleteCeData @USERNAME = 'nportman'
*/
-- exec generateTestUser @USERNAME = 'epon8', @FIRSTNAME = 'Evan', @LASTNAME = 'Poe', @GRADE = 12, @FISCAL_YEAR = 2022, @PARTY_ID = 999;
-- exec generateTestUser @USERNAME = 'jwick7', @FIRSTNAME = 'John7', @LASTNAME = 'Wick', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 999;
-- exec generateTestUser @USERNAME = 'bwayne', @FIRSTNAME = 'Bruce', @LASTNAME = 'Wayne', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 888;
-- exec generateTestUser @USERNAME = 'nromanov', @FIRSTNAME = 'Natasha', @LASTNAME = 'Romanov', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 333;
-- exec generateTestUser @USERNAME = 'tanderson', @FIRSTNAME = 'Thomas', @LASTNAME = 'Anderson', @GRADE = 12, @FISCAL_YEAR = 2022, @PARTY_ID = 777;
-- exec generateTestUser @USERNAME = 'nportman', @FIRSTNAME = 'Natalie', @LASTNAME = 'Portman', @GRADE = 9, @FISCAL_YEAR = 2022, @PARTY_ID = 111;

-- Demo related data
exec generateTestUser @USERNAME = 'dfyers', @FIRSTNAME = 'Dominic', @LASTNAME = 'Fyers', @GRADE = 7, @FISCAL_YEAR = 2022, @PARTY_ID = 456, @CREATE_TEST_DATA = 0;

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