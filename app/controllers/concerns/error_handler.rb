#Custom error classes 
class TaskNotFoundError < StandardError; end
class CommentNotFoundError < StandardError; end
class ProjectNotFoundError < StandardError; end

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from TaskNotFoundError, with: :task_not_found  # Handle custom and ActiveRecord errors with specific methods
    rescue_from CommentNotFoundError, with: :comment_not_found
    rescue_from ProjectNotFoundError, with: :project_not_found
    rescue_from CanCan::AccessDenied, with: :access_denied
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  end

  # Custom error handling for access denied
  def access_denied(exception)
    render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
  end

  # Custom error handling for Project not found
  def project_not_found
    render json: { error: 'Project not found' }, status: :not_found
  end

  # Custom error handling for Task not found
  def task_not_found
    render json: { error: 'Task not found' }, status: :not_found
  end

  # Custom error handling for Comment not found
  def comment_not_found
    render json: { error: 'Comment not found' }, status: :not_found
  end

  # Handling ActiveRecord::RecordInvalid errors
  def unprocessable_entity(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end

