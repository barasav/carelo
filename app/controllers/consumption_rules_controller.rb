class ConsumptionRulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_animal_for_new, only: %i[new create]
  before_action :set_consumption_rule, only: %i[edit update destroy]

  def new
    @consumption_rule = @animal.consumption_rules.build
  end

  def create
    consumable = find_feeding_consumable(consumption_rule_params[:consumable_item_id])

    unless consumable
      @consumption_rule = @animal.consumption_rules.build(consumption_rule_params)
      @consumption_rule.errors.add(:consumable_item_id, :blank)

      return render :new, status: :unprocessable_entity
    end

    @consumption_rule = @animal.consumption_rules.build(
      consumption_rule_params.merge(consumable_item_id: consumable.id)
    )

    if @consumption_rule.save
      redirect_to @animal, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params = consumption_rule_params

    if params.key?(:consumable_item_id)
      consumable = find_feeding_consumable(params[:consumable_item_id])

      unless consumable
        @consumption_rule.assign_attributes(params)
        @consumption_rule.errors.add(:consumable_item_id, :blank)

        return render :edit, status: :unprocessable_entity
      end
      params = params.merge(consumable_item_id: consumable.id)
    end

    if @consumption_rule.update(params)
      redirect_to @consumption_rule.care_subject, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    animal = @consumption_rule.care_subject
    @consumption_rule.destroy

    redirect_to animal, notice: t(".success")
  end

  private

  def set_animal_for_new
    @animal = current_user.animals.find(params[:animal_id])
  end

  def set_consumption_rule
    @consumption_rule = ConsumptionRule.find(params[:id])
    @animal = @consumption_rule.care_subject
    head :not_found unless @animal.is_a?(Animal) && @animal.user_id == current_user.id
  end

  def consumption_rule_params
    params.require(:consumption_rule).permit(ConsumptionRule.permitted_attributes)
  rescue ActionController::ParameterMissing
    {}
  end

  def find_feeding_consumable(consumable_item_id)
    return nil if consumable_item_id.blank?

    current_user.consumable_items.for_food.find_by(id: consumable_item_id)
  end
end
