# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < ApplicationController

      before_action :find_comment, only: [:update, :destroy] # Find the comment and check ownership before updating or deleting a comment

      # POST /tasks/:task_id/comments  Creates a comment for a specific task
      def create
        task = Task.find_by(id: params[:task_id])  # Find the task to which the comment is being added
        if task
          @comment = task.comments.new(comment_params) # Create a new comment associated with the task
          @comment.user_id = current_user.id  # Associate the comment with the current user
          @comment.save!  #Save the comment 
          LogActionService.log_action(@comment.id, current_user.id, :create, 'Comment')
          render json: { message: 'Comment created successfully', comment: @comment }, status: :created
        else
          raise TaskNotFoundError.new
        end
      end

      # PUT /comments/:id  Updates an existing comment
      def update
        authorize! :update, @comment  # CanCanCan authorization (will throw an AccessDenied exception if unauthorized)
        @comment.update!(comment_params)  #Update the comment
        LogActionService.log_action(@comment.id, current_user.id, :update, 'Comment')
        render json: { message: 'Comment updated successfully', comment: @comment }, status: :ok
      end

      # DELETE /comments/:id Deletes a comment
      def destroy
        authorize! :destroy, @comment   # CanCanCan authorization (will throw an AccessDenied exception if unauthorized)
        @comment.destroy!   # Destroy the comment and return a success 
        LogActionService.log_action(@comment.id, current_user.id, :destroy, 'Comment')
        render json: { message: 'Comment deleted successfully' }, status: :ok
      end

      # GET /comments
      def index
        comments = Comment.order(created_at: :desc).page(params[:page]).per(10) # Retrieves all comments with pagination (10 comments per page)
        render json: { comments: comments }, status: :ok
      end

      private

      # Finds the comment before updating or deleting and if comment raise exception
      def find_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise CommentNotFoundError.new   # Raise custom error if the comment is not found
      end

      # Strong parameters to allow only the permitted attributes
      def comment_params
        params.require(:comment).permit(:text, :image)
      end
    end
  end
end