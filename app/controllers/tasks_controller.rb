class TasksController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create, :update]

  before_action :authenticate_user!

  def create
    task = current_user.tasks.new(task_params)
    if task.save
      render json: { message: 'Task created successfully', task: task }, status: :created
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  def update
    task = current_user.tasks.find(params[:id])
    if task.update(task_params)
      render json: task
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  def my_tasks
    tasks = current_user.tasks
    render json: tasks
  end

  def index
    tasks = Task.all
    render json: tasks
  end

  private

  def task_params
    params.require(:task).permit(:task_title, :description, :assign_date, :due_date, :status, :priority, :assignedUser)
  end
end
