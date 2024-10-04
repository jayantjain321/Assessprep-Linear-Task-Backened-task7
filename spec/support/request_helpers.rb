# spec/support/request_helpers.rb
module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def authenticated_headers(user)
    auth_token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, 'HS256')
    { 'Authorization' => "Bearer #{auth_token}" }
  end
end
