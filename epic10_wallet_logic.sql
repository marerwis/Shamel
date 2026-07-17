-- Epic 10: Wallet Logic for Delivery App Pivot

CREATE OR REPLACE FUNCTION public.process_wallet_transaction(
  p_user_id uuid,
  p_amount numeric,
  p_type text,
  p_description text,
  p_order_id uuid DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_balance numeric;
BEGIN
  -- 1. التأكد من أن المبلغ أكبر من صفر
  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'المبلغ يجب أن يكون أكبر من صفر';
  END IF;

  -- 2. التحقق من الرصيد الحالي للمستخدم في حالة الخصم (debit)
  IF p_type = 'debit' THEN
    SELECT wallet_balance INTO v_current_balance
    FROM public.profiles
    WHERE id = p_user_id;

    IF v_current_balance IS NULL OR v_current_balance < p_amount THEN
      RAISE EXCEPTION 'الرصيد غير كافٍ. رصيدك الحالي: %', COALESCE(v_current_balance, 0);
    END IF;

    -- خصم المبلغ
    UPDATE public.profiles
    SET wallet_balance = COALESCE(wallet_balance, 0) - p_amount
    WHERE id = p_user_id;

  ELSIF p_type = 'credit' THEN
    -- إضافة المبلغ
    UPDATE public.profiles
    SET wallet_balance = COALESCE(wallet_balance, 0) + p_amount
    WHERE id = p_user_id;

  ELSE
    RAISE EXCEPTION 'نوع المعاملة غير صالح. استخدم credit أو debit';
  END IF;

  -- 3. تسجيل العملية في جدول المعاملات المالية
  INSERT INTO public.wallet_transactions (user_id, amount, type, description, order_id, created_at)
  VALUES (p_user_id, p_amount, p_type, p_description, p_order_id, now());

END;
$$;
