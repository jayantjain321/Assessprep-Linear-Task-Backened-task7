# app/controllers/api/v1/comments_controller.rb
module Api
  module V1
    class CommentsController < ApplicationController
      include ErrorHandler
      include Restoreable

      before_action :authenticate_user!
      before_action :find_comment, only: [:update, :destroy]
      before_action :authorize_comment_owner!, only: [:update, :destroy]

      def create
        task = Task.find_by(id: params[:task_id])
        if task
          comment = task.comments.new(comment_params)
          comment.user_id = current_user.id
          comment.save!
          render json: { message: 'Comment created successfully', comment: comment }, status: :created
        else
          raise TaskNotFoundError.new
        end
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def update
        return if performed?
        @comment.update!(comment_params)
        render json: { message: 'Comment updated successfully', comment: @comment }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def destroy
        return if performed?
        @comment.destroy!
        render json: { message: 'Comment deleted successfully' }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end

      def index
        comments = Comment.page(params[:page]).per(10)
        render json: { comments: comments }, status: :ok
      end

      private

      def find_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        raise CommentNotFoundError.new 
      end

      def authorize_comment_owner!
        if @comment.user_id != current_user.id
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      def comment_params
        params.require(:comment).permit(:text, :image)
      end
    end
  end
end