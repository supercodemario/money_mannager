-- Personal household support + default expense scope foundations.
-- Keeps expenses household-scoped while ensuring every authenticated user can
-- resolve at least one household id for sync.

ALTER TABLE public.households
  ADD COLUMN IF NOT EXISTS kind text NOT NULL DEFAULT 'shared';

ALTER TABLE public.households
  DROP CONSTRAINT IF EXISTS households_kind_check;

ALTER TABLE public.households
  ADD CONSTRAINT households_kind_check
  CHECK (kind IN ('shared', 'personal'));

CREATE OR REPLACE FUNCTION public.ensure_personal_household()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_household_id uuid;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT h.id
    INTO v_household_id
    FROM public.households h
    JOIN public.household_members hm
      ON hm.household_id = h.id
   WHERE hm.user_id = v_uid
     AND hm.role = 'owner'
     AND h.kind = 'personal'
   LIMIT 1;

  IF v_household_id IS NOT NULL THEN
    RETURN v_household_id;
  END IF;

  INSERT INTO public.households (name, kind)
  VALUES ('Self', 'personal')
  RETURNING id INTO v_household_id;

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES (v_household_id, v_uid, 'owner');

  RETURN v_household_id;
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_personal_household() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_personal_household() TO authenticated;

-- Backfill personal households for existing auth users.
DO $$
DECLARE
  u record;
  v_household_id uuid;
BEGIN
  FOR u IN SELECT id FROM auth.users LOOP
    SELECT h.id
      INTO v_household_id
      FROM public.households h
      JOIN public.household_members hm
        ON hm.household_id = h.id
     WHERE hm.user_id = u.id
       AND hm.role = 'owner'
       AND h.kind = 'personal'
     LIMIT 1;

    IF v_household_id IS NULL THEN
      INSERT INTO public.households (name, kind)
      VALUES ('Self', 'personal')
      RETURNING id INTO v_household_id;

      INSERT INTO public.household_members (household_id, user_id, role)
      VALUES (v_household_id, u.id, 'owner');
    END IF;
  END LOOP;
END;
$$;

-- Users cannot self-join someone else's personal household.
DROP POLICY IF EXISTS household_members_insert_self ON public.household_members;
CREATE POLICY household_members_insert_self
  ON public.household_members FOR insert
  WITH CHECK (
    user_id = auth.uid()
    AND NOT EXISTS (
      SELECT 1
      FROM public.households h
      WHERE h.id = household_id
        AND h.kind = 'personal'
    )
  );

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

  IF EXISTS (
    SELECT 1
    FROM public.households h
    WHERE h.id = p_household_id
      AND h.kind = 'personal'
  ) THEN
    RAISE EXCEPTION 'personal_household_not_shareable';
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

CREATE OR REPLACE FUNCTION public.accept_family_invite(p_household_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  inv public.family_invites%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO inv
  FROM public.family_invites
  WHERE id = p_household_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invite_not_found';
  END IF;

  IF inv.created_by = auth.uid() THEN
    RAISE EXCEPTION 'cannot_accept_own_invite';
  END IF;

  IF EXISTS (SELECT 1 FROM public.households WHERE id = p_household_id) THEN
    RAISE EXCEPTION 'household_exists';
  END IF;

  INSERT INTO public.households (id, name, kind)
  VALUES (p_household_id, inv.display_name, 'shared');

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES
    (p_household_id, inv.created_by, 'owner'),
    (p_household_id, auth.uid(), 'member');

  DELETE FROM public.family_invites WHERE id = p_household_id;
END;
$$;
