# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController

      # Skip authentication for the create action since users need to sign up before logging in
      skip_before_action :authenticate_user!, only: [:create]

      # POST /users  Creates a new user with the given parameters
      def create

        # Initialize a new user with the provided parameters
        user = User.new(user_params)
        user.save! # Save the user and return a success message with user details
        render json: { message: 'User created successfully', user: user }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        raise e  # Raise the validation error to be handled globally
      end

      # GET /users
      def index

        # Paginate the list of users (10 users per page)
        users = User.page(params[:page]).per(10)
        render json: {users: users}, status: :ok  # Return the paginated list of users
      end

      # GET /users/projects  Lists all projects associated with the current user
      def userProjects

        # Eager load the users associated with each project to avoid N+1 queries
        projects = current_user.projects.includes(:users)

        # Return the user's projects along with associated users
        render json: { projects: projects }, status: :ok
      end

      # GET /users/tasks  Lists all tasks assigned to the current user
      def userTasks
        tasks = Task.includes(:project).where(assigned_user_id: current_user.id)  # Eager load the projects associated with the tasks 
        render json: { tasks: tasks }, status: :ok
      end
      
      private
      
      # Strong parameters for user creation to ensure only permitted attributes are allowed
      def user_params
          params.require(:user).permit(:name, :email, :password, :position)
      end
    end
  end
end

