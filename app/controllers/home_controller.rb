class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @plants = current_user.plants.order(:name)
    @animals = current_user.animals.order(:name)
  end
end
