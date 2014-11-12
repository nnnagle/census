
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
                   