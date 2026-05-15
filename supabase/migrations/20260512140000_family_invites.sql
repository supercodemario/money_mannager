-- Pending "create family" invites: household row is created only when another user accepts.

CREATE TABLE public.family_invites (
  id uuid PRIMARY KEY,
  display_name text NOT NULL,
  created_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT family_invites_display_name_nonempty CHECK (length(trim(display_name)) > 0)
);

ALTER TABLE public.family_invites ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.family_invites FROM PUBLIC;
REVOKE ALL ON TABLE public.family_invites FROM anon, authenticated;

-- Creator registers a future household id + name (no [households] row yet).
CREATE OR REPLACE FUNCTION public.register_family_invite(
  p_id uuid,
  p_display_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  n text := trim(p_display_name);
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF length(n) = 0 THEN
    RAISE EXCEPTION 'invalid_display_name';
  END IF;
  IF EXISTS (SELECT 1 FROM public.households WHERE id = p_id) THEN
    RAISE EXCEPTION 'household_id_taken';
  END IF;
  IF EXISTS (SELECT 1 FROM public.family_invites WHERE id = p_id) THEN
    RAISE EXCEPTION 'invite_id_taken';
  END IF;
  INSERT INTO public.family_invites (id, display_name, created_by)
  VALUES (p_id, n, auth.uid());
END;
$$;

CREATE OR REPLACE FUNCTION public.update_family_invite_name(
  p_id uuid,
  p_display_name text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  n text := trim(p_display_name);
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF length(n) = 0 THEN
    RAISE EXCEPTION 'invalid_display_name';
  END IF;
  UPDATE public.family_invites
  SET display_name = n
  WHERE id = p_id
    AND created_by = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'invite_not_found';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_family_invite(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  DELETE FROM public.family_invites
  WHERE id = p_id
    AND created_by = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'invite_not_found';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_family_invite_preview(p_household_id uuid)
RETURNS TABLE (display_name text, creator_id uuid)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT fi.display_name, fi.created_by
  FROM public.family_invites fi
  WHERE fi.id = p_household_id;
$$;

-- Second member accepts: creates [households] + both [household_members], removes invite.
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

  INSERT INTO public.households (id, name)
  VALUES (p_household_id, inv.display_name);

  INSERT INTO public.household_members (household_id, user_id, role)
  VALUES
    (p_household_id, inv.created_by, 'owner'),
    (p_household_id, auth.uid(), 'member');

  DELETE FROM public.family_invites WHERE id = p_household_id;
END;
$$;

REVOKE ALL ON FUNCTION public.register_family_invite(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.register_family_invite(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.update_family_invite_name(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.update_family_invite_name(uuid, text) TO authenticated;

REVOKE ALL ON FUNCTION public.cancel_family_invite(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cancel_family_invite(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.get_family_invite_preview(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_family_invite_preview(uuid) TO authenticated;

REVOKE ALL ON FUNCTION public.accept_family_invite(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.accept_family_invite(uuid) TO authenticated;
