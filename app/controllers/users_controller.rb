class UsersController < ApplicationController

    skip_before_action :authenticate_user!, only: [:create]
    skip_before_action :verify_authenticity_token, only: [:create]
    def create
        user = User.new(user_params)
        
        if user.save
          render json: { message: 'User created successfully', user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def index
      users = User.all
      render json: users
    end

    def userProjects
      projects = current_user.projects
      render json: {projects: projects}, status: :ok
    end

    def userTasks
      tasks = current_user.tasks
      render json: {tasks: tasks}, status: :ok
    end
    
    private
    
    def user_params
        params.require(:user).permit(:name, :email, :password, :position)
    end
end
