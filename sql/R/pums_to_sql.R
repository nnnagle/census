####################################################################
# Download the housing files

wget.loc <- '/opt/local/bin/'
sql.loc <- '/usr/local/pgsql-9.3/bin/'


dir.create('~/Data/www2.census.gov/acs2012_5yr/pums/', recursive=TRUE)

setwd('~/Data/www2.census.gov/acs2012_5yr/pums/')

# Download the data
wget.cmd <- sprintf('%swget -r -A "csv_???.zip" -R "csv_?us.zip" -R "csv_?pr.zip" -o wget.log -nH --cut-dirs=20 -np http://www2.census.gov/acs2012_5yr/pums/',
                    wget.loc)
system(wget.cmd)
####################################################################



# Create SQL tables on snow.geog.utk.edu and insert PUMS data.

library(RPostgreSQL)
conn <- dbConnect("PostgreSQL", user='postgres', dbname='census',
                  host="snow.geog.utk.edu", port=5432)

# Unzip the microdata to a temporary file
unzip('~/Data/www2.census.gov/acs2012_5yr/pums/csv_hwy.zip',
      exdir=tempdir())



# Read the first line and extract row names
line_1 <- strsplit(readLines(file.path(tempdir(), 'ss12hwy.csv'), n=1), ',')[[1]]
line_1 <- toupper(line_1)

# Create SQL table schema
# By default, each field is 6 characters.
# The exceptions are: SERIALNO: 13; ADJINC 7; NAICSP02 8; NAICSP0? 8;
# PERNP 9; PINCP 9; (the codebook says 7, but it's clearly 9)
table_def <- data.frame(row.names=line_1, name=line_1, type='VARCHAR(6)',
                        stringsAsFactors=FALSE)
table_def$name <- toupper(table_def$name)
row.names(table_def) <- table_def$name
table_def['SERIALNO', 'type'] <- 'VARCHAR(13)'
table_def['ADJHSG', 'type'] <- 'VARCHAR(7)'
table_def['ADJINC', 'type'] <- 'VARCHAR(7)'
table_def['FINCP', 'type'] <- 'VARCHAR(9)'
table_def['HINCP', 'type'] <- 'VARCHAR(9)'
table_def['VALP', 'type'] <- 'VARCHAR(7)'


sql.cmd <- sprintf('CREATE TABLE ACS12_5H (%s, PRIMARY KEY (SERIALNO));',
                   paste(table_def$name, table_def$type, collapse=', '))

dbGetQuery(conn, statement="DROP TABLE IF EXISTS ACS12_5H;")
dbGetQuery(conn, statement=sql.cmd)
dbGetQuery(conn, statement="CREATE INDEX ACS12_5H_st_idx ON ACS12_5H(ST);")
dbGetQuery(conn, statement="CREATE INDEX ACS12_5H_puma00_idx ON ACS12_5H(PUMA00);")
dbGetQuery(conn, statement="CREATE INDEX ACS12_5H_puma10_idx ON ACS12_5H(PUMA10);")


# load in the pums files.
# the household file is split across 4 files.
#for(file in c('ss12husa','ss12husb','ss12husc','ss12husd')){
for(zip.file in list.files(pattern='csv_h..\\.zip')){
  csv.file <- unzip(zip.file, list=TRUE)$Name[1]
  unzip(zip.file, exdir=tempdir())
  sql.cmd <- sprintf("\\COPY ACS12_5H FROM '%s/%s' DELIMITER ',' CSV HEADER;", tempdir(), csv.file)
  cat(sql.cmd, file='test.sql')
  system(sprintf("%spsql -f test.sql 'host=snow.geog.utk.edu dbname=census user=postgres'", sql.loc))
}




######################################################################################
# load the person files

# Unzip the microdata to a temporary file
unzip('~/Data/www2.census.gov/acs2012_5yr/pums/csv_pwy.zip',
      exdir=tempdir(), overwrite=TRUE)

# Read the first line and extract row names
line_1 <- strsplit(readLines(file.path(tempdir(), 'ss12pwy.csv'), n=1), ',')[[1]]
line_1 <- toupper(line_1)

# Create SQL table schema
# By default, each field is 6 characters.
# The exceptions are: SERIALNO: 13; ADJINC 7; NAICSP02 8; NAICSP0? 8;
# PERNP 9; PINCP 9; (the codebook says 7, but it's clearly 9)
table_def <- data.frame(row.names=line_1, name=line_1, type='VARCHAR(6)',
                        stringsAsFactors=FALSE)
table_def$name <- toupper(table_def$name)
row.names(table_def) <- table_def$name
table_def['SERIALNO', 'type'] <- 'VARCHAR(13)'
table_def['ADJINC', 'type'] <- 'VARCHAR(7)'
table_def['NAICSP', 'type'] <- 'VARCHAR(8)'
table_def['PERNP', 'type'] <- 'VARCHAR(9)'
table_def['PINCP', 'type'] <- 'VARCHAR(9)'

sql.cmd <- sprintf('CREATE TABLE ACS12_5P (%s, PRIMARY KEY (SERIALNO, SPORDER));',
                   paste(table_def$name, table_def$type, collapse=', '))

dbGetQuery(conn, statement="DROP TABLE IF EXISTS ACS12_5P;")
dbGetQuery(conn, statement=sql.cmd)
dbGetQuery(conn, statement="CREATE INDEX ACS12_5P_st_idx ON ACS12_5P(ST);")
dbGetQuery(conn, statement="CREATE INDEX ACS12_5p_puma00_idx ON ACS12_5p(PUMA00);")
dbGetQuery(conn, statement="CREATE INDEX ACS12_5p_puma10_idx ON ACS12_5p(PUMA10);")



# load in the pums files.
# the household file is split across 4 files.
for(zip.file in list.files(pattern='csv_p..\\.zip')){
  csv.file <- unzip(zip.file, list=TRUE)$Name[1]
  unzip(zip.file, exdir=tempdir())
  sql.cmd <- sprintf("\\COPY ACS12_5P FROM '%s/%s' DELIMITER ',' CSV HEADER;", tempdir(), csv.file)
  cat(sql.cmd, file='test.sql')
  system(sprintf("%spsql -f test.sql 'host=snow.geog.utk.edu dbname=census user=postgres'", sql.loc))
}













