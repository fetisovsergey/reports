class UserMailer < ActionMailer::Base
  default from: 'info@reportsclub.ru'
 def welcome_email(user)
    @user = user
    @url  = 'http://reportsclub.ru/signin'
    mail(to: @user.email, subject: 'Добро пожаловать на ReportsClub.ru!')
  end
 def update_email(user)
    @user = user
    mail(to: @user.email, subject: 'Изменение данных учетной записи на ReportsClub.ru')
  end
end
