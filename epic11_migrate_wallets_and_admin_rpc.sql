-- Epic 11: Fix Wallet Balances & Admin Panel RPC

-- 1. إعادة بناء الرصيد من جدول المعاملات (wallet_transactions) بشكل محكم
-- سيقوم هذا السكريبت باحتساب الصافي الدقيق لكل مستخدم ووضعه في جدول المحفظة (سواء كان موجباً، صفراً، أو سالباً)
INSERT INTO public.wallets (user_id, balance)
SELECT 
    user_id,
    COALESCE(SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END), 0) - 
    COALESCE(SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END), 0) as calculated_balance
FROM public.wallet_transactions
GROUP BY user_id
ON CONFLICT (user_id) DO UPDATE
SET balance = EXCLUDED.balance;

-- 3. تحديث دالة شحن الرصيد من لوحة التحكم (Admin Panel)
CREATE OR REPLACE FUNCTION public.admin_add_funds_by_email(
  p_email text,
  p_amount numeric
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- جلب رقم المستخدم من الإيميل
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = p_email
  LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'المستخدم غير موجود';
  END IF;

  -- إضافة المبلغ إلى جدول المحافظ (wallets)
  UPDATE public.wallets
  SET balance = COALESCE(balance, 0) + p_amount
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    INSERT INTO public.wallets (user_id, balance) VALUES (v_user_id, p_amount);
  END IF;

  -- تسجيل المعاملة في السجل
  INSERT INTO public.wallet_transactions (user_id, amount, transaction_type, description, created_at)
  VALUES (v_user_id, p_amount, 'credit', 'شحن رصيد من قبل الإدارة', now());
END;
$$;
