library(RPostgreSQL)

conn <- dbConnect('PostgreSQL', host='snow.geog.utk.edu', dbname='census', user='postgres')

# List the tables there...
dbListTables(conn)

# List the fields in acs12_5h (acs 2012 5 Year, Household)
dbListFields(conn, 'acs12_5h')

# List the fields in acs12_5p (acs 2012 5 Year, Person)
dbListFields(conn, 'acs12_5p')



# Some examples:

# Query the age, race and survey weight for all persons in Georgia
ga.data <- dbGetQuery(conn,"
                      SELECT serialno, puma00, puma10, st, pwgtp, agep, rac1p 
                      FROM acs12_5p WHERE st = '13';
                      ")
#Note, SQL is finicky about requesting single quotes in queries
head(ga.data)


# Query the age, race, household income, adjhsg, house weight, and person weight, for all 
#  persons in Georgia in PUMA10=01200

ga.data <- dbGetQuery(conn, "
                      SELECT h.serialno, p.sporder, h.puma10, h.wgtp, p.pwgtp, h.hincp, h.adjhsg, p.agep, p.rac1p
                      FROM acs12_5h AS h FULL OUTER JOIN acs12_5p AS p ON p.serialno=h.serialno
                      WHERE h.st='13' AND h.puma10='01200' AND p.st='13' AND p.puma10='01200'
                      ORDER BY serialno ASC, sporder ASC;
                      ")

################
# NOTE: I'm not sure I got vacant households with this query, and I'm not sure why.
