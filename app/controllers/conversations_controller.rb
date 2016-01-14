class ConversationsController < ApplicationController
  before_action :signed_in_user
  before_action :following_users, only: [:new]
  helper_method :mailbox, :conversation

  def create
    recipient_names = conversation_params(:recipients).split(',')
    if recipient_names.include?(current_user.name)
      recipient_names.delete(current_user.name)
    end
    recipients = User.where(name: recipient_names).all
    if recipients.any? and !conversation_params(:body).blank?
      conversation = current_user.send_message(recipients, *conversation_params(:body, :subject)).conversation
      redirect_to conversation_path(conversation)
    else
      redirect_to :conversations
    end
  end

  def reply
    current_user.reply_to_conversation(conversation, *message_params(:body, :recipients))
    #redirect_to conversation_path(conversation)
    respond_to do |format|
       format.html { redirect_to conversation_path(conversation) }
       format.js 
    end
  end

  def trash
      a = 0
      conversation.recipients.each do |recipient|
        if !conversation.is_completely_trashed?(recipient)
          a += 1
        end
        if a==2
          conversation.move_to_trash(current_user)
          break
        end
      end 
      if a==1
        conversation.destroy
      end
    #conversation.move_to_trash(current_user)
    redirect_to :conversations
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :conversations
  end
  def emptytrash
   conversation.destroy
   redirect_to :conversations
  end
  private

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end

  def conversation_params(*keys)
    fetch_params(:conversation, *keys)
  end

  def message_params(*keys)
    fetch_params(:message, *keys)
  end

  def fetch_params(key, *subkeys)
    params[key].instance_eval do
      case subkeys.size
      when 0 then self
      when 1 then self[subkeys.first]
      else subkeys.map{|k| self[k] }
      end
    end
  end
#To show list of followers and followed users
  def following_users
    @usersfollowed = current_user.followed_users.to(1000)
    if params[:search] and !params[:search].blank?
      @usersfollowed = current_user.followed_users.where("name like ? or realname like ? or surname like ?",
        "#{params[:search]}%","#{params[:search]}%","#{params[:search]}%").to(50)
    end
  end
  def new
    ###########################################################################
    respond_to do |format|
      format.html { render :new }
      format.js 
    end
    ###########################################################################
  end

end
