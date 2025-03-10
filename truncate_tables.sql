-- 外部キー制約を一時的に無効化
SET session_replication_role = 'replica';

-- USER関連テーブルのトランケート
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE individual_profiles CASCADE;
TRUNCATE TABLE company_profiles CASCADE;
TRUNCATE TABLE user_skills CASCADE;
TRUNCATE TABLE user_employment_types CASCADE;
TRUNCATE TABLE user_locations CASCADE;
TRUNCATE TABLE user_work_styles CASCADE;

-- JOB関連テーブルのトランケート
TRUNCATE TABLE jobs CASCADE;
TRUNCATE TABLE job_skills CASCADE;

-- インボイス関連テーブルのトランケート
TRUNCATE TABLE invoices CASCADE;

-- その他関連テーブル
TRUNCATE TABLE likes CASCADE;
TRUNCATE TABLE conversations CASCADE;
TRUNCATE TABLE messages CASCADE;

-- 外部キー制約を再度有効化
SET session_replication_role = 'origin';
