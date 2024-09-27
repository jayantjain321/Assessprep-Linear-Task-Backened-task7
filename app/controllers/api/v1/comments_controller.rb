# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < ApplicationController
      
      include Restoreable
  
      before_action :authenticate_user!
  
      def create
        task = Task.find_by(id: params[:task_id])
        if task
          comment = task.comments.new(comment_params)
          comment.user_id = current_user.id  # Set the user_id to the current user
      
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
          if comment.user_id == current_user.id
            if comment.update(comment_params)
              render json: { message: 'Comment updated successfully', comment: comment }, status: :ok
            else
              render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: 'You are not authorized to update this comment' }, status: :forbidden
          end
        else
          render json: { error: 'Comment not found' }, status: :not_found
        end
      end
  
      def destroy
        comment = Comment.find_by(id: params[:id])
        if comment
          if comment.user_id == current_user.id
            if comment.destroy
              render json: { message: 'Comment deleted successfully' }, status: :ok
            else
              render json: { error: 'Failed to delete comment' }, status: :unprocessable_entity
            end
          else
            render json: { error: 'You are not authorized to delete this comment' }, status: :forbidden
          end
        else
          render json: { error: 'Comment not found' }, status: :not_found
        end
      end
      
      private
      
      def comment_params
        params.require(:comment).permit(:text, :image)
      end
    end
  end
end



