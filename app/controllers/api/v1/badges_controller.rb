class Api::V1::BadgesController < Api::V1::BaseController
  def index
    @badges = Item.joins(:type, :rarity)
                 .where(types: { name: 'Badge' })
                 .order('rarities.name ASC')

    render json: @badges.map { |item|
      {
        badge: {
          id: item.id,
          name: item.name,
          rarity: item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: item.efficiency,
          supply: item.supply,
          floorPrice: item.floorPrice
        }
      }
    }
  end

  def owned_badges
    @nfts = Nft.joins(item: [:type, :rarity])
               .where(owner: current_user.id.to_s)
               .where(types: { name: 'Badge' })
               .select('DISTINCT ON (items.id) nfts.*')
               .order('items.id, nfts.created_at DESC')

    render json: @nfts.map { |nft|
      {
        nft_badge: {
          id: nft.id,
          issueId: nft.issueId,
          name: nft.item.name,
          rarity: nft.item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: nft.item.efficiency,
          supply: nft.item.supply,
          floorPrice: nft.item.floorPrice,
          purchasePrice: nft.purchasePrice
        }
      }
    }
  end

  def show
    @badge = if params[:type] == 'item'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Badge' })
          .find(params[:id])
    else
      current_user.nfts
                 .joins(item: [:type, :rarity])
                 .where(types: { name: 'Badge' })
                 .find(params[:id])
    end

    calculator = MetricsCalculator.new(@badge.item, current_user)
    metrics = calculator.calculate_badge_metrics

    render json: if params[:type] == 'item'
      {
        badge: {
          id: @badge.id,
          name: @badge.name,
          rarity: @badge.rarity.as_json(only: [:id, :name, :color]),
          efficiency: @badge.efficiency,
          supply: @badge.supply,
          floorPrice: @badge.floorPrice
        },
        roi_analysis: {
          matches_to_roi: calculate_matches_to_roi(metrics),
          daily_matches_possible: metrics[:matches_per_day],
          estimated_days_to_roi: calculate_days_to_roi(metrics)
        },
        metrics: metrics
      }
    else
      {
        nft_badge: {
          id: @badge.id,
          issueId: @badge.issueId,
          name: @badge.item.name,
          rarity: @badge.item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: @badge.item.efficiency,
          supply: @badge.item.supply,
          floorPrice: @badge.item.floorPrice,
          purchasePrice: @badge.purchasePrice
        },
        roi_analysis: {
          matches_to_roi: calculate_matches_to_roi(metrics),
          daily_matches_possible: metrics[:matches_per_day],
          estimated_days_to_roi: calculate_days_to_roi(metrics)
        },
        metrics: metrics
      }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Badge not found or not accessible" }, status: :not_found
  end

  private

  def calculate_matches_to_roi(metrics)
    return 0 if metrics[:daily_profit] <= 0
    (@badge.item.floorPrice / metrics[:bft_per_charge]).ceil
  end

  def calculate_days_to_roi(metrics)
    matches = calculate_matches_to_roi(metrics)
    return Float::INFINITY if matches == 0
    (matches.to_f / metrics[:matches_per_day]).ceil
  end
end
