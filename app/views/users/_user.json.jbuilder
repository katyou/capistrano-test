json.extract! user, :id, :id, :user_id, :password, :user_name, :mail_address, :created_at, :updated_at
json.url user_url(user, format: :json)
