-- Remove all pending family invites created by the current user (no direct SELECT on family_invites for clients).

CREATE OR REPLACE FUNCTION public.cancel_all_my_family_invites()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  DELETE FROM public.family_invites WHERE created_by = auth.uid();
END;
$$;

REVOKE ALL ON FUNCTION public.cancel_all_my_family_invites() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cancel_all_my_family_invites() TO authenticated;
