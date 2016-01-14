class MicropostsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: :destroy
 
  def index
    @microposts = Micropost.all
    @comment = @micropost.comments.build(params[:content])
    @comment.user = current_user
  end  

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Сообщение создано"
      #redirect_to root_url
    else
      @feed_items = []
      #redirect_to root_url
    end
    redirect_to current_user
  end

  def destroy
    @micropost.destroy
    #redirect_to root_url
    redirect_to current_user
  end

  def upvote
    @post = Micropost.find(params[:id])
    @post.save
    @post.liked_by current_user
    respond_to do |format|
      format.html { redirect_to :back }
      #format.json { render json: { count: @post.votes.count } }
      format.js 
    end
  end
  def downvote
     @post = Micropost.find(params[:id])
     @post.save
     @post.unliked_by current_user
     #@post.save
     respond_to do |format|
       format.html { redirect_to :back }
       format.js 
    end
  end
  
  private
  
    def micropost_params
      params.require(:micropost).permit(:content, :photo,:latitude,:longtitude)
    end
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
