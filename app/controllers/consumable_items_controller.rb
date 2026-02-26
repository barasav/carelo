class ConsumableItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consumable_item, only: %i[show edit update destroy]

  def index
    @consumable_items = current_user.consumable_items.order(:name)
  end

  def show
  end

  def new
    @consumable_item = current_user.consumable_items.build
  end

  def create
    @consumable_item = current_user.consumable_items.build(consumable_item_params)

    if @consumable_item.save
      redirect_to @consumable_item, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @consumable_item.update(consumable_item_params)
      redirect_to @consumable_item, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @consumable_item.destroy
    redirect_to consumable_items_path, notice: t(".success")
  end

  private

  def set_consumable_item
    @consumable_item = current_user.consumable_items.find_by(id: params[:id])
    head :not_found unless @consumable_item
  end

  def consumable_item_params
    params.require(:consumable_item).permit(ConsumableItem.permitted_attributes)
  rescue ActionController::ParameterMissing
    {}
  end
end
