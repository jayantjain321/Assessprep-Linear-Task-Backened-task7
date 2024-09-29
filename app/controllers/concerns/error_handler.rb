class TaskNotFoundError < StandardError; end

class CommentNotFoundError < StandardError; end

class ProjectNotFoundError < StandardError; end

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from TaskNotFoundError, with: :task_not_found
    rescue_from CommentNotFoundError, with: :comment_not_found
    rescue_from ProjectNotFoundError, with: :project_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  end

  def project_not_found
    render json: { error: 'Project not found' }, status: :not_found
  end

  def task_not_found
    render json: { error: 'Task not found' }, status: :not_found
  end

  def comment_not_found
    render json: { error: 'Comment not found' }, status: :not_found
  end

  def unprocessable_entity(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end

