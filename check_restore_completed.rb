# frozen_string_literal: true

require 'aws-sdk'
require 'date'
require 'yaml'
require_relative './deep_archive_restorable.rb'

def main
  completed_list = []
  uncompleted_list = []

  target_dates.each do |date|
    s3_objects = s3_list_object_content(s3_client, config['BUCKET'], "#{config['S3_KEY']}/#{date.strftime(config['LOG_DATE_FORMAT'])}")
    completed, uncompleted = s3_objects.partition do |object|
      object.storage_class == [config['GLACIER_JOB_TIER']]
    end
    completed_list.push(completed)
    uncompleted_list.push(uncompleted)
  end
  puts "Completed: #{completed_list.flatten.size}, uncompleted: #{uncompleted_list.flatten.size}"
end

def target_dates
  fetch_target_dates(config['TERMS'])
end

def s3_client
  @s3_client ||= Aws::S3::Client.new
end

def config
  @config ||= YAML.load_file('config.yml')
end

main
