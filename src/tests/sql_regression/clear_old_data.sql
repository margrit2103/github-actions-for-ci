--- db_schema database has old transactions at time of booking in this script.
--- This script deletes the old data.
---   THIS SCRIPT SHOULD ALWAYS BE CALLED MANUALLY BY A RESPONSIBLE PARTY, AND NEVER AT A LIVE SITE !!!!


TRUNCATE lysglb.ldgr_movement CASCADE;
TRUNCATE lysglb.deboop CASCADE;
TRUNCATE lysglb.debfopen CASCADE;
TRUNCATE lysglb.debfdetail CASCADE;
TRUNCATE lysglb.cashoop CASCADE;
TRUNCATE lysglb.creopen CASCADE;
TRUNCATE lysglb.cashoop CASCADE;
TRUNCATE lysglb.debftrans CASCADE;
DO
$$
DECLARE arec record;
BEGIN
 FOR arec IN SELECT format( 'TRUNCATE %s.%s ', table_schema, table_name ) AS instr  FROM information_schema.TABLES WHERE table_schema LIKE 'year%' AND table_type = 'BASE TABLE' 
 LOOP
    EXECUTE arec.instr;
 END LOOP;
END;
$$
LANGUAGE plpgsql;      

SELECT utility.if_then_else( $$SELECT count(*) = 1 FROM pg_tables WHERE tablename= 'cf_primary'$$,
'
TRUNCATE analysis.cf_primary CASCADE;
TRUNCATE analysis.cf_contra;
TRUNCATE analysis.to_deb_primary CASCADE;
TRUNCATE analysis.to_deb_contra;
TRUNCATE analysis.to_cre_primary CASCADE;
TRUNCATE analysis.to_cre_contra;
TRUNCATE analysis.jnl;
',
'' );

