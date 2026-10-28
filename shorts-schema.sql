-- Run in Supabase SQL Editor to enable NOVA Shorts interactions.
create table if not exists public.short_likes (
  video_id uuid not null references public.videos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(video_id,user_id)
);
create table if not exists public.short_comments (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null references public.videos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(trim(body)) between 1 and 500),
  created_at timestamptz not null default now()
);
create table if not exists public.short_reposts (
  video_id uuid not null references public.videos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(video_id,user_id)
);
create index if not exists short_comments_video_created on public.short_comments(video_id,created_at desc);
alter table public.short_likes enable row level security;
alter table public.short_comments enable row level security;
alter table public.short_reposts enable row level security;
drop policy if exists "Read public short likes" on public.short_likes;
create policy "Read public short likes" on public.short_likes for select to anon,authenticated using (exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Like public shorts" on public.short_likes;
create policy "Like public shorts" on public.short_likes for insert to authenticated with check (user_id=(select auth.uid()) and exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Unlike own shorts" on public.short_likes;
create policy "Unlike own shorts" on public.short_likes for delete to authenticated using(user_id=(select auth.uid()));
drop policy if exists "Read public short comments" on public.short_comments;
create policy "Read public short comments" on public.short_comments for select to anon,authenticated using (exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Comment on public shorts" on public.short_comments;
create policy "Comment on public shorts" on public.short_comments for insert to authenticated with check (user_id=(select auth.uid()) and exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Delete own comments" on public.short_comments;
create policy "Delete own comments" on public.short_comments for delete to authenticated using(user_id=(select auth.uid()));
drop policy if exists "Read public short reposts" on public.short_reposts;
create policy "Read public short reposts" on public.short_reposts for select to anon,authenticated using (exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Repost public shorts" on public.short_reposts;
create policy "Repost public shorts" on public.short_reposts for insert to authenticated with check (user_id=(select auth.uid()) and exists(select 1 from public.videos v where v.id=video_id and v.status='approved' and v.kind='short'));
drop policy if exists "Remove own repost" on public.short_reposts;
create policy "Remove own repost" on public.short_reposts for delete to authenticated using(user_id=(select auth.uid()));
grant select,insert,delete on public.short_likes,public.short_comments,public.short_reposts to authenticated;
grant select on public.short_likes,public.short_comments,public.short_reposts to anon;
