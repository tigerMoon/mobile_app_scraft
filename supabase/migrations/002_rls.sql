alter table users enable row level security;
alter table check_ins enable row level security;

create policy "user manage self"
on users for all
using (auth.uid() = id);

create policy "user manage own checkins"
on check_ins for all
using (auth.uid() = user_id);