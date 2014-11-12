###############################
# Libraries
library(RPostgreSQL)
library(Matrix)

###############################
# connection info
conn <- dbConnect("PostgreSQL", user='postgres', dbname='census',
                  host="snow.geog.utk.edu", port=5432)

###############################################################
# Create the crosswalks for census tracts in Davidson County:
where.list <- list(c("block10_statefp10", "'47'"), c("block10_countyfp10", "'037'"))
puma.tract.crosswalk <- function(conn, table, block_geoid, puma_geoid, area, where.list, matrix=TRUE){
  # puma.tract.crosswalk create the puma to tract crosswalk from the database on snow
  # conn: the RpostgreSQL connection
  # dbname: character - the table name (e.g. puma00_block10)
  # puma_geoid: character - the field name of the puma geoid (e.g. puma00_geoid)
  # block_geoid: character - the field name of the block geoid (e.g. block10_geoid)
  # area: character - the field name of the area data (e.g. isect_area)
  # where.list - a list of left-right entries in a where clase: e.g.
  #     list(c("block10_statefp10", "'47'"), c("block10_countyfp10", "'037'"))
  require(Matrix)
  where.clause <- paste(lapply(where.list, function(x) paste(x, collapse="=")), collapse=" AND ")
# Example sql call
#   puma00_tract10 <- dbGetQuery(conn, "SELECT LEFT(block10_geoid, 10) AS tract10,
#                                       puma00_geoid AS puma00,
#                                       SUM(isect_area) as area
#                                     FROM puma00_block10 
#                                     WHERE block10_statefp10='47' AND block10_countyfp10='037'
#                                     GROUP BY puma00, tract10
#                                     ORDER BY puma00, tract10;")
#   
#   
  sql.query <- sprintf("SELECT LEFT(%s, 11) AS tract,
                                %s AS puma,
                                SUM(%s) AS area
                               FROM %s
                               WHERE %s
                               GROUP BY puma, tract
                               ORDER BY puma, tract;", 
                       block_geoid, puma_geoid, area, table, where.clause)
  puma_tract <- dbGetQuery(conn, sql.query)
  puma_tract$tract <- as.factor(puma_tract$tract)
  puma_tract$puma <- as.factor(puma_tract$puma)
  if(matrix==FALSE) return(puma_tract)
  puma_tract.mat <- sparseMatrix(i = as.numeric(puma_tract$tract),
                                 j = as.numeric(puma_tract$puma),
                                 x = as.numeric(puma_tract$area),
                                 dimnames = list(levels(puma_tract$tract), levels(puma_tract$puma)))
  return(puma_tract.mat)
}

puma00_tract10 <- puma.tract.crosswalk(conn, 'puma00_block10', 'block10_geoid', 'puma00_geoid', 'isect_area', where.list)

# Remove all entries that are less than 10% of the tract
tractSize <- rowSums(puma00_tract10)
puma00_tract10@x[ puma00_tract10@x < .1 * tractSize[puma00_tract10@i + 1] ] <- 0
# Note: sparseMatrix@i is 0 indexed

puma00_tract10 <- drop0(puma00_tract10)
puma00_tract10 <- puma00_tract10[ , colSums(puma00_tract10) > 0 ]



####################
# Repeat for puma10_block10
puma10_tract10 <- puma.tract.crosswalk(conn, 'puma10_block10', 'block10_geoid', 'puma10_geoid', 'isect_area', where.list, matrix=TRUE)

tractSize <- rowSums(puma10_tract10)
puma10_tract10@x[ puma10_tract10@x < .1 * tractSize[puma10_tract10@i + 1] ] <- 0
# Note: sparseMatrix@i is 0 indexed

puma10_tract10 <- drop0(puma10_tract10)
puma10_tract10 <- puma10_tract10[ , colSums(puma10_tract10) > 0 ]




save(puma00_tract10, puma10_tract10, file='~/Dropbox/git/census/Davidson/puma00_tract10.Rdata')

