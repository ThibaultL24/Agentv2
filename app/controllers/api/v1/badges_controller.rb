class Api::V1::BadgesController < Api::V1::BaseController
  def index
    # Debug: Afficher les infos de l'utilisateur connecté
    puts "\nUtilisateur connecté:"
    puts "- ID: #{current_user.id}"
    puts "- Username: #{current_user.username}"
    puts "- MaxRarity: #{current_user.maxRarity}"

    if params[:status] == 'available'
      # On récupère les IDs des badges déjà possédés
      owned_item_ids = current_user.nfts
                                 .joins(item: :type)
                                 .where(types: { name: 'Badge' })
                                 .select(:itemId)
                                 .distinct
                                 .pluck(:itemId)

      puts "\nBadges possédés (IDs): #{owned_item_ids}"

      # On récupère les badges disponibles
      @badges = Item.joins(:type, :rarity)
                   .where(types: { name: 'Badge' })
                   .where.not(id: owned_item_ids)
                   .order('rarities.name ASC')

      puts "Badges disponibles: #{@badges.map { |b| "#{b.name} (#{b.rarity.name})" }}"

      render json: @badges.map { |item|
        {
          badge: {
            id: item.id,
            name: item.name,
            rarity: item.rarity.name,
            efficiency: item.efficiency,
            supply: item.supply,
            floorPrice: item.floorPrice
          }
        }
      }
    else
      # On récupère les badges possédés par l'utilisateur
      @nfts = Nft.joins(item: [:type, :rarity])
                 .where(owner: current_user.id)
                 .where(types: { name: 'Badge' })
                 .select('DISTINCT ON (items.id) nfts.*')
                 .order('items.id, nfts.created_at DESC')

      puts "\nBadges possédés: #{@nfts.map { |nft| "#{nft.item.name} (#{nft.item.rarity.name})" }}"

      render json: @nfts.map { |nft|
        {
          badge: {
            id: nft.id,
            issueId: nft.issueId,
            name: nft.item.name,
            rarity: nft.item.rarity.name,
            efficiency: nft.item.efficiency,
            supply: nft.item.supply,
            floorPrice: nft.item.floorPrice,
            purchasePrice: nft.purchasePrice
          }
        }
      }
    end
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
          rarity: @badge.rarity.name,
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
        badge: {
          id: @badge.id,
          issueId: @badge.issueId,
          name: @badge.item.name,
          rarity: @badge.item.rarity.name,
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
