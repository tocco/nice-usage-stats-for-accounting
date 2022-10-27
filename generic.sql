SELECT
  -- interface languages
  (SELECT count(*) FROM nice_interface_language) AS "interface langs",

  -- correcspondence languages
  (SELECT count(*) FROM nice_correspondence_language) AS "corresp. langs",

  -- business units
  (SELECT count(*) FROM nice_business_unit) AS "BUs",

  -- DMS domains (external)
  (SELECT COUNT(*) FROM nice_domain AS d LEFT OUTER JOIN nice_domain_type AS dt ON d.fk_domain_type = dt.pk WHERE dt.unique_id = 'public_file_repository') AS "DMS domains external",

  -- DMS domains (internal)
  (SELECT COUNT(*) FROM nice_domain AS d LEFT OUTER JOIN nice_domain_type AS dt ON d.fk_domain_type = dt.pk WHERE dt.unique_id = 'internal_file_repository') AS "DMS domains internal",

  -- admin users
  --
  -- This includes all users (nice_user) that are linked to an active login with a role of type 'manager. As exception,
  -- users associated with an @tocco.ch email address are ignored.
  --
  (SELECT
     COUNT(DISTINCT u.pk)
   FROM
     nice_user AS u
     LEFT OUTER JOIN
     nice_principal AS p ON u.pk = p.fk_user
     LEFT OUTER JOIN
     nice_login_role AS l ON p.pk = l.fk_principal
     LEFT OUTER JOIN
     nice_role AS r ON l.fk_role = r.pk
     LEFT OUTER JOIN
     nice_role_type AS t ON r.fk_role_type = t.pk
     LEFT OUTER JOIN
     nice_principal_status AS s ON p.fk_principal_status = s.pk
   WHERE
     t.unique_id = 'manager' AND s.unique_id = 'active'
       AND u.email NOT LIKE '%@tocco.ch'
  ) AS "admins",

  -- outgoing mails per month averaged over the last 12 months (if possible)
  --
  -- • For simplicity a year is assumed to be 360 days and a month 30 days.
  -- • If the first mail ever sent has been sent less than 12 months ago, the time span since the first mail
  --   is used to calculate a monthly average. The result is extrapolated if necessary.
  --
  (SELECT
     (COUNT(*)
      -- time since first mail has been sent, clamped at 360 days.
      / extract(EPOCH FROM (SELECT least(interval '360d', max(now() - timestamp)) FROM nice_email_archive))
      -- 30 days in seconds
      * 2592000)::int
   FROM
     nice_email_archive AS ea
   WHERE
     ea.timestamp >= now() - interval '360d'
     AND original_mail = '' -- left blank on outgoing mail
  ) AS "mails per month";
