-- 1. التأكد من أن نوع (ENUM) يحتوي على جميع الأدوار المطلوبة
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'user';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'customer';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'provider';

-- 2. إنشاء وظيفة (Function) التعامل مع العضو الجديد بقوة وتجنب الأخطاء
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  assigned_role public.user_role;
BEGIN
  -- تحديد نوع الحساب بشكل آمن لتفادي أخطاء التحويل (Cast Errors)
  BEGIN
    assigned_role := (COALESCE(NEW.raw_user_meta_data->>'role', 'customer'))::public.user_role;
  EXCEPTION WHEN OTHERS THEN
    assigned_role := 'customer'::public.user_role;
  END;

  -- الإدراج في جدول profiles
  INSERT INTO public.profiles (id, full_name, role, status)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email, 'مستخدم جديد'),
    assigned_role,
    CASE 
      WHEN assigned_role = 'provider' THEN 'pending'
      ELSE 'active'
    END
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role;
    
  -- إذا كان مزود خدمة، قم بالإدراج في جدول تفاصيل المزود (provider_details)
  IF assigned_role = 'provider' THEN
    INSERT INTO public.provider_details (
      id, 
      father_name, 
      grandfather_name, 
      id_type, 
      id_number, 
      category_id, 
      title
    ) VALUES (
      NEW.id,
      NEW.raw_user_meta_data->>'father_name',
      NEW.raw_user_meta_data->>'grandfather_name',
      NEW.raw_user_meta_data->>'id_type',
      NEW.raw_user_meta_data->>'id_number',
      NULLIF(NEW.raw_user_meta_data->>'category_id', '')::uuid,
      NEW.raw_user_meta_data->>'title'
    )
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. حذف أي Triggers قديمة لتفادي التكرار
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS create_profile_on_signup ON auth.users;

-- 4. إنشاء الـ Trigger النهائي والجذري ليعمل فور إضافة مستخدم جديد
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
