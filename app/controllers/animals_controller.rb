class AnimalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_animal, only: %i[show edit update destroy]

  def index
    @animals = current_user.animals.order(:name)
  end

  def show
  end

  def new
    @animal = current_user.animals.build
  end

  def create
    @animal = current_user.animals.build(animal_params)

    if @animal.save
      redirect_to @animal, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @animal.update(animal_params)
      redirect_to @animal, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @animal.destroy
    redirect_to animals_path, notice: t(".success")
  end

  private

  def set_animal
    @animal = current_user.animals.find(params[:id])
  end

  def animal_params
    params.require(:animal).permit(Animal.permitted_attributes)
  rescue ActionController::ParameterMissing
    {}
  end
end
