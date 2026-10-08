-- Optional check. Run after steps 1, 2 and 3.
-- Expect: rowsecurity = true for both tables, policies listed, bucket public = true.

select tablename, rowsecurity
from pg_tables
where schemaname = 'public' and tablename in ('search_history', 'chat_messages');

select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public' and tablename in ('search_history', 'chat_messages')
order by tablename, policyname;

select id, public, file_size_limit
from storage.buckets
where id = 'recipe-images';
