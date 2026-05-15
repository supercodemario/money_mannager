-- Household owner role + RPC for owner-invited members (add via scanned invite QR).

-- Restrict role values
ALTER TABLE public.household_members DROP CONSTRAINT IF EXISTS household_members_role_check;
ALTER TABLE public.household_members
  ADD CONSTRAINT household_members_role_check CHECK (role IN ('owner', 'member'));

-- Exactly one owner per household for existing rows: lowest user_id lexicographically wins.
WITH ranked AS (
  SELECT
    household_id,
    user_id,
    ROW_NUMBER() OVER (PARTITION BY household_id ORDER BY user_id) AS rn
  FROM public.household_members
)
UPDATE public.household_members hm
SET role = 'owner'
FROM ranked r
WHERE hm.household_id = r.household_id
  AND hm.user_id = r.user_id
  AND r.rn = 1;

-- Owner adds another auth user to their household (SECURITY DEFINER bypasses RLS insert limits).
CREATE OR REPLACE FUNCTION public.add_household_member_as_owner(
  p_household_id uuid,
  p_invitee_user_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.household_members hm
    WHERE hm.household_id = p_household_id
      AND hm.user_id = auth.uid()
      AND hm.role = 'owner'
  ) THEN
    RAISE EXCEPTION 'not_owner';
  END IF;

  IF p_invitee_user_id = auth.uid() THEN
    RAISE EXCEPTION 'cannot_invite_self';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.household_members
    WHERE household_id = p_household_id
      AND user_id = p_invitee_user_id
  ) THEN
    RAISE EXCEPTION 'already_member';
  END IF;

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES (p_household_id, p_invitee_user_id, 'member');
END;
$$;

REVOKE ALL ON FUNCTION public.add_household_member_as_owner(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.add_household_member_as_owner(uuid, uuid) TO authenticated;
