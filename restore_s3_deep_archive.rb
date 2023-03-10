# frozen_string_literal: true

require 'aws-sdk'
require 'csv'
require 'date'
require 'yaml'
require_relative './deep_archive_restorable.rb'

def main
  manifest_file_name = "manifest#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv"
  make_manifest(manifest_file_name)
  response = upload_manifest_file(manifest_file_name)
  create_batch_operation_job(manifest_file_name, response.etag)
end

def make_manifest(file_name)
  target_dates.each do |date|
    s3_objects = s3_list_object_content(s3_client, config['BUCKET'], "#{config['S3_KEY']}/#{date.strftime(config['LOG_DATE_FORMAT'])}")
    s3_objects.each do |object|
      CSV.open(file_name, 'a') { |f| f << [config['BUCKET'], object.key] }
    end
  end
end

def upload_manifest_file(file_name)
  s3_client.put_object(
    body: File.open(file_name, 'rb'),
    bucket: config['MANIFEST_BUCKET'],
    key: file_name
  )
end

def create_batch_operation_job(manifes_file_name, etag) # rubocop:disable Metrics/MethodLength
  manifest_bucket_arn = make_s3_bucket_arn(config['MANIFEST_BUCKET'])
  job_id = s3_control_client.create_job(
    account_id: config['AWS_ACCOUNT_ID'],
    confirmation_required: false,
    operation: {
      s3_initiate_restore_object: {
        expiration_in_days: 10,
        glacier_job_tier: config['GLACIER_JOB_TIER'],
      },
    },
    report: {
      bucket: manifest_bucket_arn,
      format: 'Report_CSV_20180820',
      enabled: true,
      prefix: 'report',
      report_scope: 'AllTasks',
    },
    client_request_token: SecureRandom.uuid.delete('-'),
    manifest: {
      spec: {
        format: 'S3BatchOperations_CSV_20180820',
        fields: ['Bucket', 'Key'],
      },
      location: {
        object_arn: "#{manifest_bucket_arn}/#{manifes_file_name}",
        etag: etag,
      },
    },
    description: '2020-10-02 - Restore',
    priority: 10,
    role_arn: config['ROLE_ARN'],
    tags: config['TAGS'],
  )

  puts job_id
end

def target_dates
  fetch_target_dates(config['TERMS'])
end

def s3_client
  @s3_client ||= Aws::S3::Client.new
end

def s3_control_client
  @s3_control_client ||= Aws::S3Control::Client.new
end

def make_s3_bucket_arn(bucket)
  "arn:aws:s3:::#{bucket}"
end

def config
  @config ||= YAML.load_file('config.yml')
end

main
