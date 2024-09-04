class SessionsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      user = User.find_by(email: params[:email])
  
      if user && user.authenticate(params[:password])
        token = encode_token(user_id: user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  
    private
  
    def encode_token(payload)
      secret_key = Rails.application.credentials.secret_key_base
      JWT.encode(payload, secret_key, 'HS256')
    end
end

