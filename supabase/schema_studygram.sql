-- StudyGram schema
-- Run this in the Supabase SQL editor.
-- This is separate from the existing Pulso tables and only uses studygram_* names.

create extension if not exists "pgcrypto";

create table if not exists public.studygram_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_name text not null default '',
  last_name text not null default '',
  avatar_url text,
  bio text,
  post_count integer not null default 0,
  follower_count integer not null default 0,
  saved_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint studygram_profiles_post_count_nonnegative check (post_count >= 0),
  constraint studygram_profiles_follower_count_nonnegative check (follower_count >= 0),
  constraint studygram_profiles_saved_count_nonnegative check (saved_count >= 0)
);

create table if not exists public.studygram_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.studygram_profiles(id) on delete cascade,
  title text not null,
  subject text not null,
  content text not null,
  material_url text,
  material_type text,
  like_count integer not null default 0,
  comment_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint studygram_posts_subject_check check (
    subject in (
      'Mathematics',
      'Programming',
      'Physics',
      'Biology',
      'English',
      'Others'
    )
  ),
  constraint studygram_posts_like_count_nonnegative check (like_count >= 0),
  constraint studygram_posts_comment_count_nonnegative check (comment_count >= 0)
);

create table if not exists public.studygram_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.studygram_posts(id) on delete cascade,
  user_id uuid not null references public.studygram_profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.studygram_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.studygram_posts(id) on delete cascade,
  user_id uuid not null references public.studygram_profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(post_id, user_id)
);

create index if not exists studygram_posts_created_at_idx
on public.studygram_posts(created_at desc);

create index if not exists studygram_posts_subject_idx
on public.studygram_posts(subject);

create index if not exists studygram_posts_user_id_idx
on public.studygram_posts(user_id);

create index if not exists studygram_comments_post_id_created_at_idx
on public.studygram_comments(post_id, created_at asc);

create index if not exists studygram_likes_post_id_idx
on public.studygram_likes(post_id);

alter table public.studygram_profiles enable row level security;
alter table public.studygram_posts enable row level security;
alter table public.studygram_comments enable row level security;
alter table public.studygram_likes enable row level security;

drop policy if exists "studygram_profiles_select" on public.studygram_profiles;
create policy "studygram_profiles_select" on public.studygram_profiles
for select to authenticated using (true);

drop policy if exists "studygram_profiles_insert_own" on public.studygram_profiles;
create policy "studygram_profiles_insert_own" on public.studygram_profiles
for insert to authenticated
with check (auth.uid() = id);

drop policy if exists "studygram_profiles_update_own" on public.studygram_profiles;
create policy "studygram_profiles_update_own" on public.studygram_profiles
for update to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "studygram_posts_select" on public.studygram_posts;
create policy "studygram_posts_select" on public.studygram_posts
for select to authenticated using (true);

drop policy if exists "studygram_posts_insert_own" on public.studygram_posts;
create policy "studygram_posts_insert_own" on public.studygram_posts
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "studygram_posts_update_own" on public.studygram_posts;
create policy "studygram_posts_update_own" on public.studygram_posts
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "studygram_posts_delete_own" on public.studygram_posts;
create policy "studygram_posts_delete_own" on public.studygram_posts
for delete to authenticated
using (auth.uid() = user_id);

drop policy if exists "studygram_comments_select" on public.studygram_comments;
create policy "studygram_comments_select" on public.studygram_comments
for select to authenticated using (true);

