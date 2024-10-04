# app/controllers/api/v1/tasks_controller.rb
module Api
  module V1
    class TasksController < ApplicationController
      
      before_action :find_task, only: [:update, :destroy, :task_comments]
      before_action :authorize_task_owner!, only: [:update, :destroy]

      def create
        assigned_user = User.find_by(id: params[:assigned_user_id])
        project = Project.find_by(id: params[:project_id])

        if assigned_user.nil?
          render json: { error: 'Assigned user not found' }, status: :not_found
          return
        end

        raise ProjectNotFoundError.new if project.nil?

        task = Task.new(task_params.merge(user_id: current_user.id, assigned_user_id: assigned_user.id, project_id: project.id))
        task.save!

        render json: { message: 'Task created successfully', task: task }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def update
        assigned_user = User.find_by(id: params[:assigned_user_id])

        if assigned_user.nil?
          render json: { error: 'Assigned user not found' }, status: :not_found
          return
        end

        @task.update!(task_params.merge(assigned_user_id: assigned_user.id))
        render json: { message: 'Task updated successfully', task: @task }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def destroy
        @task.destroy!
        render json: { message: 'Task deleted successfully' }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def index
        tasks = Task.page(params[:page]).per(10) #displying large datasets in pagination
        render json: {tasks: tasks}, status: :ok
      end

      def task_comments
        comments = @task.comments
        render json: { comments: comments }, status: :ok
      end

      private

      def find_task
        @task = Task.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise TaskNotFoundError.new
      end

      def authorize_task_owner!
        if @task.user_id != current_user.id
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      def task_params
        params.require(:task).permit(:task_title, :description, :assign_date, :due_date, :status, :priority)
      end
    end
  end
end


