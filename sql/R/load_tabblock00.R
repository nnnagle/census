wget.loc <- '/opt/local/bin/'
dir.create('~/Data/www2.census.gov/geo/tiger/TIGER2010/TABBLOCK/2000', recursive=TRUE)


setwd('~/Data/www2.census.gov/geo/tiger/TIGER2010/TABBLOCK/2000')

wget.cmd <- sprintf('%swget -r -A "tl_2010_??_tabblock00.zip" -o wget.log -nH --cut-dirs=20 -np http://www2.census.gov/geo/tiger/TIGER2010/TABBLOCK/2000',
                    wget.loc)
system(wget.cmd)

zip.files <- list.files(pattern="*.zip")
zip.files <- zip.files[1:51]


sql.loc <- '/usr/local/pgsql-9.3/bin/'


system(sprintf('%spsql -U postgres -d tiger -c "DROP TABLE IF EXISTS tabblock00"', sql.loc))
# Census uses NAD83 SRID=4269


for(f in zip.files){
  unzip(f, exdir='tmp')
  shp.file <- list.files('tmp', pattern='*.shp$', full.names=TRUE, include.dirs=TRUE)
  shp2pgsql.cmd <- sprintf('%sshp2pgsql %s -I -s 4269 -W "latin1" -D %s tabblock00 | %spsql -d tiger -U postgres ' , 
                           sql.loc, ifelse(f==zip.files[[1]], '', '-a'), shp.file, sql.loc )
  print(shp2pgsql.cmd)
  system(shp2pgsql.cmd)
  unlink('tmp', recursive = TRUE, force = TRUE)
}