drop policy if exists "studygram_comments_insert_own" on public.studygram_comments;
create policy "studygram_comments_insert_own" on public.studygram_comments
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "studygram_comments_update_own" on public.studygram_comments;
create policy "studygram_comments_update_own" on public.studygram_comments
for update to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "studygram_comments_delete_owner_or_post_author" on public.studygram_comments;
create policy "studygram_comments_delete_owner_or_post_author" on public.studygram_comments
for delete to authenticated
using (
  auth.uid() = user_id
  or exists (
    select 1
    from public.studygram_posts p
    where p.id = studygram_comments.post_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "studygram_likes_select" on public.studygram_likes;
create policy "studygram_likes_select" on public.studygram_likes
for select to authenticated using (true);

drop policy if exists "studygram_likes_insert_own" on public.studygram_likes;
create policy "studygram_likes_insert_own" on public.studygram_likes
for insert to authenticated
with check (auth.uid() = user_id);

drop policy if exists "studygram_likes_delete_own" on public.studygram_likes;
create policy "studygram_likes_delete_own" on public.studygram_likes
for delete to authenticated
using (auth.uid() = user_id);

create or replace function public.studygram_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_studygram_profiles_updated_at on public.studygram_profiles;
create trigger trg_studygram_profiles_updated_at
before update on public.studygram_profiles
for each row execute procedure public.studygram_set_updated_at();

drop trigger if exists trg_studygram_posts_updated_at on public.studygram_posts;
create trigger trg_studygram_posts_updated_at
before update on public.studygram_posts
for each row execute procedure public.studygram_set_updated_at();

drop trigger if exists trg_studygram_comments_updated_at on public.studygram_comments;
create trigger trg_studygram_comments_updated_at
before update on public.studygram_comments
for each row execute procedure public.studygram_set_updated_at();

create or replace function public.studygram_increment_post_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_profiles
  set post_count = post_count + 1
  where id = new.user_id;
  return new;
end;
$$;

create or replace function public.studygram_decrement_post_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_profiles
  set post_count = greatest(0, post_count - 1)
  where id = old.user_id;
  return old;
end;
$$;

drop trigger if exists trg_studygram_posts_insert_count on public.studygram_posts;
create trigger trg_studygram_posts_insert_count
after insert on public.studygram_posts
for each row execute procedure public.studygram_increment_post_count();

drop trigger if exists trg_studygram_posts_delete_count on public.studygram_posts;
create trigger trg_studygram_posts_delete_count
after delete on public.studygram_posts
for each row execute procedure public.studygram_decrement_post_count();

create or replace function public.studygram_increment_like_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_posts
  set like_count = like_count + 1
  where id = new.post_id;
  return new;
end;
$$;

create or replace function public.studygram_decrement_like_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_posts
  set like_count = greatest(0, like_count - 1)
  where id = old.post_id;
  return old;
end;
$$;

drop trigger if exists trg_studygram_likes_insert_count on public.studygram_likes;
create trigger trg_studygram_likes_insert_count
after insert on public.studygram_likes
for each row execute procedure public.studygram_increment_like_count();

drop trigger if exists trg_studygram_likes_delete_count on public.studygram_likes;
create trigger trg_studygram_likes_delete_count
after delete on public.studygram_likes
for each row execute procedure public.studygram_decrement_like_count();

create or replace function public.studygram_increment_comment_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_posts
  set comment_count = comment_count + 1
  where id = new.post_id;
  return new;
end;
$$;

create or replace function public.studygram_decrement_comment_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.studygram_posts
  set comment_count = greatest(0, comment_count - 1)
  where id = old.post_id;
  return old;
end;
$$;

drop trigger if exists trg_studygram_comments_insert_count on public.studygram_comments;
create trigger trg_studygram_comments_insert_count
after insert on public.studygram_comments
for each row execute procedure public.studygram_increment_comment_count();

drop trigger if exists trg_studygram_comments_delete_count on public.studygram_comments;
create trigger trg_studygram_comments_delete_count
after delete on public.studygram_comments
for each row execute procedure public.studygram_decrement_comment_count();

create or replace function public.studygram_create_profile_for_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.studygram_profiles (id, first_name, last_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_studygram_auth_user_profile on auth.users;
create trigger trg_studygram_auth_user_profile
after insert on auth.users
for each row execute procedure public.studygram_create_profile_for_new_user();

-- Optional realtime support. These blocks are safe to re-run.
do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_rel pr
    join pg_publication p on p.oid = pr.prpubid
    join pg_class c on c.oid = pr.prrelid
    join pg_namespace n on n.oid = c.relnamespace
    where p.pubname = 'supabase_realtime'
      and n.nspname = 'public'
      and c.relname = 'studygram_posts'
  ) then
    alter publication supabase_realtime add table public.studygram_posts;
  end if;
end;
$$;

do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_rel pr
    join pg_publication p on p.oid = pr.prpubid
    join pg_class c on c.oid = pr.prrelid
    join pg_namespace n on n.oid = c.relnamespace
    where p.pubname = 'supabase_realtime'
      and n.nspname = 'public'
      and c.relname = 'studygram_comments'
  ) then
    alter publication supabase_realtime add table public.studygram_comments;
  end if;
end;
$$;
