-- Canary fixture: SQL migration lacking Row Level Security.
-- Triggers Snip BrokenRLS (High).

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    balance NUMERIC NOT NULL DEFAULT 0.00
);
