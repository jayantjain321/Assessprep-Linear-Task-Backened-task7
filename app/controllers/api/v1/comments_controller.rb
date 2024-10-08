# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < ApplicationController

      # Find the comment and check ownership before updating or deleting a comment
      before_action :find_comment, only: [:update, :destroy]
      before_action :authorize_comment_owner!, only: [:update, :destroy]

      # POST /tasks/:task_id/comments  Creates a comment for a specific task
      def create

        # Find the task to which the comment is being added
        task = Task.find_by(id: params[:task_id])
        if task

          # Create a new comment associated with the task
          comment = task.comments.new(comment_params)
          comment.user_id = current_user.id  # Associate the comment with the current user
          comment.save!  #Save the comment 
          render json: { message: 'Comment created successfully', comment: comment }, status: :created
        else
          raise TaskNotFoundError.new
        end
      rescue ActiveRecord::RecordInvalid => e
        raise e  # Raise the validation error to be handled globally
      end

      # PUT /comments/:id  Updates an existing comment
      def update
        @comment.update!(comment_params)  #Update the comment
        render json: { message: 'Comment updated successfully', comment: @comment }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      # DELETE /comments/:id Deletes a comment
      def destroy
        @comment.destroy!   # Destroy the comment and return a success message
        render json: { message: 'Comment deleted successfully' }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      # GET /comments
      # Retrieves all comments with pagination (10 comments per page)
      def index
        comments = Comment.ordered_by_creation.page(params[:page]).per(10)
        render json: { comments: comments }, status: :ok
      end

      private

      # Finds a comment by ID before updating or deleting it
      def find_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise CommentNotFoundError.new   # Raise custom error if the comment is not found
      end

      # Ensures only the owner of the comment can update or delete it
      def authorize_comment_owner!
        if @comment.user_id != current_user.id

          # Return a forbidden error if the current user is not authorized to modify the comment
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      # Strong parameters to allow only the permitted attributes
      def comment_params
        params.require(:comment).permit(:text, :image)
      end
    end
  end
end