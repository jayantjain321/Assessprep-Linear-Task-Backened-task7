class CommentsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: [:create, :destroy, :update]

    def create
      task = Task.find_by(id: params[:task_id])
      if task
        comment = task.comments.new(comment_params)
  
        if comment.save
          render json: { message: 'Comment created successfully', comment: comment }, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Task not found' }, status: :not_found
      end
    end

    def update
      comment = Comment.find_by(id: params[:id])
  
      if comment
        if comment.update(comment_params)
          render json: { message: 'Comment updated successfully', comment: comment }, status: :ok
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Comment not found' }, status: :not_found
      end
    end

    def destroy
      comment = Comment.find_by(id: params[:id])
      if comment
        if comment.destroy
          render json: { message: 'Comment deleted successfully' }, status: :ok
        else
          render json: { error: 'Failed to delete comment' }, status: :unprocessable_entity
        end
      else
        render json: { error: 'Comment not found' }, status: :not_found
      end
    end
    
    private
    
    def comment_params
      params.require(:comment).permit(:text, :image, :task_id)
    end
end



