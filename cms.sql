-- web domains in use
--
-- • only domains of type 'web' are considered
-- • it doesn't matter which permissions are set
-- • at least five pages must have set permissions within the same domain
-- • login page must be set (NOT NULL)
SELECT
  count(*) AS "web domains in use"
FROM (
       SELECT
         count(distinct nr.fk_page)
       FROM
         nice_page AS p
         LEFT OUTER JOIN
         nice_domain AS d ON p.fk_domain_shortcut = d.pk
         LEFT OUTER JOIN
         nice_domain_type AS dt ON d.fk_domain_type = dt.pk
         LEFT OUTER JOIN
         nice_node_right AS nr ON p.pk = nr.fk_page
       WHERE
         dt.unique_id = 'web'
         AND d.fk_login_page IS NOT NULL
         AND (SELECT count(*) FROM nice_node_permission WHERE pk = nr.fk_node_permission) > 0
       GROUP BY
         d.pk
       HAVING
         count(distinct nr.fk_page) >= 5
     ) AS "inner";
