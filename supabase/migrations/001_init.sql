create table users (
  id uuid primary key references auth.users(id),
  name text not null,
  emergency_email text not null,
  created_at timestamp with time zone default now()
);

create table check_ins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  check_in_date date not null,
  created_at timestamp with time zone default now(),
  unique (user_id, check_in_date)
);