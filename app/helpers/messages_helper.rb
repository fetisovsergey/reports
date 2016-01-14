module MessagesHelper
  def recipients_options
    s = ''
    current_user.followed_users.each do |user|
      s << "<option value='#{user.name}'>#{user.name}</option>"
    end
    s.html_safe
  end
end
