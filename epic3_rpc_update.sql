-- RPC to Release Milestone Payment
CREATE OR REPLACE FUNCTION release_milestone_payment(
    p_milestone_id UUID,
    p_order_id UUID,
    p_amount NUMERIC,
    p_provider_id UUID
)
RETURNS VOID AS $$
BEGIN
    -- 1. Check if milestone is already paid
    IF EXISTS (SELECT 1 FROM public.order_milestones WHERE id = p_milestone_id AND status = 'Paid') THEN
        RAISE EXCEPTION 'هذه الدفعة تم سدادها مسبقاً.';
    END IF;

    -- 2. Mark milestone as Paid
    UPDATE public.order_milestones SET status = 'Paid' WHERE id = p_milestone_id;

    -- 3. Update customer's pending balance
    UPDATE public.wallets
    SET pending_balance = pending_balance - p_amount
    WHERE user_id = (SELECT customer_id FROM public.orders WHERE id = p_order_id);

    -- 4. Create Wallet for provider if not exists, then add balance
    INSERT INTO public.wallets (user_id, balance, pending_balance)
    VALUES (p_provider_id, p_amount, 0.0)
    ON CONFLICT (user_id) 
    DO UPDATE SET balance = public.wallets.balance + EXCLUDED.balance;

    -- 5. Release from escrow transactions (optional: just mark a portion as released, or insert a log)
    INSERT INTO public.escrow_transactions (order_id, amount, status)
    VALUES (p_order_id, p_amount, 'Released');

    -- 6. If all milestones are Paid, mark Order as Completed
    IF NOT EXISTS (SELECT 1 FROM public.order_milestones WHERE order_id = p_order_id AND status = 'Pending') THEN
        UPDATE public.orders SET status = 'Completed' WHERE id = p_order_id;
    END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
