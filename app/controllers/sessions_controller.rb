class SessionsController < ApplicationController
def new
end

def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
    	if user.email_confirmed
      	   sign_in user
           #redirect_back_or root_url
           redirect_back_or user
	else
	   flash.now[:error] = 'Please activate your account'
      	   # Sign the user in and redirect to the user's show page.
    	   render 'new'
	end
    else
      	flash.now[:error] = 'Invalid email/password combination' # Not quite right!
      	render 'new'
    end
end

def destroy
   sign_out
   redirect_to root_url	
end
end
