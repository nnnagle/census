# Recode PUMS data to the Summary File categories
# The raw data file ss11ga.Rdata was created by 
#  data/munge/example_sql_pull.R

library(car)
load('data/secondary/ss11ga.Rdata')

ss11ga.recode <- NULL


####################################################
# ID                                               #
####################################################
ss11ga.recode[['serialno']] <- ss11ga$serialno
ss11ga.recode[['sporder']] <- ss11ga$sporder
ss11ga.recode[['puma']] <- ss11ga$puma


####################################################
# Sex                                              #
####################################################
ss11ga.recode[['sex']] <- recode(ss11ga$sex, "'1'='Male'; '2'='Female'", levels=c("Male", "Female"), as.factor.result=TRUE)

####################################################
# AGE                                              #
####################################################
age.brks <- c(0,5,10,15,18,20,21,22,25,30,35,40,45,50,55,60,62,65,67,70,75,80,85,Inf)
ss11ga.recode[['agep']] <- cut(as.numeric(ss11ga$agep), 
                               breaks=c(0,5,10,15,18,20,21,22,25,30,35,40,45,50,55,60,62,65,67,70,75,80,85,Inf), include.lowest=TRUE, right=FALSE,
                               labels=c(paste(age.brks[1:22], c(age.brks[2:23])-1,sep='-'), '85+'),
                               ordered_result=TRUE)


####################################################
# PERSONAL INCOME                                  #
####################################################
ss11ga.recode[['pincp']] <- cut(as.numeric(ss11ga$pincp)*as.numeric(ss11ga$adjinc)/1000000, 
                                breaks=c(-Inf, 2500, 5000, 7500, 10000, 12500, 15000, 17500, 20000, 22500,
                                         25000, 30000, 35000, 40000, 45000, 50000, 55000, 65000, 75000, 100000, Inf),
                                labels=c('1-2499 or loss', '2500-4999','5000-7499','7500-9999','10000-12499',
                                         '12500-14999','15000-17499','17500-19999',
                                         '20000-22499','22500-24999','25000-29999','30000-34999',
                                         '35000-39999','40000-44999', '45000-49999',
                                         '50000-','55000-64999','65000-74999','75000-99999','100000 or more'),
                                right=FALSE, ordered_result=TRUE)
ss11ga.recode[['pincp']][ss11ga$agep<15] <- NA  

####################################################
# RACE                                             #
####################################################

ss11ga.recode[['race']] <- car::recode(ss11ga$rac1p,
                                       "1=1; 2=2; c(3,4,5)=3; 5=4; 6=4;7=5; 8=6; 9=7")
ss11ga.recode[['race']] <- factor(ss11ga.recode[['race']], 1:7, labels=c('White alone', 'Black or African American alone', 
                                                                         'American Indian and Alaska Native alone', 'Asian alone',
                                                                         'Native Hawaiian and Other Pacific Islander alone','Some other race alone',
                                                                         'Two or more races')
)  

####################################################
# HISPANIC                                         #
####################################################

ss11ga.recode[['hispan']] <- (car::recode(as.numeric(ss11ga$hisp),
                                          "1='Not Hispanic'; 2:24='Hispanic'",
                                          levels=c('Not Hispanic', 'Hispanic'),
                                          as.factor.result=TRUE))

####################################################
# EMPLOYENT STATUS                                 #
####################################################

ss11ga.recode[['empstat']] <- car::recode(ss11ga$esr,
                                          "c('1','2','4','5')='employed'; '3'='unemployed'; '6'='not in labor force'",
                                          levels=c('employed','unemployed','not in labor force'),
                                          as.factor.result=TRUE)

####################################################
# EDUCATIONAL ATTAINMENT                           #
####################################################

ss11ga.recode[['educ']] <- recode(ss11ga$schl,
                                  "c('01','02','03','04','05','06','06','07')='Less than high school diploma'; 
                                  c('08','09')='High school graduate, or GED'; 
                                  c('10','11','12')='Some college of associates degree'; 
                                  c('13','14','15','16')='Bachelors degree or higher'",
                                  levels=c("Less than high school diploma", "High school graduate, or GED",
                                           "Some college of associates degree", "Bachelors degree or higher"),
                                  as.factor.result=TRUE
)
ss11ga.recode[['educ']][ss11ga$agep<25] <- NA  


