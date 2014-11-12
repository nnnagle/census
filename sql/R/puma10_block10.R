sql.loc <- '/usr/local/pgsql-9.3/bin/'

system(sprintf('%spsql -U postgres -d census -c "DROP TABLE IF EXISTS puma10_block10"', 
               sql.loc))

sql.cmd <- sprintf('
                   CREATE TABLE puma10_block10(
                   gid serial primary key,
                   block10_statefp10 varchar,
                   block10_countyfp10 varchar,
                   block10_geoid varchar,
                   puma10_geoid varchar,
                   isect_area numeric
                   );
                   ')
system(sprintf('%spsql -U postgres -d census -c "%s"', 
               sql.loc, sql.cmd))



sql.cmd <- sprintf("
                   INSERT INTO puma10_block10(block10_statefp10, block10_countyfp10, block10_geoid,puma10_geoid, isect_area)
                   SELECT
                   a.statefp10 AS block10_statefp10,
                   a.countyfp10 AS block10_countyfp10,
                   a.geoid10 AS block10_geoid,
                   b.geoid10 AS puma10_geoid,
                   CASE 
                   WHEN ST_Within(a.geom,b.geom) 
                   THEN ST_Area(ST_Transform(a.geom, 2163))
                   ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 2163))
                   END AS isect_area
                   FROM tabblock10 a
                   JOIN puma10 b
                   ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
                   WHERE a.statefp10 NOT IN ('02', '15');
                   ")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d census -f run.sql', 
               sql.loc, sql.cmd))



#############################################################################
# Repeat for Alaska using srid:3338
sql.cmd <- sprintf("
                   INSERT INTO puma10_block10(block10_statefp10, block10_countyfp10, block10_geoid,puma10_geoid, isect_area)
                   SELECT
                   a.statefp10 AS block10_statefp10,
                   a.countyfp10 AS block10_countyfp10,
                   a.geoid10 AS block10_geoid,
                   b.geoid10 AS puma10_geoid,
                   CASE 
                   WHEN ST_Within(a.geom,b.geom) 
                   THEN ST_Area(ST_Transform(a.geom, 3338))
                   ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 3338))
                   END AS isect_area
                   FROM tabblock10 a
                   JOIN puma10 b
                   ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
                   WHERE a.statefp10 = '02';
                   ")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d census -f run.sql', 
               sql.loc, sql.cmd))


#############################################################################
# Repeat for Hawii using ESRI:102007 srid:102007
sql.cmd <- sprintf("
                   INSERT INTO puma10_block10(block10_statefp10, block10_countyfp10, block10_geoid,puma10_geoid, isect_area)
                   SELECT
                   a.statefp10 AS block10_statefp10,
                   a.countyfp10 AS block10_countyfp10,
                   a.geoid10 AS block10_geoid,
                   b.geoid10 AS puma10_geoid,
                   CASE 
                   WHEN ST_Within(a.geom,b.geom) 
                   THEN ST_Area(ST_Transform(a.geom, 102007))
                   ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 102007))
                   END AS isect_area
                   FROM tabblock10 a
                   JOIN puma10 b
                   ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
                   WHERE a.statefp10 = '15';
                   ")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d census -f run.sql', 
               sql.loc, sql.cmd))




