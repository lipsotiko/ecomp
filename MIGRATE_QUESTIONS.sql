DECLARE @ELEMENT_ID VARCHAR(255);
DECLARE @MONTH INT = 8;
DECLARE @YEAR INT = 2023;
DECLARE @REVIEW_CONFIGURATION_ID INT = (select id from review_standards where fiscal_year = 2023 and [description] = 'CE (revised)')

DECLARE element_cursor CURSOR FOR
SELECT 'ADJ' UNION
SELECT 'QCM' UNION
SELECT 'PRM' UNION
SELECT 'PAY' UNION
SELECT 'COM'

OPEN element_cursor
FETCH NEXT FROM element_cursor INTO @ELEMENT_ID
WHILE @@FETCH_STATUS = 0
BEGIN
    begin try drop table #tmp_review end try begin catch end catch
    select r.*, le.*
    into #tmp_review
    from review r
    inner join lead_element le
    on r.element_id = le.id
    inner join review_period rp
    on r.review_period_id = rp.id
    inner join review_evaluation re
    on rp.review_evaluation_id = re.id
    inner join review_standards rc
    on re.review_standards_id = rc.id
    where review_section = 'QUALITY'
        and r.ok > 0
        and rp.review_month = @MONTH
        and rp.review_year = @YEAR
        and le.lead_element_id = @ELEMENT_ID
        and rc.id = @REVIEW_CONFIGURATION_ID

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
        , r.created_at as review_date
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
    from lead_question
    where element_id in (select id from lead_element where lead_element_id = @ELEMENT_ID and review_standards_id = @REVIEW_CONFIGURATION_ID)
    order by question_number

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

        DECLARE @COMMENT_COL VARCHAR(255) = (SELECT 'COMMENT_' + CAST(@QUESTION_NUMBER as VARCHAR))
        IF COL_LENGTH('#tmp_results', @COMMENT_COL) IS NULL
        BEGIN
            EXEC('ALTER TABLE #tmp_results ADD [' + @COMMENT_COL+ '] VARCHAR(MAX)')
        END

        FETCH NEXT FROM db_cursor INTO @QUESTION_NUMBER, @QUESTION_TEXT
    END

    CLOSE db_cursor
    DEALLOCATE db_cursor


    DECLARE @REVIEW_ID INT
    DECLARE db_cursor CURSOR FOR
    select review_id from #tmp_review

    OPEN db_cursor
    FETCH NEXT FROM db_cursor INTO @REVIEW_ID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        begin try drop table #tmp_questions_and_answers end try begin catch end catch
        select rqr.question_number
            , rqr.response
            , rqr.comments
        into #tmp_questions_and_answers
        from review_quality_responses rqr
        where parent_review_id = @REVIEW_ID

        declare @SQL varchar(MAX) = ''
        select @SQL =  @SQL + 'update #tmp_results set Q_' + CAST(question_number as VARCHAR) + ' = ''' + response + ''' where review_id = ' + cast(@REVIEW_ID as VARCHAR(255)) + '; '
        from #tmp_questions_and_answers
        where response is not null
        exec(@SQL)

        set @SQL = ''
        select @SQL =  @SQL + 'update #tmp_results set COMMENT_' + CAST(question_number as VARCHAR) + ' = ''' + REPLACE(REPLACE(comments, '''', ''''), '''', '') + ''' where review_id = ' + cast(@REVIEW_ID as VARCHAR(255)) + '; '
        from #tmp_questions_and_answers
        where comments is not null
        begin try
            exec(@SQL)
        end try
        begin catch
            print(@SQL)
        end catch

        FETCH NEXT FROM db_cursor INTO @REVIEW_ID
    END

    CLOSE db_cursor
    DEALLOCATE db_cursor

    select @ELEMENT_ID as element, * from #tmp_lead_questions
    select * from #tmp_results order by review_period_date


    FETCH NEXT FROM element_cursor INTO @ELEMENT_ID
END

CLOSE element_cursor
DEALLOCATE element_cursor

