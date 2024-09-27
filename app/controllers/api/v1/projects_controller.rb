# app/controllers/api/v1/projects_controller.rb
module Api
  module V1
    class ProjectsController < ApplicationController

      include Restoreable

      before_action :authenticate_user!
    
      def create
        user = User.find_by(id: params[:user_id])
        if user
          project = user.projects.new(project_params)
          if project.save
            user.projects << project 
            render json: { message: 'Project Created Successfully', project: project }, status: :created
          else
            render json: project.errors, status: :unprocessable_entity
          end
        else
          render json: { error: 'User not found' }, status: :not_found
        end
      end
    
      def update
        project = Project.find_by(id: params[:id])
        
        if project
          if project.update(project_params)
            render json: { message: 'Project updated successfully' , project: project}, status: :ok
          else
            render json: project.errors, status: :unprocessable_entity
          end
        else
          render json: { error: 'Project not found' }, status: :not_found
        end
      end
    
      def destroy
        project = Project.find_by(id: params[:id])
        if project
          project.destroy
          render json: { message: 'Project deleted successfully' }, status: :ok
        else
          render json: { error: 'Project not found' }, status: :not_found
        end
      end
    
      def show
        project = Project.find_by(id: params[:id])
        if project
          render json: {tasks: project.tasks }, status: :ok
        else
          render json: { error: 'Project not found' }, status: :not_found
        end
      end
    
      def index
        projects = Project.page(params[:page]).per(10)
        render json: {projects: projects}, status: :ok
      end
    
      private
    
      def project_params
        params.require(:project).permit(:name, :description, :status, :start_date, :end_date)
      end
    end    
  end
end
