class CommentsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: :destroy

  def create

    @micropost = Micropost.find(params[:micropost_id])
    @comment = @micropost.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_to current_user }
        format.js 
      end
    else
      respond_to do |format|
        format.html { redirect_to current_user }
        format.js 
      end
    end
  end

  def destroy
    @comment.destroy
    redirect_to current_user
  end
  
  private
  
    def comment_params
      params.require(:comment).permit(:content,:micropost_id,:user_id)
    end

    def correct_user
      @comment = current_user.comments.find_by(id: params[:id])
      redirect_to root_url if @comment.nil?
    end
end
