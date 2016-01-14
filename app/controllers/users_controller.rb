class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update, :map, :notifications]
  before_action :admin_user,     only: :destroy
  
  def show
    @user = User.find(params[:id])
    @comment = Comment.new
    if current_user?(@user)
      @micropost  = @user.microposts.build
      @location  = @user.locations.build
      @feed_items = @user.feed.paginate(page: params[:page],per_page: 50)
      ###########################################################################
      # Подсчет количества непрочитанных сообщений
      @message_count=0
      @user.mailbox.conversations.each do |conversation|
        if conversation.is_unread?(@user)
          @message_count += 1
        end
      end
      ###########################################################################
      # Позволяет рендерить форму (включить js) для micropost и рендерить новостную ленту плюс количество
      # сообщений, подписок, подписчиков, постов
      respond_to do |format|
        format.html { }
        format.js 
      end
      ###########################################################################
    else
      @microposts = @user.microposts.paginate(page: params[:page],per_page: 50)
    end
  end
  
  def new
    @user = User.new
  end

  def index
    if params[:search] and !params[:search].blank?
      @title = "Результаты поиска по слову"
      @parameter = params[:search]
     	### First 20 users which we found 
      @users = User.search(params[:search]).to(20)
      ###########################################################################
      respond_to do |format|
        format.html { }
        format.js 
      end
      ###########################################################################
    else
     	@title = "10 случайных пользователей"
      @parameter = ""
     	#####  10 Random Users to view ###################
     	@users = User.order("RANDOM()").limit(10)
     	##################################################
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.welcome_email(@user).deliver
      #sign_in @user
      flash[:success] = "Добро пожаловать в ReportsClub.ru! На Ваш почтовый адрес отправлено письмо со ссылкой для подтверждения регистрации"
      redirect_to email_url
    else
      flash[:error] = "Что-то пошло не так!("
      render 'new'
    end
  end

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      flash[:success] = "Добро пожаловать в ReportsClub.ru! Ваш почтовый адрес успешно подтвержден!) Вы можете войти в свой аккаунт"
      redirect_to signin_url
    else
      flash[:error] = "Извините, данный пользователь не существует"
      redirect_to root_url
    end
  end
 
  
  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Профиль пользователя обновлен"
      UserMailer.update_email(@user).deliver
      redirect_to @user
    else
      render 'edit'
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page],per_page: 50)
    if params[:search] and !params[:search].blank?
      @users = @user.followed_users.search(params[:search]).paginate(page: params[:page],per_page: 50)
    end
    ###########################################################################
    respond_to do |format|
      format.html { render 'show_follow' }
      format.js 
    end
    ###########################################################################
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page],per_page: 50)
    if params[:search] and !params[:search].blank?
      @users = @user.followers.search(params[:search]).paginate(page: params[:page],per_page: 50)
    end
    ###########################################################################
    respond_to do |format|
      format.html { render 'show_follow' }
      format.js 
    end
    ###########################################################################
  end

  def map
    @title = "Map"
    @user = User.find(params[:id])
    @users = @user.followed_users

    ### Получение массива из id подписчиков
    @user_ids = []
    @users.select(:id).each do |user|
      @user_ids = @user_ids | [user.id] 
    end
    ###################################################

    # Получение Местоположений подписчиков
    @locations = Location.where(user_id: [@user_ids])
    #@locations= @locations.where("created_at >= ?",(Time.now.midnight - 14.day)).limit(50)
    @locations = @locations.order('created_at DESC')
    ####################################################

  end

  def notifications
    @title = "Notifications"
    @user = User.find(params[:id])

    ### Получение массива из id микропостов пользователя
    @micropost_ids = []
    @user.microposts.select(:id).each do |micropost|
      @micropost_ids = @micropost_ids | [micropost.id] 
    end
    ###################################################

    # Получение Комментариев других пользователей под постами микропользоователя за последние 2 недели
    @comments = Comment.where(micropost_id: [@micropost_ids])
    @comments = @comments.where("user_id != ? AND created_at >= ?",current_user.id,(Time.now.midnight - 14.day)).limit(50)
    @comments = @comments.reverse_order
    ####################################################

    # Получение Лайков других пользователей под постами микропользоователя за последние 2 недели
    @votes = Vote.where(votable_id: [@micropost_ids])
    @votes = @votes.where("voter_id != ? AND created_at >= ?",current_user.id,(Time.now.midnight - 14.day)).limit(50)
    @votes = @votes.order('created_at DESC')
    ####################################################

    ## Подписки пользователя
    #@users_followed = @user.relationships.where("follower_id == ? AND created_at >= ?",current_user.id,(Time.now.midnight - 14.day)).limit(100)
    #@users_followed = @users_followed.reverse_order
    ##########################
    
    ## Подписчики пользователя
    @users_followers = Relationship.where("followed_id == ? AND created_at >= ?",current_user.id,(Time.now.midnight - 14.day)).limit(50)
    @users_followers = @users_followers.reverse_order
    ##########################
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :about, :weblink, :realname, :surname, :city, :password, :password_confirmation, :avatar)
    end
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
