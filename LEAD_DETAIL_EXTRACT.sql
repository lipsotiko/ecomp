DECLARE @ELEMENT_ID VARCHAR(255) = 'QCM'
DECLARE @FISCAL_YEAR INT = 2023

begin try drop table #tmp_review end try begin catch end catch
select r.*, le.* 
into #tmp_review
from review r
inner join lead_element le
on r.element_id = le.id
inner join review_period rp
on r.review_period_id = rp.id
where review_section = 'QUALITY' and rp.review_month in (10, 11, 12) and rp.review_year = 2022 and le.lead_element_id = @ELEMENT_ID

begin try drop table #tmp_results end try begin catch end catch
select r.review_id
    , rp.review_year * 100 + rp.review_month as review_period_date
    , DateName(MONTH , DateAdd( MONTH , rp.review_month , -1)) as month_name
    , r.action_type
    , ce.party_id as ce_party_id
    , ce.last_name + ', ' + ce.first_name as claims_examiner
    , super.party_id as supervisor_party_id
    , super.last_name + ', ' + super.first_name as supervisor
    , rtrim(ltrim(ic.last_name)) + ', ' + rtrim(ltrim(ic.first_name)) as claimant_name
    , r.case_number
    , r.action_date
    , r.review_date
    , r.ok
    , r.total
into #tmp_results
from #tmp_review r
inner join lead_element le
on r.element_id = le.id
inner join review_period rp
on r.review_period_id = rp.id
inner join review_evaluation re
on rp.review_evaluation_id = re.id
left join [user] ce
on re.user_id = ce.user_id
left join ifecs_case ic
on r.case_id = ic.case_id
left join review_summary rs
on r.review_period_id = rs.review_period_id
left join [user] super
on rs.updated_by = super.user_id

begin try drop table #tmp_lead_questions end try begin catch end catch
select question_number, question_text
into #tmp_lead_questions 
from lead_question where element_id in (select id from lead_element where lead_element_id = @ELEMENT_ID and fiscal_year = @FISCAL_YEAR) order by question_number

DECLARE @QUESTION_NUMBER INT
DECLARE @QUESTION_TEXT VARCHAR(255)

DECLARE db_cursor CURSOR FOR 
select question_number, question_text from #tmp_lead_questions

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @QUESTION_NUMBER, @QUESTION_TEXT

WHILE @@FETCH_STATUS = 0  
BEGIN
    DECLARE @Q_COL VARCHAR(255) = (SELECT 'Q_' + CAST(@QUESTION_NUMBER as VARCHAR))
    IF COL_LENGTH('#tmp_results', @Q_COL) IS NULL
    BEGIN
        EXEC('ALTER TABLE #tmp_results ADD [' + @Q_COL+ '] VARCHAR(255)')
    END

    FETCH NEXT FROM db_cursor INTO @QUESTION_NUMBER, @QUESTION_TEXT
END 

CLOSE db_cursor  
DEALLOCATE db_cursor


DECLARE @REVIEW_ID INT
DECLARE @DETAILS_JSON VARCHAR(MAX)

DECLARE db_cursor CURSOR FOR 
select review_id, details from #tmp_review

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @REVIEW_ID, @DETAILS_JSON

WHILE @@FETCH_STATUS = 0  
BEGIN
    if (@DETAILS_JSON IS NOT NULL)
    begin
        begin try drop table #tmp_JSON end try begin catch end catch
        select * into #tmp_JSON from dbo.parseJSON(@DETAILS_JSON)

        begin try drop table #tmp_questions_and_answers end try begin catch end catch
        select CAST(questionNumber.StringValue as INT) as question_number, response.StringValue as response , comments.StringValue as comments
        into #tmp_questions_and_answers
        from (
            select parent_ID, [NAME], StringValue
            from #tmp_JSON
            where [NAME] = 'questionNumber'
        ) as questionNumber
        inner join (
            select parent_ID, [NAME], StringValue
            from #tmp_JSON
            where [NAME] = 'response'
        ) as response
        on questionNumber.parent_ID = response.parent_ID
        left join (
            select parent_ID, [NAME], StringValue
            from #tmp_JSON
            where [NAME] = 'comments'
        ) as comments
        on questionNumber.parent_ID = comments.parent_ID

        declare @SQL varchar(MAX)
        set @SQL = ''
        select @SQL =  @SQL + 'update #tmp_results set Q_' + CAST(question_number as VARCHAR) + ' = ''' + response + ''' where review_id = ' + cast(@REVIEW_ID as VARCHAR(255))
        from #tmp_questions_and_answers
        exec(@SQL)
    end

    FETCH NEXT FROM db_cursor INTO @REVIEW_ID, @DETAILS_JSON
END 

CLOSE db_cursor  
DEALLOCATE db_cursor

select * from #tmp_lead_questions
select * from #tmp_results where ok > 0 order by review_period_date