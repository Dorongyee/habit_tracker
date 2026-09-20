-- 습관 점수표: 테이블 + 보안 정책
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run 한 번만 실행하면 됩니다.

create table if not exists public.habit_data (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 행 수준 보안: 내 데이터만 읽고 쓸 수 있게
alter table public.habit_data enable row level security;

drop policy if exists "read own"   on public.habit_data;
drop policy if exists "insert own" on public.habit_data;
drop policy if exists "update own" on public.habit_data;

create policy "read own"
  on public.habit_data for select
  using (auth.uid() = user_id);

create policy "insert own"
  on public.habit_data for insert
  with check (auth.uid() = user_id);

create policy "update own"
  on public.habit_data for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
