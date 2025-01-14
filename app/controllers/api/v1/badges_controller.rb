class Api::V1::BadgesController < ApplicationController
  def index
    @badges = current_user.badges
    render json: @badges
  end

  def show
    @badge = Badge.find(params[:id])
    render json: {
      badge: @badge,
      performance: calculate_badge_metrics
    }
  end

  def create
    @badge = Badge.new(badge_params)
    if @badge.save
      render json: @badge, status: :created
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  def update
    @badge = Badge.find(params[:id])
    if @badge.update(badge_params)
      render json: @badge
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy
    head :no_content
  end

  private

  def calculate_badge_metrics
    badge_matches = @badge.badge_useds.includes(:match)
    {
      earnings: {
        total_bft: badge_matches.sum { |bu| bu.match.bft_earned },
        average_bft_per_match: badge_matches.average('matches.bft_earned'),
        total_matches: badge_matches.count
      },
      multiplier: @badge.multiplier,
      bft_bonus: @badge.bft_bonus
    }
  end

  def badge_params
    params.require(:badge).permit(
      :nftId, :multiplier, :bft_bonus
    )
  end
end
