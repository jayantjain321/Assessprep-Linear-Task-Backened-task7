# spec/support/request_helpers.rb
module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def auth_header(user)
    { 'Authorization' => "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base, 'HS256')}" }
  end
end
