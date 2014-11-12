# Dependencies
# 01_crosswalks.R

###############################
# Libraries
library(RPostgreSQL)
library(Matrix)

###############################
# connection info
conn <- dbConnect("PostgreSQL", user='postgres', dbname='census',
                  host="snow.geog.utk.edu", port=5432)

B01001 <- dbGetQuery(conn, "SELECT geo.state, geo.county, geo.tract, a.*
                              FROM acs2012_5yr.B01001_moe AS a 
                                INNER JOIN acs2012_5yr.geoheader AS geo
                                ON a.geoid=geo.geoid 
                                WHERE geo.state='47' AND geo.county='037' AND geo.sumlevel='140'
                             ORDER BY state, county, tract;")
