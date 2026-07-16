CREATE OR REPLACE FUNCTION public.admin_add_funds_by_email(p_email text, p_amount numeric)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_user_id uuid;
BEGIN
  -- 1. التأكد من أن المبلغ أكبر من صفر
  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'المبلغ يجب أن يكون أكبر من صفر';
  END IF;

  -- 2. البحث عن المستخدم بواسطة البريد الإلكتروني في جدول auth.users
  SELECT id INTO target_user_id
  FROM auth.users
  WHERE email = p_email;

  -- إذا لم يتم العثور على المستخدم
  IF target_user_id IS NULL THEN
    RAISE EXCEPTION 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني: %', p_email;
  END IF;

  -- 3. تحديث رصيد المحفظة في جدول profiles
  UPDATE public.profiles
  SET wallet_balance = COALESCE(wallet_balance, 0) + p_amount
  WHERE id = target_user_id;

  -- 4. تسجيل العملية في جدول المعاملات المالية (لتظهر للمستخدم في التطبيق)
  INSERT INTO public.wallet_transactions (user_id, amount, type, description, created_at)
  VALUES (target_user_id, p_amount, 'credit', 'شحن رصيد من الإدارة', now());

END;
$$;
