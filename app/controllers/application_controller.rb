class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.

  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :skip_authentication?

  private

  def authenticate_user!
    @current_user = decode_token
    render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  private

  def decode_token
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
        user_id = decoded_token[0]['user_id']
        User.find_by(id: user_id)
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def skip_authentication?
    # Skip authentication for the UsersController#create action
    action_name == 'create' && controller_name == 'users'
  end
  
  # allow_browser versions: :modern

  # before_action :authenticate_user!

  # private

  # def authenticate_user!
  #   @current_user = decode_token
  #   render json: { error: 'Not Authorized' }, status: :unauthorized unless @current_user
  # end

  # def current_user
  #   @current_user
  # end

  # private

  # def decode_token
  #   if request.headers['Authorization'].present?
  #     token = request.headers['Authorization'].split(' ').last
  #     begin
  #       decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
  #       user_id = decoded_token[0]['user_id']
  #       User.find_by(id: user_id)
  #     rescue JWT::DecodeError
  #       nil
  #     end
  #   end
  # end
  
end
