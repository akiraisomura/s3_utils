# frozen_string_literal: true

require 'aws-sdk'
require 'active_support/all'

def main
  alarms = cloud_watch_client.describe_alarms.metric_alarms

  unrecommended_alarms = alarms.reject { |a| alarm_with_ok?(a['alarm_actions'], a['ok_actions']) }
  message = format_message(unrecommended_alarms)
  puts message
end

def format_message(unrecommended_alarms)
  message = "List of alarms with missing definitions of ok_action or alarm_action"
  message += unrecommended_alarms.map { |a| "#{a['alarm_name']}" }.join("\n")
  message
end

def alarm_with_ok?(alarm_actions, ok_actions)
  alarm_actions.present? && ok_actions.present?
end

def cloud_watch_client
  @cloud_watch_client ||= Aws::CloudWatch::Client.new
end

main
