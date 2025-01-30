class Api::V1::MatchesController < ApplicationController
  def index
    @matches = current_user.matches.includes(:badge_useds)
    render json: @matches
  end

  def show
    @match = Match.find(params[:id])
    badge = @match.badge_useds.first&.badge
    metrics = badge ? MetricsCalculator.new(badge.item).calculate_badge_metrics : {}

    render json: {
      match: @match,
      metrics: {
        combat_stats: {
          damage_dealt: @match.damage_dealt,
          damage_taken: @match.damage_taken,
          critical_hits: @match.critical_hits
        },
        time_efficiency: @match.profit / @match.time,
        badge_metrics: metrics,
        multipliers: {
          bonus: @match.bonusMultiplier,
          perks: @match.perksMultiplier,
          badge: metrics[:efficiency]
        }
      },
      rewards: calculate_match_rewards
    }
  end

  def create
    @match = Match.new(match_params)
    if @match.save
      render json: @match, status: :created
    else
      render json: @match.errors, status: :unprocessable_entity
    end
  end

  def update
    @match = Match.find(params[:id])
    if @match.update(match_params)
      render json: @match
    else
      render json: @match.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @match = Match.find(params[:id])
    @match.destroy
    head :no_content
  end

  private

  def calculate_match_rewards
    {
      currencies: {
        bft: @match.bft_earned,
        flex: @match.flex_earned
      },
      resources: {
        reinforcers: @match.reinforcers_earned,
        variators: @match.variators_earned
      },
      total_profit: @match.profit
    }
  end

  def match_params
    params.require(:match).permit(
      :user_id, :build, :player_type,
      :damage_dealt, :damage_taken, :critical_hits,
      :time, :bft_earned, :flex_earned,
      :reinforcers_earned, :variators_earned,
      :profit, :bonusMultiplier, :perksMultiplier
    )
  end
end
