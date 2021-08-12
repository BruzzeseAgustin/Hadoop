CREATE TABLE IF NOT EXISTS
              user_test(first_name string, 
                       last_name string, 
                       company_name string, 
                       address string, 
                       country string, 
                       city string, 
                       state string, 
                       post string, 
                       phone1 string, 
                       phone2 string, 
                       email string, 
                       web string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
 
LOAD DATA LOCAL INPATH '/opt/tools/testfiles/SampleUserData.txt' OVERWRITE INTO TABLE user_test;
select first_name from user_test where country='US' limit 5;
select COUNT(DISTINCT first_name) from user_test where country='UK';

