class Api::V1::BadgesController < Api::V1::BaseController
  def index
    @badges = if params[:status] == 'available'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Badge' })
          .where('rarities.name <= ?', current_user.maxRarity)
          .includes(:item_farming, :item_crafting, :item_recharge)
          .order('rarities.name ASC')
    else
      current_user.nfts
                 .joins(item: [:type, :rarity])
                 .includes(item: [:item_farming, :item_crafting, :item_recharge])
                 .where(types: { name: 'Badge' })
                 .order('rarities.name ASC')
    end

    render json: @badges.map { |badge|
      {
        badge: badge,
        metrics: MetricsCalculator.new(badge.respond_to?(:item) ? badge.item : badge).calculate_badge_metrics
      }
    }
  end

  def show
    @badge = if params[:type] == 'item'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Badge' })
          .includes(:item_farming, :item_crafting, :item_recharge)
          .find(params[:id])
    else
      current_user.nfts
                 .joins(item: [:type, :rarity])
                 .includes(item: [:item_farming, :item_crafting, :item_recharge])
                 .where(types: { name: 'Badge' })
                 .find(params[:id])
    end

    render json: {
      badge: @badge,
      metrics: MetricsCalculator.new(@badge.respond_to?(:item) ? @badge.item : @badge).calculate_badge_metrics
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Badge not found or not accessible" }, status: :not_found
  end
end
