class TasksController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create, :update]

  def create
    task = Task.new(task_params)

    if task.save
      render json: { message: 'Task created successfully', task: task }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    task = Task.find(params[:id])
    if task.update(task_params)
      render json: task, status: :ok
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :assign_date, :due_date, :status, :priority, :assigned_user)
  end
end
