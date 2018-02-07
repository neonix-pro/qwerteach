json.extract! global_request, :id, :user_id, :topic_id, :level_id, :description, :status, :created_at, :updated_at
json.url global_request_url(global_request, format: :json)
