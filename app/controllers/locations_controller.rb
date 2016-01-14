class LocationsController < ApplicationController
  before_action :signed_in_user
  before_action :remove_locations, only: :create
  before_action :correct_user,   only: :destroy
  def create
    @location = current_user.locations.build(location_params)
    if @location.save
      flash[:success] = "Местоположение добавлено"
      #redirect_to root_url
    else
      @location = []
      #redirect_to root_url
    end
    redirect_to current_user
  end

  def destroy
    @location.destroy
    #redirect_to root_url
    redirect_to current_user
  end
  
  private
  
    def location_params
      params.require(:location).permit(:latitude,:longtitude)
    end

    def remove_locations
      current_user.locations.each do |receipt|
        receipt.destroy
      end
    end

    def correct_user
      @location = current_user.locations.find_by(id: params[:id])
      redirect_to root_url if @location.nil?
    end
end
