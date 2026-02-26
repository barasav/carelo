class StockLotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_consumable_item, only: %i[new create]
  before_action :set_stock_lot, only: %i[edit update destroy]

  def index
    @stock_lots = current_user.stock_lots.includes(:consumable_item).order(created_at: :desc)
  end

  def new
    @stock_lot = current_user.stock_lots.build(consumable_item: @consumable_item)
  end

  def create
    @stock_lot = current_user.stock_lots.build(stock_lot_params.merge(consumable_item: @consumable_item))

    if @stock_lot.save
      redirect_to stock_lots_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stock_lot.update(stock_lot_params)
      redirect_to stock_lots_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @stock_lot.destroy

    redirect_to stock_lots_path, notice: t(".success")
  end

  private

  def set_consumable_item
    @consumable_item = current_user.consumable_items.find_by(id: params[:consumable_item_id])
    head :not_found unless @consumable_item
  end

  def set_stock_lot
    @stock_lot = current_user.stock_lots.find(params[:id])
  end

  def stock_lot_params
    params.require(:stock_lot).permit(%i[quantity unit purchased_on expires_on notes])
  rescue ActionController::ParameterMissing
    {}
  end
end
