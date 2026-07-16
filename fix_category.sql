
CREATE OR REPLACE FUNCTION set_request_root_category()
RETURNS TRIGGER AS $BODY
DECLARE
  v_parent_id UUID;
  v_current_id UUID;
BEGIN
  v_current_id := NEW.category_id;
  
  LOOP
    SELECT parent_id INTO v_parent_id FROM public.categories WHERE id = v_current_id;
    IF v_parent_id IS NULL THEN
      EXIT;
    END IF;
    v_current_id := v_parent_id;
  END LOOP;
  
  NEW.category_id := v_current_id;
  RETURN NEW;
END;
$BODY LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_request_root_category ON public.requests;
CREATE TRIGGER trg_set_request_root_category
BEFORE INSERT ON public.requests
FOR EACH ROW
EXECUTE FUNCTION set_request_root_category();

UPDATE public.requests r
SET category_id = (
  WITH RECURSIVE cat_tree AS (
    SELECT id, parent_id FROM public.categories WHERE id = r.category_id
    UNION ALL
    SELECT c.id, c.parent_id FROM public.categories c
    INNER JOIN cat_tree ct ON ct.parent_id = c.id
  )
  SELECT id FROM cat_tree WHERE parent_id IS NULL LIMIT 1
)
WHERE status = 'Pending_Broadcast';

