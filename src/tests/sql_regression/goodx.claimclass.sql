\echo Claim class test

\echo Parameters: This test assumes that a goodx1 directory exists. 

\echo Make sure that no claimclass tables are left
select count(*) from pg_tables where tablename = 'claimclass';

\echo Insert
WITH _insert  AS( INSERT INTO goodx1.claimclass( description, beskrywing,inhouse, outhouse ) VALUES(  'english', 'afrikaans', 'IH', 'OH') returning mainid,description, beskrywing, inhouse, outhouse, entity_uid )
SELECT set_config('test.mainid', mainid::TEXT, FALSE ) <> '' as _, description, beskrywing, inhouse, outhouse, entity_uid FROM _insert;

\echo  Update 
UPDATE goodx1.claimclass SET ( description, beskrywing,inhouse, outhouse ) = (  'DESCRIPTION', 'BESRYWING', 'IH_v2', 'OH_v2') WHERE mainid = current_setting( 'test.mainid' )::INTEGER;
SELECT description, beskrywing, inhouse, outhouse, entity_uid FROM goodx1.claimclass WHERE mainid = current_setting( 'test.mainid' )::INTEGER;

