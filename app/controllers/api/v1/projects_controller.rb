module Api
  module V1
    class ProjectsController < ApplicationController
      include Restoreable
      include ErrorHandler

      before_action :authenticate_user!
      before_action :find_project, only: [:update, :destroy, :show]

      def create
        user = User.find_by(id: params[:user_id])
        if user.nil?
          render json: { error: 'User not found' }, status: :not_found
          return
        end

        project = user.projects.new(project_params)
        begin
          project.save!
          user.projects << project 
          render json: { message: 'Project Created Successfully', project: project }, status: :created
        rescue ActiveRecord::RecordInvalid => e
          raise e
        end
      end

      def update
        @project.update!(project_params)
        render json: { message: 'Project updated successfully', project: @project }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def destroy
        @project.destroy
        render json: { message: 'Project deleted successfully' }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def show
        render json: { tasks: @project.tasks }, status: :ok
      end

      def index
        projects = Project.page(params[:page]).per(10)
        render json: { projects: projects }, status: :ok
      end

      private

      def find_project
        @project = Project.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise ProjectNotFoundError.new
      end

      def project_params
        params.require(:project).permit(:name, :description, :status, :start_date, :end_date)
      end
    end    
  end
end




