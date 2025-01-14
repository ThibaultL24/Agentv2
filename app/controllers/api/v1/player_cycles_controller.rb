class Api::V1::PlayerCyclesController < ApplicationController
  def index
    @cycles = current_user.player_cycles
    render json: @cycles
  end

  def show
    @cycle = PlayerCycle.find(params[:id])
    render json: {
      cycle: @cycle,
      metrics: calculate_cycle_metrics(@cycle)
    }
  end

  def create
    @cycle = PlayerCycle.new(cycle_params)
    if @cycle.save
      render json: @cycle, status: :created
    else
      render json: @cycle.errors, status: :unprocessable_entity
    end
  end

  def update
    @cycle = PlayerCycle.find(params[:id])
    if @cycle.update(cycle_params)
      render json: @cycle
    else
      render json: @cycle.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @cycle = PlayerCycle.find(params[:id])
    @cycle.destroy
    head :no_content
  end

  private

  def calculate_cycle_metrics(cycle)
    {
      total_energy_spent: cycle.matches.sum(:energyUsed),
      total_profit: cycle.matches.sum(:profit),
      average_profit_per_match: cycle.matches.average(:profit)
    }
  end

  def cycle_params
    params.require(:player_cycle).permit(
      :user_id, :target_profit, :energy_budget
    )
  end
end
