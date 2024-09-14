class TasksController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create, :update]

  before_action :authenticate_user!

  def create
    user = User.find_by(id: params[:user_id])
    project = Project.find_by(id: params[:project_id])
  
    if user.nil?
      render json: { error: 'User does not exist' }, status: :not_found
      return
    end
  
    if project.nil?
      render json: { error: 'Project does not exist' }, status: :not_found
      return
    end
  
    task = Task.new(task_params.merge(user_id: user.id, project_id: project.id))
  
    if task.save
      render json: { message: 'Task created successfully', task: task }, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  

  def update
    task = Task.find_by(id: params[:id])
    if task.nil?
      render json: { error: 'Task not found' }, status: :not_found
    elsif task.update(task_params)
      render json: task
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  def index
    tasks = Task.all
    render json: tasks
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
    params.require(:task).permit(:task_title, :description, :assign_date, :due_date, :status, :priority, :assignedUser)
  end
end