####################################################
# MARITAL STATUS                                   #
####################################################
ss11ga.recode[['marst']] <- recode(ss11ga$msp,
                                   "'1'='Now married, spouse present'; 
                                    '2'='Now married, spouse absent';
                                    '3'='Widowed';
                                    '4'='Divorced';
                                    '5'='Separated';
                                    '6'='Never married'",
                                   levels=c("Never married", "Now married, spouse present",
                                            "Now married, spouse absent", "Separated",
                                            "Widowed","Divorced"),
                                   as.factor.result=TRUE)
                                   
ss11ga.recode[['marst']][ss11ga$agep<15] <- NA  

####################################################
# TENURE                                           #
####################################################

ss11ga.recode[['ten']]<- recode(ss11ga$ten,
                                               "c('1','2')= 'owner occupied'; c('3','4') = 'renter occupied'",
                                               levels=c('owner occupied', 'renter occupied'),
                                               as.factor.result=TRUE)

####################################################
# HOUSEHOLD INCOME                                 #
####################################################

ss11ga.recode[['hincp']] <- cut(as.numeric(ss11ga$hincp)*as.numeric(ss11ga$adjinc)/1000000, 
                                breaks=c(-Inf, 10000, 15000,  20000, 
                                         25000, 30000, 35000, 40000, 45000, 50000, 60000, 75000, 100000, 125000, 150000, 200000, Inf),
                                labels=c('less than $10,000', '$10,000 to $14,999','$15,000 to $19,999','$20,000 to $24,999','$25,000 to $29,999'
                                        ,'$30,000 to $34,999','$35,000 to $39,999',
                                         '$40,000 to $44,999','$45,000 to $49,999','$50,000 to $59,999','$60,000 to $74,999','$75,000 to $99,999','$100,000 to $124,999',
                                         '$125,000 to $149,999','$150,000 to $199,999','$200,000 or more'),
                                right=FALSE, ordered_result=TRUE)

####################################################
# HOUSEHOLD SIZE                                   #
####################################################

#Number of person in household - B11016
ss11ga.recode[['np']]<-cut(as.numeric(ss11ga$np), 
                                        breaks=c( 1, 2, 3, 4,5,6,7, Inf),
                                        labels=c('1-person household', '2-person household','3-person household','4-person household','5-person household', '6-person household', '7-or-more person household'),
                                        right=FALSE, ordered_result=TRUE)


 

####################################################
# NUMBER OF OWN CHILDREN                           #
####################################################
# It looks like the cutoff in the Summary Files is 0, 1-2, 3-4, 5+  (example: B17012)
# Also, it should be related children.  I don't think we can get this without merging the entire House and Person data files:
ss11ga.recode[['noc']]<- cut(as.numeric(ss11ga$noc), 
                             
                              breaks=c( 0, 2, 4, 5, Inf),
                              labels=c('no children', '1 or 2 children', '3 or 4 children', '5 or more children'),
                              right=FALSE, ordered_result=TRUE)


####################################################
# NUMBER OF RELATED CHILDREN                       #
####################################################
# It looks like the cutoff in the Summary Files is 0, 1-2, 3-4, 5+  (example: B17012)
# Also, it should be related children.  I don't think we can get this without merging the entire House and Person data files:
ss11ga.recode[['nrc']]<- cut(as.numeric(ss11ga$nrc), 
                             
                             breaks=c( 0, 2, 4, 5, Inf),
                             labels=c('no children', '1 or 2 children', '3 or 4 children', '5 or more children'),
                             right=FALSE, ordered_result=TRUE)

####################################################
# CITIZENSHIP                                      #
####################################################

ss11ga.recode[['cit']]<-recode(ss11ga$cit,
                                   "'1'='U.S. Citizen, born in the United States'; 
                                    '2'='U.S. Citizen, born in Puerto Rico or U.S. Island Areas';
                                    '3'='U.S. Citizen, born abroad of American parent(s)';
                                    '4'='U.S. Citizen by Naturalization';
                                    '5'='Not a U.S. Citizen'",
                                    
                                       levels=c("U.S. Citizen, born in the United States", "U.S. Citizen, born in Puerto Rico or U.S. Island Areas",
                                                "U.S. Citizen, born abroad of American parent(s)", "U.S. Citizen by Naturalization",
                                                "Not a U.S. Citizen"),
                                       as.factor.result=TRUE)


