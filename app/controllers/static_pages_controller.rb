class StaticPagesController < ApplicationController
  def home
    if signed_in?
      #@micropost  = current_user.microposts.build
      #@feed_items = current_user.feed.paginate(page: params[:page])
      redirect_back_or current_user
    end
  end
  def about 
  end
  def email
  end
  def results
  end
  def help
  end 
end
