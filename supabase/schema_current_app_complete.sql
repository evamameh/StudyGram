-- StudyGram current app schema
-- Run this in Supabase SQL Editor for the Flutter app's current public.* tables.
-- This file matches the app code that uses:
-- profiles, posts, likes, comments, follows, post_saves, comment_likes.

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  bio text,
  avatar_url text,
  created_at timestamptz not null default now(),
  follower_count integer not null default 0,
  constraint profiles_follower_count_nonnegative check (follower_count >= 0)
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamptz not null default now()
);

create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(post_id, user_id)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null,
  parent_id uuid references public.comments(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(follower_id, following_id),
  check (follower_id <> following_id)
);

create table if not exists public.post_saves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid not null references public.posts(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, post_id)
);

create table if not exists public.comment_likes (
  id uuid primary key default gen_random_uuid(),
  comment_id uuid not null references public.comments(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(comment_id, user_id)
);

create index if not exists idx_posts_user_created
  on public.posts(user_id, created_at desc);

create index if not exists idx_follows_follower
  on public.follows(follower_id);

create index if not exists idx_follows_following
  on public.follows(following_id);

create index if not exists idx_post_saves_user_created
  on public.post_saves(user_id, created_at desc);

create index if not exists idx_comments_post_created
  on public.comments(post_id, created_at asc);

create index if not exists idx_likes_post_id
  on public.likes(post_id);

create index if not exists idx_comment_likes_comment_id
  on public.comment_likes(comment_id);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
alter table public.comments enable row level security;
alter table public.follows enable row level security;
alter table public.post_saves enable row level security;
alter table public.comment_likes enable row level security;

drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select" on public.profiles
for select to authenticated using (true);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
for insert to authenticated with check (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "posts_select" on public.posts;
create policy "posts_select" on public.posts
for select to authenticated using (true);

drop policy if exists "posts_insert_own" on public.posts;
create policy "posts_insert_own" on public.posts
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "posts_update_own" on public.posts;
create policy "posts_update_own" on public.posts
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "posts_delete_own" on public.posts;
create policy "posts_delete_own" on public.posts
for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "likes_select" on public.likes;
create policy "likes_select" on public.likes
for select to authenticated using (true);

drop policy if exists "likes_insert_own" on public.likes;
create policy "likes_insert_own" on public.likes
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "likes_delete_own" on public.likes;
create policy "likes_delete_own" on public.likes
for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "comments_select" on public.comments;
create policy "comments_select" on public.comments
for select to authenticated using (true);

drop policy if exists "comments_insert" on public.comments;
create policy "comments_insert" on public.comments
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "comments_update_own" on public.comments;
create policy "comments_update_own" on public.comments
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "comments_delete_owner_or_author" on public.comments;
create policy "comments_delete_owner_or_author" on public.comments
for delete to authenticated
using (
  auth.uid() = user_id
  or exists (
    select 1 from public.posts p
    where p.id = comments.post_id and p.user_id = auth.uid()
  )
);

drop policy if exists "follows_select" on public.follows;
create policy "follows_select" on public.follows
for select to authenticated using (true);

drop policy if exists "follows_insert_own" on public.follows;
create policy "follows_insert_own" on public.follows
for insert to authenticated with check (auth.uid() = follower_id);

drop policy if exists "follows_delete_own" on public.follows;
create policy "follows_delete_own" on public.follows
for delete to authenticated using (auth.uid() = follower_id);

drop policy if exists "post_saves_select_own" on public.post_saves;
create policy "post_saves_select_own" on public.post_saves
for select to authenticated using (auth.uid() = user_id);

drop policy if exists "post_saves_insert_own" on public.post_saves;
create policy "post_saves_insert_own" on public.post_saves
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "post_saves_delete_own" on public.post_saves;
create policy "post_saves_delete_own" on public.post_saves
for delete to authenticated using (auth.uid() = user_id);

drop policy if exists "comment_likes_select" on public.comment_likes;
create policy "comment_likes_select" on public.comment_likes
for select to authenticated using (true);

drop policy if exists "comment_likes_insert_own" on public.comment_likes;
create policy "comment_likes_insert_own" on public.comment_likes
for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "comment_likes_delete_own" on public.comment_likes;
create policy "comment_likes_delete_own" on public.comment_likes
for delete to authenticated using (auth.uid() = user_id);

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_username text;
begin
  base_username := coalesce(
    nullif(new.raw_user_meta_data->>'full_name', ''),
    nullif(trim(concat(
      new.raw_user_meta_data->>'first_name',
      ' ',
      new.raw_user_meta_data->>'last_name'
    )), ''),
    split_part(new.email, '@', 1),
    'student'
  );

  insert into public.profiles(id, username)
  values (new.id, base_username)
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists trg_create_profile_for_new_user on auth.users;
create trigger trg_create_profile_for_new_user
after insert on auth.users
for each row execute procedure public.create_profile_for_new_user();

create or replace function public.increment_profile_follower_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set follower_count = follower_count + 1
  where id = new.following_id;
  return new;
end;
$$;

create or replace function public.decrement_profile_follower_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set follower_count = greatest(0, follower_count - 1)
  where id = old.following_id;
  return old;
end;
$$;

drop trigger if exists trg_follows_insert_follower_count on public.follows;
create trigger trg_follows_insert_follower_count
after insert on public.follows
for each row execute procedure public.increment_profile_follower_count();

drop trigger if exists trg_follows_delete_follower_count on public.follows;
create trigger trg_follows_delete_follower_count
after delete on public.follows
for each row execute procedure public.decrement_profile_follower_count();

insert into storage.buckets(id, name, public)
values ('avatars', 'avatars', true), ('posts', 'posts', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "Public read avatars" on storage.objects;
create policy "Public read avatars"
on storage.objects for select
using (bucket_id = 'avatars');

drop policy if exists "Users upload avatar to own folder" on storage.objects;
create policy "Users upload avatar to own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users update own avatar folder" on storage.objects;
create policy "Users update own avatar folder"
on storage.objects for update to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users delete own avatar folder" on storage.objects;
create policy "Users delete own avatar folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Public read posts" on storage.objects;
create policy "Public read posts"
on storage.objects for select
using (bucket_id = 'posts');

drop policy if exists "Users upload post to own folder" on storage.objects;
create policy "Users upload post to own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'posts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users update own post folder" on storage.objects;
create policy "Users update own post folder"
on storage.objects for update to authenticated
using (
  bucket_id = 'posts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users delete own post folder" on storage.objects;
create policy "Users delete own post folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'posts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

alter table public.likes replica identity full;
alter table public.comment_likes replica identity full;
alter table public.comments replica identity full;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    if not exists (
      select 1
      from pg_publication_rel pr
      join pg_publication p on p.oid = pr.prpubid
      join pg_class c on c.oid = pr.prrelid
      join pg_namespace n on n.oid = c.relnamespace
      where p.pubname = 'supabase_realtime'
        and n.nspname = 'public'
        and c.relname = 'likes'
    ) then
      alter publication supabase_realtime add table public.likes;
    end if;

    if not exists (
      select 1
      from pg_publication_rel pr
      join pg_publication p on p.oid = pr.prpubid
      join pg_class c on c.oid = pr.prrelid
      join pg_namespace n on n.oid = c.relnamespace
      where p.pubname = 'supabase_realtime'
        and n.nspname = 'public'
        and c.relname = 'comments'
    ) then
      alter publication supabase_realtime add table public.comments;
    end if;

    if not exists (
      select 1
      from pg_publication_rel pr
      join pg_publication p on p.oid = pr.prpubid
      join pg_class c on c.oid = pr.prrelid
      join pg_namespace n on n.oid = c.relnamespace
      where p.pubname = 'supabase_realtime'
        and n.nspname = 'public'
        and c.relname = 'comment_likes'
    ) then
      alter publication supabase_realtime add table public.comment_likes;
    end if;
  end if;
end;
$$;
