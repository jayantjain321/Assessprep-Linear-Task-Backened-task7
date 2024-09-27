# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController

      include Restoreable

      before_action :authenticate_user!
    
      def create
        assigned_user = User.find_by(id: params[:assigned_user_id])
        project = Project.find_by(id: params[:project_id])
      
        if assigned_user.nil?
          render json: { error: 'Assigned user not found' }, status: :not_found
          return
        end
      
        if project.nil?
          render json: { error: 'Project not found' }, status: :not_found
          return
        end
      
        task = Task.new(task_params.merge(user_id: current_user.id, assigned_user_id: assigned_user.id, project_id: project.id))
      
        if task.save
          render json: { message: 'Task created successfully', task: task }, status: :created
        else
          render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        task = Task.find_by(id: params[:id])
        if task
          if task.user_id == current_user.id
            if task.update(task_params)
              render json: { message: 'Task updated successfully', task: task }, status: :ok
            else
              render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: 'You are not authorized to update this Task' }, status: :forbidden
          end
        else
          render json: { error: 'Task not found' }, status: :not_found
        end
      end
    
      def index
        tasks = Task.page(params[:page]).per(10)
        render json: {tasks: tasks}, status: :ok
      end

      def destroy
        task = Task.find(params[:id])
        if task
          task.destroy
          render json: { message: 'Task successfully deleted.' }, status: :ok
        else
          render json: { error: 'Task not found' }, status: :not_found
        end
      end
    
      def TaskComments
        task = Task.find_by(id: params[:id])
        if task
          comments = task.comments
          render json: {comments: comments}, status: :ok
        else 
          render json: {error: "Comment Not found"}, status: :not_found
        end
      end
    
      private
    
      def task_params
        params.require(:task).permit(:task_title, :description, :assign_date, :due_date, :status, :priority)
      end
    end    
  end
end
