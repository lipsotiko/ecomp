-- select * from [user] where last_name = 'MAHADY'

DECLARE cur_all CURSOR FOR select distinct user_id, id from review_evaluation where user_id in (5065, 5090)
OPEN cur_all

declare @UID INT, @EID INT
FETCH NEXT FROM cur_all INTO @UID, @EID;

WHILE @@FETCH_STATUS = 0  
BEGIN
    delete from timeliness_case where id in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID  and id = @EID)))
    delete from review_case_exclusion where review_id in (select review_id from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID and id = @EID)))
    delete from review_summary where review_period_id in (select id from review_period where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID and id = @EID))
    delete from review where review_period_id in (select id from review_period where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID  and id = @EID)) and review_section = 'TIMELINESS'
    delete from review_period where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID) and review_evaluation_id = @EID
    delete from review_evaluation_pip_element where review_evaluation_id in (select id from [review_evaluation] where user_id = @UID) and review_evaluation_id = @EID
    delete from [review_evaluation] where user_id = @UID and id = @EID

    FETCH NEXT FROM cur_all INTO @UID, @EID;
END;

close cur_all