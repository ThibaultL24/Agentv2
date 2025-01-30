class Api::V1::PlayerCyclesController < ApplicationController
  def index
    @cycles = current_user.player_cycles
    render json: @cycles
  end

  def show
    @cycle = PlayerCycle.find(params[:id])
    badge_metrics = calculate_cycle_badge_metrics(@cycle)

    render json: {
      cycle: @cycle,
      metrics: {
        total_energy_spent: @cycle.matches.sum(:energyUsed),
        total_profit: @cycle.matches.sum(:profit),
        average_profit_per_match: @cycle.matches.average(:profit),
        badge_performance: badge_metrics
      }
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

  def calculate_cycle_badge_metrics(cycle)
    badges_used = cycle.matches.joins(:badge_useds).group('badge_useds.badge_id').count

    badges_used.map do |badge_id, usage_count|
      badge = Badge.find(badge_id)
      calculator = MetricsCalculator.new(badge.item)
      metrics = calculator.calculate_badge_metrics

      {
        badge_id: badge_id,
        usage_count: usage_count,
        efficiency: metrics[:efficiency],
        total_profit_contribution: cycle.matches
          .joins(:badge_useds)
          .where(badge_useds: { badge_id: badge_id })
          .sum(:profit),
        metrics: metrics
      }
    end
  end

  def cycle_params
    params.require(:player_cycle).permit(
      :user_id, :target_profit, :energy_budget
    )
  end
end
