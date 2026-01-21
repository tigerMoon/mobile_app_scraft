-- 启用 pg_cron 扩展
create extension if not exists pg_cron;

-- 授予 Supabase 权限访问 cron schema
grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

-- 配置定时任务：每天早上 9 点（UTC）检查未签到用户
-- 注意：这个任务需要在部署后手动配置，因为需要填入实际的项目 URL 和 Service Role Key
--
-- 使用方法：
-- 1. 在 Supabase SQL Editor 中执行以下 SQL（替换 <YOUR_PROJECT> 和 <SERVICE_ROLE_KEY>）:
--
-- select cron.schedule(
--   'check-missed-check-ins-daily',
--   '0 9 * * *',
--   $$
--   select
--     net.http_post(
--       url := 'https://<YOUR_PROJECT>.supabase.co/functions/v1/check-missed-check-ins',
--       headers := jsonb_build_object(
--         'Content-Type', 'application/json',
--         'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
--       )
--     ) as request_id;
--   $$
-- );
--
-- 2. 验证定时任务已创建:
-- select * from cron.job;
--
-- 3. 查看定时任务执行历史:
-- select * from cron.job_run_details order by start_time desc limit 10;

-- 如果需要删除定时任务:
-- select cron.unschedule('check-missed-check-ins-daily');
