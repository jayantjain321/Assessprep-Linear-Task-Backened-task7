module Api
  module V1
    class ProjectsController < ApplicationController

      # Callback to find the project for specific actions
      before_action :find_project, only: [:update, :destroy, :show]

      # Ensures that only the project owner can update or destroy the project
      before_action :authorize_task_owner!, only: [:update, :destroy]

      # POST users/:id/projects
      def create
        # Find the user by the provided user_id parameter
        user = User.find_by(id: params[:user_id])

        # Return an error if the user is not found
        if user.nil?
          render json: { error: 'User not found' }, status: :not_found
          return
        end

        # Create a new project for the user, setting the current_user as the project creator
        @project = user.projects.new(project_params.merge(project_creator_id: current_user.id))
        begin
          @project.save!    # Save the project, raising an error if validation fails
          user.projects << @project   # Associate the project with the user
          LogActionService.log_action(@project.id, current_user.id, :create, 'Project')
          render json: { message: 'Project Created Successfully', project: @project }, status: :created
        rescue ActiveRecord::RecordInvalid => e
          # Raise the validation error to handle globally
          raise e
        end
      end
      
      # PUT /projects/:id
      def update
        @project.update!(project_params)
        LogActionService.log_action(@project.id, current_user.id, :update, 'Project')
        render json: { message: 'Project updated successfully', project: @project }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      # DELETE /projects/:id
      def destroy
        @project.destroy 
        LogActionService.log_action(@project.id, current_user.id, :destroy, 'Project')
        render json: { message: 'Project deleted successfully' }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end
      

      # GET /projects/:id
      def show
        # Order the tasks by created_at in descending order
        tasks = @project.tasks
        # Return the tasks associated with the project
        render json: { tasks: tasks }, status: :ok
      end
      

      # GET /projects
      def index
        # Paginate the project list to avoid loading large datasets in one go
        projects = Project.order(created_at: :desc).page(params[:page]).per(10) # Order projects by creation time in descending order
        render json: { projects: projects }, status: :ok  # Return the paginated list of projects
      end

      private

      # Finds a project by its ID, returns a custom error if the project is not found
      def find_project
        @project = Project.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise ProjectNotFoundError.new  # Custom error handling for project not found
      end

      # Ensures that the current user is the creator of the project before allowing certain actions
      def authorize_task_owner!

        # Check if the current user is the owner of the project
        if @project.project_creator_id != current_user.id
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden  # Return an unauthorized error
        end
      end
      
      def project_params
        params.require(:project).permit(:name, :description, :status, :start_date, :end_date)  #only allow the specified attributes
      end
    end    
  end
end




