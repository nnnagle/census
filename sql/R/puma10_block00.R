sql.loc <- '/usr/local/pgsql-9.3/bin/'

system(sprintf('%spsql -U postgres -d tiger -c "DROP TABLE IF EXISTS puma10_block00"', 
               sql.loc))

sql.cmd <- sprintf('
CREATE TABLE puma10_block00(
  gid serial primary key,
  block00_statefp00 varchar,
  block00_countyfp00 varchar,
  block00_geoid varchar,
  puma10_geoid varchar,
  isect_area numeric
);
')
system(sprintf('%spsql -U postgres -d tiger -c "%s"', 
               sql.loc, sql.cmd))



sql.cmd <- sprintf("
INSERT INTO puma10_block00(block00_statefp00, block00_countyfp00, block00_geoid,puma10_geoid, isect_area)
  SELECT
    a.statefp00 AS block00_statefp00,
    a.countyfp00 AS block00_countyfp00,
    a.blkidfp00 AS block00_geoid,
    b.geoid10 AS puma10_geoid,
    CASE 
      WHEN ST_Within(a.geom,b.geom) 
      THEN ST_Area(ST_Transform(a.geom, 2163))
      ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 2163))
    END AS isect_area
  FROM tabblock00 a
  JOIN puma10 b
    ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
  WHERE a.statefp00 NOT IN ('02', '15');
")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d tiger -f run.sql', 
               sql.loc, sql.cmd))



#############################################################################
# Repeat for Alaska using srid:3338
sql.cmd <- sprintf("
INSERT INTO puma10_block00(block00_statefp00, block00_countyfp00, block00_geoid,puma10_geoid, isect_area)
  SELECT
    a.statefp00 AS block00_statefp00,
    a.countyfp00 AS block00_countyfp00,
    a.blkidfp00 AS block00_geoid,
    b.geoid10 AS puma10_geoid,
    CASE 
      WHEN ST_Within(a.geom,b.geom) 
      THEN ST_Area(ST_Transform(a.geom, 3338))
      ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 3338))
    END AS isect_area
  FROM tabblock00 a
  JOIN puma10 b
    ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
  WHERE a.statefp00 = '02';
")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d tiger -f run.sql', 
               sql.loc, sql.cmd))


#############################################################################
# Repeat for Hawii using ESRI:102007 srid:102007
sql.cmd <- sprintf("
INSERT INTO puma10_block00(block00_statefp00, block00_countyfp00, block00_geoid,puma10_geoid, isect_area)
  SELECT
    a.statefp00 AS block00_statefp00,
    a.countyfp00 AS block00_countyfp00,
    a.blkidfp00 AS block00_geoid,
    b.geoid10 AS puma10_geoid,
    CASE 
      WHEN ST_Within(a.geom,b.geom) 
      THEN ST_Area(ST_Transform(a.geom, 102007))
      ELSE ST_Area(ST_Transform(ST_Multi(ST_Intersection(a.geom,b.geom)), 102007))
    END AS isect_area
  FROM tabblock00 a
  JOIN puma10 b
    ON (ST_Intersects(a.geom, b.geom) AND NOT ST_Touches(a.geom, b.geom))
  WHERE a.statefp00 = '15';
")
cat(sql.cmd, file='run.sql')
system(sprintf('%spsql -U postgres -d tiger -f run.sql', 
               sql.loc, sql.cmd))



