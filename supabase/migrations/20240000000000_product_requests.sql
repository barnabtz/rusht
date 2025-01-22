-- Create product requests table
create table public.product_requests (
    id uuid not null default uuid_generate_v4(),
    requester_id uuid references auth.users not null,
    title text not null,
    description text not null,
    category text not null,
    budget_min decimal(10,2) not null,
    budget_max decimal(10,2) not null,
    needed_by timestamp with time zone not null,
    created_at timestamp with time zone not null default now(),
    status text not null default 'open',
    images text[] not null default '{}',
    response_count integer not null default 0,
    
    constraint product_requests_pkey primary key (id),
    constraint product_requests_budget_check check (budget_max > budget_min),
    constraint product_requests_needed_by_check check (needed_by > created_at),
    constraint product_requests_status_check check (status in ('open', 'fulfilled', 'expired'))
);

-- Add RLS policies
alter table public.product_requests enable row level security;

create policy "Anyone can view product requests"
    on public.product_requests for select
    using (true);

create policy "Users can create their own requests"
    on public.product_requests for insert
    with check (auth.uid() = requester_id);

create policy "Users can update their own requests"
    on public.product_requests for update
    using (auth.uid() = requester_id);

create policy "Users can delete their own requests"
    on public.product_requests for delete
    using (auth.uid() = requester_id);

-- Create function to automatically expire requests
create or replace function public.expire_old_requests()
returns trigger
language plpgsql
security definer
as $$
begin
    update public.product_requests
    set status = 'expired'
    where status = 'open'
    and needed_by < now();
    return null;
end;
$$;

-- Create trigger to run expire_old_requests function every hour
create trigger expire_old_requests_trigger
    after insert or update
    on public.product_requests
    execute function public.expire_old_requests();
