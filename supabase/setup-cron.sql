-- 配置定时任务脚本
-- 使用前请替换 <YOUR_PROJECT> 和 <SERVICE_ROLE_KEY>

-- 每天早上 9 点（UTC）检查未签到用户
select cron.schedule(
  'check-missed-check-ins-daily',
  '0 9 * * *',  -- Cron 表达式: 分 时 日 月 周
  $$
  select
    net.http_post(
      url := 'https://<YOUR_PROJECT>.supabase.co/functions/v1/check-missed-check-ins',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
      )
    ) as request_id;
  $$
);

-- 验证定时任务已创建
select
  jobid,
  schedule,
  command,
  nodename,
  nodeport,
  database,
  username,
  active
from cron.job;
