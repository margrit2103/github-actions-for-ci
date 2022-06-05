\echo Check that virtual fields are not defined for inserting / updating
SELECT * FROM analysis.meta_data_all_inconsistent_insert_update_validation();

\echo Check that virtual fields are not pointing to an invalid table
select * from analysis.meta_data_pointers_to_wrong_table( 'to_deb_primary', ARRAY['to_deb_primary', 'to_deb_contra', 'to_cre_primary', 'to_cre_contra', 'cf_primary', 'cf_contra', 'jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'to_deb_contra',  ARRAY[                  'to_deb_contra', 'to_cre_primary', 'to_cre_contra', 'cf_primary', 'cf_contra', 'jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'to_cre_primary', ARRAY['to_deb_primary', 'to_deb_contra', 'to_cre_primary', 'to_cre_contra', 'cf_primary', 'cf_contra', 'jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'to_cre_contra',  ARRAY['to_deb_primary', 'to_deb_contra',                   'to_cre_contra', 'cf_primary', 'cf_contra', 'jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'cf_primary',     ARRAY['to_deb_primary', 'to_deb_contra', 'to_cre_primary', 'to_cre_contra',               'cf_contra', 'jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'cf_contra',      ARRAY['to_deb_primary', 'to_deb_contra', 'to_cre_primary', 'to_cre_contra',               'cf_contra','jnl'])
union
select * from analysis.meta_data_pointers_to_wrong_table( 'jnl',            ARRAY['to_deb_primary', 'to_deb_contra', 'to_cre_primary', 'to_cre_contra', 'cf_primary', 'cf_contra'  ])
