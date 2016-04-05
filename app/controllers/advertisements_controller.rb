class AdvertisementsController < ApplicationController
  protect_from_forgery

  def show
    finished :adv
    redirect_to 'https://jinshuju.net/f/uYwnaM'
  end
end
