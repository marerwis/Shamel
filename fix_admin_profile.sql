-- هذا السكربت يقوم بإنشاء ملف شخصي (Profile) لحساب الأدمن الخاص بك
-- في جدول profiles، لأن قاعدة البيانات ترفض إضافة خدمة بدون أن يكون
-- منشئ الخدمة موجوداً في جدول profiles (حسب قيد services_provider_id_fkey).

INSERT INTO public.profiles (id, full_name)
SELECT id, 'Admin User'
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);