####################################################
# HOUSING WEIGHT                                   #
####################################################
ss11ga.recode[['wgtp']] <- as.numeric(ss11ga$wgtp)

####################################################
# PERSON WEIGHT                                    #
####################################################
ss11ga.recode[['pwgtp']] <- as.numeric(ss11ga$pwgtp)


###################################################
# Vehicles Available                              #
###################################################
#Reference Table B25044


ss11ga.recode[['veh']]<- cut(as.numeric(ss11ga$veh), 
                             
                             breaks=c( 0, 1, 2, 3, 4, 5, Inf),
                             labels=c('No vehicle available', '1 vehicle available', '2 vehicles available', '3 vehicles available', '4 vehicles available', '5 or more vehicles available'),
                             right=FALSE, ordered_result=TRUE)

###################################################
#Property Value                                   #
###################################################
#Referecne Table B25075

ss11ga.recode[['val']]<- cut(as.numeric(ss11ga$val), 
                             
                             breaks=c( 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24, Inf),
                             labels=c('Less than $10,000', '$10,000 to $14,999', '$15,000 to $19,999', '$20,000 to $24,999', '$25,000 to $29,999', '$30,000 to $34,999
                              ', '$35,000 to $39,999','$40,000 to $49,999','$50,000 to $59,999','$60,000 to $69,999','$70,000 to $79,999','$80,000 to $89,999', '$90,000 to $99,999
                              ', '$100,000 to $124,999', '$125,000 to $149,999', '$150,000 to $174,999', '$175,000 to $199,999', '$200,000 to $249,999', '$250,000 to $299,999
                                ', '$300,000 to $399,999', '$400,000 to $499,999', '$500,000 to $749,999', '$750,000 to $999,999', '$1,000,000 or more'),
                             right=FALSE, ordered_result=TRUE)


#################################################
#Structure First Built                          #
#################################################
#Reference Table B25107


ss11ga.recode[['yearbuilt']]<-cut(as.numeric(ss11ga$ybl), 
                             
                             breaks=c( 1,2,3,4,5,6,7,8,9, Inf),
                             labels=c('Built 2005 or later', 'Built 2000 to 2004', 'Built 1990 to 1999',
                                      'Built 1980 to 1989', 'Built 1970 to 1979', 'Built 1960 to 1969
                                      ', 'Built 1950 to 1959','Built 1940 to 1949','Built 1939 or earlier'),
                             right=FALSE, ordered_result=TRUE)



################################################
#Age_2
################################################
#There seems to be a few different methods for categorizing age
#Table B01001A

ss11ga.recode[['age_2']]<- cut(as.numeric(ss11ga$agep), 
                             
                             breaks=c( -Inf, 5, 10, 15, 18, 20, 25, 30, 35, 45, 55, 65, 75, 85, Inf), 
                               labels=c('Under 5 years', '5 to 9 years', '10 to 14 years', '15 to 17 years',
                                        '18 and 19 years', '20 to 24 years', '25 to 29 years','30 to 34 years',
                                        '35 to 44 years', '45 to 54 years', '55 to 64 years',
                                        '65 to 74 years', '75 to 84 years', '85 years and over'),
                               right=FALSE, ordered_result=TRUE)
                              


################################################
#Monthly Rent #RNTP
################################################
#Table B25056

ss11ga.recode[['rntp']] <- cut(as.numeric(ss11ga$rntp)*as.numeric(ss11ga$adjhsg)/1000000, 
                                breaks=c(-Inf, 100, 150,  200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 
                                         750, 800, 900, 1000, 1250, 1500, 2000, Inf),
                                labels=c('Less than $100', '$100 to $149','$150 to $199','$200 to $249','$250 to $299'
                                         ,'$300 to $349','$350 to $399',
                                         '$400 to $449','$450 to $499','$500 to $549','$550 to $599','$600 to $649','$650 to $699',
                                         '$700 to $749','$750 to $799','$800 to $899','$900 to $999', '$1,000 to $1,249', '$1,250 to $1,499',
                                         '$1,500 to $1,999', '$2,000 or more'),
                                right=FALSE, ordered_result=TRUE)

###############################################
#Type (HU or GQ)
###############################################
ss11ga.recode[['type']] <- recode(ss11ga$type,
                                  "'1'='Housing Unit'; c('2','3')='Group Quarters'",
                                  levels=c('Housing Unit', 'Group Quarters'),
                                  as.factor.result=TRUE)

################################################
#Gross Rent #GRNTP
################################################
#Table B25063

ss11ga.recode[['grntp']] <- cut(as.numeric(ss11ga$grntp)*as.numeric(ss11ga$adjhsg)/1000000, 
                               breaks=c(-Inf, 100, 150,  200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 
                                        750, 800, 900, 1000, 1250, 1500, 2000, Inf),
                               labels=c('Less than $100', '$100 to $149','$150 to $199','$200 to $249','$250 to $299'
                                        ,'$300 to $349','$350 to $399',
                                        '$400 to $449','$450 to $499','$500 to $549','$550 to $599','$600 to $649','$650 to $699',
                                        '$700 to $749','$750 to $799','$800 to $899','$900 to $999', '$1,000 to $1,249', '$1,250 to $1,499',
                                        '$1,500 to $1,999', '$2,000 or more'),
                               right=FALSE, ordered_result=TRUE)


################################################
#Vacancy Status #VACS
################################################
#Table B25004



ss11ga.recode[['vacs']] <- recode(ss11ga$vacs,
                                   "'1'='For rent'; 
                                '2'='Rented, not occupied';
                                '3'='For sale only';
                                '4'='Sold, not occupied';
                                '5'='For seasonal, recreational, or occasional use';
                                '6'='For migrant workers';
                                  '7'='Other Vacant';",
                                levels=c("For rent", "Rented, not occupied",
                                "For sale only", "Sold, not occupied",
                                "For seasonal, recreational, or occasional use","For migrant workers","Other Vacant"),
                                as.factor.result=TRUE)

#################################################
#Vacant/Occupied Recode
#vacs
################################################

ss11ga.recode[['vac_status']] <- car::recode(ss11ga$vacs,
                                          "c('1','2','3','4','5','6','7')='vacant'; else='occupied or GQ';",
                                          levels=c('vacant','occupied'),
                                          as.factor.result=TRUE)


#################################################
#BLD Building Type
# Table B25024.
################################################
ss11ga.recode[['bld']] <- recode(ss11ga$bld,
                                 "'01' = 'Mobile home or trailer';
                                 '02' = 'One-family house detached';
                                 '03' = 'One-family house attached';
                                 '04' = '2 Apartments';
                                 '05' = '3-4 Apartments';
                                 '06' = '5-9 Apartments';
                                 '07' = '10-19 Apartments';
                                 '08' = '20-49 Apartments';
                                 '09' = '50 or more apartments';
                                 '10' = 'Boat, RV, van, etc.'",
                                 levels=c(
                                          'One-family house detached',
                                          'One-family house attached',
                                          '2 Apartments',
                                          '3-4 Apartments',
                                          '5-9 Apartments',
                                          '10-19 Apartments',
                                          '20-49 Apartments',
                                          '50 or more apartments',
                                          'Mobile home or trailer',
                                          'Boat, RV, van, etc.'),
                                 as.factor.result=TRUE)

###########################################
#Age_3
###########################################
#Table B06001

ss11ga.recode[['age_3']]<- cut(as.numeric(ss11ga$agep), 
                               
                               breaks=c( -Inf, 5, 18, 25, 35, 45, 55, 60, 62, 65, 75, Inf), 
                               labels=c('Under 5 years', '5 to 17 years', '18 to 24 years', '25 to 34 years',
                                        '35 to 44 years', '45 to 54 years', '55 to 59 years','60 and 61 years',
                                        '62 to 64 years', '65 to 74 years', 
                                        '75 years and over'),
                               right=FALSE, ordered_result=TRUE)



ss11ga.recode <- as.data.frame(ss11ga.recode)

save(ss11ga=ss11ga.recode, file='data/secondary/ss11ga_recode.Rdata')



