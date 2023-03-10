# frozen_string_literal: true

def s3_list_object_content(s3_client, bucket, key)
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

def fetch_target_dates(terms)
  terms.flat_map { |term| [*Date.parse(term['START_DATE'])..Date.parse(term['END_DATE'])] }
end
