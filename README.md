# s3_utils
s3 util is a ruby script list for dealing with s3 issue.

### restore_s3_deep_archive
restore_s3_deep_archive can restore s3 archive.
It requires the structure that has element below
  - Each object has YYYYMMDD parent dir. 
  - ex: `bucket/hoge/20200101/object.txt`

## usage

### restore_s3_deep_archive
```
1. Bundle install

2. cp config.yml.template config.yml

3 edit config.yml with below 
  - BUCKET: set bucket that you want to restore
  - MANIFEST_BUCKET: set bucket you put manifest file on
  - S3_KEY: set s3 key before date
  - START_DATE: start date
  - END_DATE: end date
  - AWS_ACCOUNT_ID: your account id
  - ROLE_ARN: set role arn
  - TAGS: set tags
  - GLACIER_JOB_TIER: choose "STANDARD" or "BULK"
  - LOG_DATE_FORMAT: set s3 dir date format


4. bundle exec ruby restore_s3_deep_archive.rb
```
