-- ============================================================
-- Epic 15: Fix RLS Policies + Enable Realtime for all tables
-- نفّذ هذا الملف كاملاً في SQL Editor في Supabase
-- ============================================================

-- ============================================================
-- STEP 1: Enable Realtime on the required tables
-- (تفعيل البث المباشر على الجداول المطلوبة)
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.requests;
ALTER PUBLICATION supabase_realtime ADD TABLE public.wallets;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;


-- ============================================================
-- STEP 2: Fix RLS Policies for "orders" table
-- ============================================================

-- حذف السياسات القديمة إن وجدت لتجنب التعارض
DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Providers can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert orders" ON public.orders;
DROP POLICY IF EXISTS "Users and providers can update orders" ON public.orders;
DROP POLICY IF EXISTS "Allow realtime for orders" ON public.orders;

-- تفعيل RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- السماح للمستخدم برؤية طلباته (كعميل أو كمزود)
CREATE POLICY "Users can view own orders"
ON public.orders
FOR SELECT
USING (
  auth.uid() = user_id OR auth.uid() = provider_id
);

-- السماح للمستخدم بإنشاء طلب
CREATE POLICY "Users can insert orders"
ON public.orders
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- السماح بتحديث الطلبات (للعميل أو المزود)
CREATE POLICY "Users and providers can update orders"
ON public.orders
FOR UPDATE
USING (auth.uid() = user_id OR auth.uid() = provider_id);


-- ============================================================
-- STEP 3: Fix RLS Policies for "requests" table
-- ============================================================
DROP POLICY IF EXISTS "Users can view own requests" ON public.requests;
DROP POLICY IF EXISTS "Users can insert requests" ON public.requests;
DROP POLICY IF EXISTS "Providers can view broadcast requests" ON public.requests;
DROP POLICY IF EXISTS "Allow realtime for requests" ON public.requests;

ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

-- العميل يرى طلباته فقط
CREATE POLICY "Users can view own requests"
ON public.requests
FOR SELECT
USING (auth.uid() = user_id);

-- العميل يستطيع إنشاء طلب
CREATE POLICY "Users can insert requests"
ON public.requests
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- العميل يستطيع تعديل طلبه
CREATE POLICY "Users can update own requests"
ON public.requests
FOR UPDATE
USING (auth.uid() = user_id);

-- المزود يرى الطلبات المتاحة للعطاء (Pending_Broadcast)
CREATE POLICY "Providers can view broadcast requests"
ON public.requests
FOR SELECT
USING (
  status = 'Pending_Broadcast' AND auth.role() = 'authenticated'
);


-- ============================================================
-- STEP 4: Fix RLS Policies for "wallets" table
-- ============================================================
DROP POLICY IF EXISTS "Users can view own wallet" ON public.wallets;
DROP POLICY IF EXISTS "Users can update own wallet" ON public.wallets;

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

-- المستخدم يرى محفظته فقط
CREATE POLICY "Users can view own wallet"
ON public.wallets
FOR SELECT
USING (auth.uid() = user_id);

-- المستخدم يستطيع تحديث محفظته
CREATE POLICY "Users can update own wallet"
ON public.wallets
FOR UPDATE
USING (auth.uid() = user_id);

-- السماح للدوال الداخلية بتحديث المحفظة (SECURITY DEFINER functions)
CREATE POLICY "Service role can manage wallets"
ON public.wallets
FOR ALL
USING (auth.role() = 'service_role');


-- ============================================================
-- STEP 5: Fix RLS Policies for "notifications" table
-- ============================================================
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- المستخدم يرى إشعاراته فقط
CREATE POLICY "Users can view own notifications"
ON public.notifications
FOR SELECT
USING (auth.uid() = user_id);

-- المستخدم يستطيع تعديل إشعاراته (قراءة/حذف)
CREATE POLICY "Users can update own notifications"
ON public.notifications
FOR UPDATE
USING (auth.uid() = user_id);

-- السماح للدوال بإدراج الإشعارات
CREATE POLICY "Service role can insert notifications"
ON public.notifications
FOR INSERT
WITH CHECK (auth.role() = 'authenticated' OR auth.role() = 'service_role');


-- ============================================================
-- STEP 6: Fix RLS for "wallet_transactions" table
-- ============================================================
DROP POLICY IF EXISTS "Users can view own transactions" ON public.wallet_transactions;

ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
ON public.wallet_transactions
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage transactions"
ON public.wallet_transactions
FOR ALL
USING (auth.role() = 'service_role');


-- ============================================================
-- التحقق من نجاح العملية
-- يجب أن تظهر لك قائمة بالسياسات المضافة
-- ============================================================
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('orders', 'requests', 'wallets', 'notifications', 'wallet_transactions')
ORDER BY tablename, policyname;
