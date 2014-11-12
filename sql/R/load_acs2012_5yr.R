wget.loc <- '/opt/local/bin/'
sql.loc <- '/usr/local/pgsql-9.3/bin/'


dir.create('~/Data/www2.census.gov/acs2012_5yr/summaryfile/2008-2012_ACSSF_All_In_2_Giant_Files(Experienced-Users-Only)/', recursive=TRUE)

setwd('~/Data/www2.census.gov/acs2012_5yr/summaryfile/2008-2012_ACSSF_All_In_2_Giant_Files(Experienced-Users-Only)')

wget.cmd <- sprintf('%swget -r -A ".tar.gz" -o wget.log -nH --cut-dirs=20 -np http://www2.census.gov/acs2012_5yr/summaryfile/2008-2012_ACSSF_All_In_2_Giant_Files%%28Experienced-Users-Only%%29',
                    wget.loc)
system(wget.cmd)

zip.files <- list.files(pattern='.tar.gz')

for(f in zip.files){
  untar(f, exdir='.', compressed=TRUE)
}


#####################
# Get geography file

download.file('http://www2.census.gov/acs2012_5yr/summaryfile/2008-2012_ACSSF_All_In_2_Giant_Files(Experienced-Users-Only)/2012_ACS_Geography_Files.zip',
              destfile='2012_ACS_Geography_Files.zip')
unzip('2012_ACS_Geography_Files.zip')


###########################
# Create SQL directory and change directory path
# setwd('~/Dropbox/git/census/sql/')
# dir.create('sql/acs2012_5_yr')
# file.copy(from = list.files('sql/acs2012_5yr_orig/', full.names=TRUE),
#           to = 'sql/acs2012_5_yr', recursive=TRUE, overwrite=TRUE)
# system("find sql/acs2012_5_yr/ -type f -exec sed -i 's/dir_name/Volumes/HDD2/Data/www2.census.gov/acs2012_5yr/summaryfile/2008-2012_ACSSF_All_In_2_Giant_Files%%28Experienced-Users-Only%%29/g' {} \;")

# Just make that change by hand

setwd('sql/acs2012_5_yr/')

system(sprintf("%spsql -U postgres -d census -c 'CREATE SCHEMA acs2012_5yr'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'create_geoheader.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'create_tmp_geoheader.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'geoheader_comments.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'import_geoheader.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'parse_tmp_geoheader.sql'", sql.loc))

system(sprintf("%spsql -U postgres -d census -f 'create_import_tables.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'import_sequences.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'store_by_tables.sql'", sql.loc))
system(sprintf("%spsql -U postgres -d census -f 'insert_into_tables.sql'", sql.loc))


system(sprintf("%spsql -U postgres -d census -f 'view_stored_by_tables.sql'", sql.loc))

system(sprintf("%spsql -U postgres -d census -f 'drop_import_tables.sql'", sql.loc))






