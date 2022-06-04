\echo  Hi, I am running script 1

select * from lysglb.mpy;

\echo  changing description
update lysglb.mpy set description = 'MY DESCRIPTION';

\echo  new file
select * from lysglb.mpy
