# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController

      skip_before_action :authenticate_user!, only: [:create]
  
      def create
          user = User.new(user_params)
          
          if user.save
            render json: { message: 'User created successfully', user: user }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
      end
  
      def index
        users = User.page(params[:page]).per(10)
        render json: {users: users}, status: :ok
      end
  
      def userProjects
        projects = current_user.projects.includes(:users) # Eager loading
        render json: { projects: projects }, status: :ok
      end
  
      def userTasks
        tasks = current_user.tasks.includes(:project) # Eager loading
        render json: { tasks: tasks }, status: :ok
      end
      
      private
      
      def user_params
          params.require(:user).permit(:name, :email, :password, :position)
      end
    end
  end
end

