module Api
  module V1
    class ProjectsController < ApplicationController

      before_action :find_project, only: [:update, :destroy, :show] # Callback to find the project for specific actions

      # POST users/:id/projects
      def create
        user = User.find_by(id: params[:user_id]) # Find the user by the provided user_id parameter

        if user.nil?  # Return an error if the user is not found
          render json: { error: 'User not found' }, status: :not_found
          return
        end
        @project = user.projects.new(project_params.merge(project_creator_id: current_user.id)) # Create a new project for the user, setting the current_user as the project creator
        @project.save!    # Save the project, raising an error if validation fails
        user.projects << @project   # Associate the project with the user
        LogActionService.log_action(@project.id, current_user.id, :create, 'Project')
        render json: { message: 'Project Created Successfully', project: @project }, status: :created
      end
      
      # PUT /projects/:id
      def update
        authorize! :update, @project
        @project.update!(project_params)
        LogActionService.log_action(@project.id, current_user.id, :update, 'Project')
        render json: { message: 'Project updated successfully', project: @project }, status: :ok
      end

      # DELETE /projects/:id
      def destroy
        authorize! :destroy, @project # CanCanCan authorization (will throw an AccessDenied exception if unauthorized)
        @project.destroy 
        LogActionService.log_action(@project.id, current_user.id, :destroy, 'Project')
        render json: { message: 'Project deleted successfully' }, status: :ok
      end

      # GET /projects/:id
      def show
        tasks = @project.tasks   # Receving all tasks of a project
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
      
      def project_params
        params.require(:project).permit(:name, :description, :status, :start_date, :end_date)  #only allow the specified attributes
      end
    end    
  end
end




