-- NOVA STREAM: channel followers / following
-- Run this file in Supabase Dashboard -> SQL Editor -> New query -> Run.
create table if not exists public.channel_follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  followed_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  constraint channel_follows_no_self_follow check (follower_id <> followed_id)
);

create index if not exists channel_follows_followed_id_idx
  on public.channel_follows(followed_id);
create index if not exists channel_follows_follower_id_idx
  on public.channel_follows(follower_id);

alter table public.channel_follows enable row level security;

drop policy if exists "Anyone can read channel follows" on public.channel_follows;
create policy "Anyone can read channel follows"
  on public.channel_follows for select
  using (true);

drop policy if exists "Users can follow as themselves" on public.channel_follows;
create policy "Users can follow as themselves"
  on public.channel_follows for insert
  to authenticated
  with check (auth.uid() = follower_id and follower_id <> followed_id);

drop policy if exists "Users can unfollow as themselves" on public.channel_follows;
create policy "Users can unfollow as themselves"
  on public.channel_follows for delete
  to authenticated
  using (auth.uid() = follower_id);
