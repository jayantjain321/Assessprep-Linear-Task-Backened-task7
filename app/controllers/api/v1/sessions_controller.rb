# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
  
      skip_before_action :authenticate_user!, only: [:create]

      def create
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
          access_token = encode_token({ user_id: user.id, exp: 12.hours.from_now.to_i })
          refresh_token = encode_token({ user_id: user.id, exp: 12.hours.from_now.to_i })
          render json: { 
            access_token: access_token, 
            refresh_token: refresh_token, 
            user: user.as_json(only: [:id, :name, :email, :position]) 
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def refresh_token
        if request.headers['Authorization'].present?
          refresh_token = request.headers['Authorization'].split(' ').last

          begin
            decoded_token = JWT.decode(refresh_token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
            user_id = decoded_token[0]['user_id']
            user = User.find_by(id: user_id)
      
            if user
              new_access_token = encode_token({ user_id: user.id, exp: 12.hours.from_now.to_i }) #Here it is generating the new access token
              render json: { access_token: new_access_token }, status: :ok
            else
              render json: { error: 'User not found' }, status: :unauthorized
            end
      
          rescue JWT::ExpiredSignature
            render json: { error: 'Refresh token has expired. Please login again.' }, status: :unauthorized
          rescue JWT::DecodeError
            render json: { error: 'Invalid refresh token. Please login again.' }, status: :unauthorized
          end
        else
          render json: { error: 'Token is missing' }, status: :unauthorized
        end
      end

      def logout
        # The logout process is primarily handled on the client side.
        # Inform the client to remove JWT tokens from storage.
        render json: { message: 'Logged out successfully' }, status: :ok
      end
    
      private
    
      def encode_token(payload)
        secret_key = Rails.application.credentials.secret_key_base
        JWT.encode(payload, secret_key, 'HS256')
      end
    end   
  end
end

