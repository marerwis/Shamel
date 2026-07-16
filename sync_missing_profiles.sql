-- هذا السكربت يقوم بمزامنة وإضافة أي عضو تم تسجيله سابقاً ولم يظهر في صفحة الأعضاء
-- يحدث هذا عادة إذا تم التسجيل قبل إصلاح الـ (Database Triggers)
-- أو إذا تم إنشاء العضو يدوياً من واجهة Authentication

INSERT INTO public.profiles (id, full_name, role, status, created_at)
SELECT 
  id, 
  COALESCE(raw_user_meta_data->>'full_name', email, 'عضو غير معروف'), 
  (COALESCE(raw_user_meta_data->>'role', 'customer'))::user_role,
  'active',
  created_at
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);
