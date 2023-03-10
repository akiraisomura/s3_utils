# frozen_string_literal: true

require 'aws-sdk'
require 'date'
require 'yaml'

def main
  completed_list = []
  uncompleted_list = []

  target_dates.each do |date|
    s3_objects = s3_list_object_content(config['BUCKET'], "#{config['S3_KEY']}/#{date.strftime(config['LOG_DATE_FORMAT'])}")
    completed, uncompleted = s3_objects.partition do |object|
      object.storage_class == [config['GLACIER_JOB_TIER']]
    end
    completed_list.push(completed)
    uncompleted_list.push(uncompleted)
  end
  puts "Completed: #{completed_list.flatten.size}, uncompleted: #{uncompleted_list.flatten.size}"
end

def s3_list_object_content(bucket, key)
  params = { bucket: bucket, prefix: key }
  contents = []
  loop do
    objects = s3_client.list_objects_v2(params)
    contents.push(objects.contents)
    next_continuation_token = objects.next_continuation_token
    break unless next_continuation_token

    params[:continuation_token] = next_continuation_token
  end
  contents.flatten(1)
end

def target_dates
  config['TERMS'].flat_map { |term| [*Date.parse(term['START_DATE'])..Date.parse(term['END_DATE'])] }
end

def s3_client
  @s3_client ||= Aws::S3::Client.new
end

def config
  @config ||= YAML.load_file('config.yml')
end

main
