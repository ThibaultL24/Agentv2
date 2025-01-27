class Api::V1::BadgesController < Api::V1::BaseController
  def index
    @badges = current_user.nfts
    render json: @badges
  end

  def show
    @badge = Nft.find(params[:id])
    render json: {
      badge: @badge,
      roi_analysis: calculate_roi_metrics
    }
  end

  def create
    @badge = Nft.new(badge_params)
    if @badge.save
      render json: @badge, status: :created
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  def update
    @badge = Nft.find(params[:id])
    if @badge.update(badge_params)
      render json: @badge
    else
      render json: @badge.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @badge = Nft.find(params[:id])
    @badge.destroy
    head :no_content
  end

  private

  def badge_params
    params.require(:badge).permit(
      :issueId, :itemId, :owner, :purchasePrice  # Uniquement les champs de la table nfts
    )
  end

  def calculate_roi_metrics
    {
      matches_to_roi: calculate_matches_to_roi,
      daily_matches_possible: calculate_daily_matches_possible,
      estimated_days_to_roi: calculate_estimated_days_to_roi
    }
  end

  def calculate_matches_to_roi
    item = @badge.item
    crafting = item.item_crafting
    recharge = item.item_recharge

    # Coûts initiaux
    badge_cost = crafting.flex_craft
    recharge_cost = recharge.unit_charge_cost

    # Efficacité BFT
    bft_per_recharge = item.efficiency * recharge.max_energy_recharge

    # Calcul selon la formule
    total_badge_cost = badge_cost + recharge_cost
    recharges_needed = ((total_badge_cost / bft_per_recharge) - 1)
    total_recharge_cost = recharges_needed * recharge_cost

    total_cost = total_badge_cost + total_recharge_cost
    (total_cost / bft_per_recharge).ceil
  end

  def calculate_daily_matches_possible
    average_match_duration = 10 # minutes
    (24 * 60) / average_match_duration
  end

  def calculate_estimated_days_to_roi
    (calculate_matches_to_roi.to_f / calculate_daily_matches_possible).ceil
  end
end
