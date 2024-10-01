# app/controllers/api/v1/applications_controller.rb
module Api
  module V1
    class ApplicationController < ActionController::API
      # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
      
      # allow_browser versions: :modern   

      protect_from_forgery with: :exception

      skip_before_action :verify_authenticity_token

      before_action :authenticate_user!, unless: :skip_authentication?
    
      private
    
      def authenticate_user!
        begin
          @current_user = decode_token
        rescue JWT::ExpiredSignature
          render json: { error: 'Token has expired. Please refresh token.' }, status: :unauthorized
        rescue JWT::DecodeError
          render json: { error: 'Invalid token. Please login again.' }, status: :unauthorized
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'User not found. Please login again.' }, status: :unauthorized
        rescue StandardError => e
          render json: { error: e.message }, status: :unauthorized
        end
      end      
    
      def current_user
        @current_user
      end
    
      private
      
      def decode_token
        if request.headers['Authorization'].present?
          token = request.headers['Authorization'].split(' ').last
          decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
          user_id = decoded_token[0]['user_id']
          User.find_by(id: user_id) || raise(ActiveRecord::RecordNotFound)
        else
          raise StandardError.new('Token is missing')
        end
      end
    
      def skip_authentication?
        action_name == 'create' && controller_name == 'users'
      end
    end       
  end
end
