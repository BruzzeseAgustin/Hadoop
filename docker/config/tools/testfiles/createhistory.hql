CREATE EXTERNAL TABLE history_raw (
    user_id STRING,
    datetime TIMESTAMP,
    ip STRING,
    browser STRING,
    os STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';
