-- MOBILAINISHA 7.5 — proposed schema, NOT deployed.
-- Review Russian personal-data localization, auth and RLS before production use.
-- Existing staff_members role constraint must be extended in a separate migration.
create table if not exists public.repair_orders (
 id uuid primary key default gen_random_uuid(),
 order_number text not null unique,
 store_id integer not null references public.stores(id),
 customer_id uuid references auth.users(id),
 assigned_master_id uuid references auth.users(id),
 device_kind text not null,
 brand_model text not null,
 serial_imei text,
 reported_fault text not null,
 visible_condition text,
 accessories text,
 stage text not null default 'requested'
   check (stage in ('requested','intake_pending','accepted','diagnostics','approval_pending','approved','repairing','waiting_parts','quality_check','ready','payment_pending','handover_pending','issued','cancelled','returned_unrepaired')),
 quoted_amount numeric(12,2) check (quoted_amount >= 0),
 final_amount numeric(12,2) check (final_amount >= 0),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.repair_events (
 id bigint generated always as identity primary key,
 repair_id uuid not null references public.repair_orders(id),
 actor_id uuid references auth.users(id),
 event_type text not null,
 previous_stage text,
 next_stage text,
 note text,
 created_at timestamptz not null default now()
);
create table if not exists public.repair_media (
 id uuid primary key default gen_random_uuid(),
 repair_id uuid not null references public.repair_orders(id),
 uploaded_by uuid not null references auth.users(id),
 stage text not null,
 side text check (side in ('front','back','left','right','top','bottom','video','damage','diagnostic','handover')),
 storage_path text not null,
 content_type text not null,
 sha256 text,
 created_at timestamptz not null default now()
);
create table if not exists public.repair_documents (
 id uuid primary key default gen_random_uuid(),
 repair_id uuid not null references public.repair_orders(id),
 kind text not null check (kind in ('intake','diagnosis','approval','work_report','handover')),
 version integer not null default 1,
 document_payload jsonb not null,
 document_file_path text,
 customer_signed_at timestamptz,
 staff_signed_at timestamptz,
 customer_signature_evidence jsonb,
 staff_signature_evidence jsonb,
 created_at timestamptz not null default now(),
 unique(repair_id,kind,version)
);
create table if not exists public.repair_approvals (
 id uuid primary key default gen_random_uuid(),
 repair_id uuid not null references public.repair_orders(id),
 proposed_by uuid references auth.users(id),
 customer_id uuid references auth.users(id),
 proposal jsonb not null,
 decision text not null default 'pending' check (decision in ('pending','approved','rejected','question')),
 decided_at timestamptz,
 decision_evidence jsonb,
 created_at timestamptz not null default now()
);
create table if not exists public.repair_messages (
 id uuid primary key default gen_random_uuid(),
 repair_id uuid not null references public.repair_orders(id),
 sender_id uuid not null references auth.users(id),
 audience text not null check (audience in ('customer','staff','manager','owner')),
 body text not null,
 created_at timestamptz not null default now()
);
create table if not exists public.notification_outbox (
 id bigint generated always as identity primary key,
 recipient_id uuid not null references auth.users(id),
 repair_id uuid references public.repair_orders(id),
 event_type text not null,
 payload jsonb not null default '{}'::jsonb,
 delivery_state text not null default 'pending',
 created_at timestamptz not null default now(),
 delivered_at timestamptz
);
-- Deny access until explicitly reviewed per-role policies are deployed.
alter table public.repair_orders enable row level security;
alter table public.repair_events enable row level security;
alter table public.repair_media enable row level security;
alter table public.repair_documents enable row level security;
alter table public.repair_approvals enable row level security;
alter table public.repair_messages enable row level security;
alter table public.notification_outbox enable row level security;
revoke all on public.repair_orders, public.repair_events, public.repair_media, public.repair_documents, public.repair_approvals, public.repair_messages, public.notification_outbox from anon, authenticated;
-- Required before deployment: server-enforced staff membership and store scope,
-- signed customer decisions, immutable event audit, secure storage, notification worker,
-- order-number sequence, state-machine transition function and integration tests.
