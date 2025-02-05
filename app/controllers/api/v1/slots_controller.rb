class Api::V1::SlotsController < ApplicationController
  def index
    @slots = Slot.all
    render json: @slots
  end

  def show
    @slot = Slot.find(params[:id])
    render json: @slot
  end

  private

  def calculate_slot_metrics(slot)
    user_slots = slot.user_slots
    {
      average_profit: user_slots.joins(:matches).average('matches.profit'),
      energy_efficiency: calculate_energy_efficiency(user_slots),
      usage_count: user_slots.count
    }
  end

  def calculate_energy_efficiency(user_slots)
    matches = Match.where(slots: user_slots.pluck(:id))
    return 0 if matches.empty?
    matches.sum(:profit) / matches.sum(:energyUsed)
  end
end
