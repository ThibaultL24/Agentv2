class Api::V1::BadgesController < Api::V1::BaseController
  def index
    # Debug: Afficher les infos de l'utilisateur connecté
    puts "\nUtilisateur connecté:"
    puts "- ID: #{current_user.id}"
    puts "- Username: #{current_user.username}"
    puts "- MaxRarity: #{current_user.maxRarity}"

    if params[:status] == 'available'
      # On récupère les IDs des badges déjà possédés (en évitant les doublons)
      owned_item_ids = current_user.nfts
                                 .joins(item: :type)
                                 .where(types: { name: 'Badge' })
                                 .select(:itemId)
                                 .distinct
                                 .pluck(:itemId)

      puts "\nItems possédés (IDs): #{owned_item_ids}"

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
            issueId: 1,
            name: item.name,
            rarity: item.rarity.name,
            purchasePrice: item.floorPrice
          },
          metrics: {
            rarity: item.rarity.name,
            floorPrice: item.floorPrice,
            efficiency: 0.1,
            supply: item.supply,
            ratio: 1.0,
            farming_time: 600
          }
        }
      }
    else
      # On récupère les badges possédés par l'utilisateur (en évitant les doublons)
      @nfts = current_user.nfts
                         .joins(item: [:type, :rarity])
                         .where(types: { name: 'Badge' })
                         .select('DISTINCT ON (items.id) nfts.*')
                         .order('items.id, nfts.created_at DESC')

      puts "\nNFTs possédés: #{@nfts.map { |nft| "#{nft.item.name} (#{nft.item.rarity.name})" }}"

      render json: @nfts.map { |nft|
        {
          badge: {
            id: nft.id,
            issueId: nft.issueId,
            name: nft.item.name,
            rarity: nft.item.rarity.name,
            purchasePrice: nft.purchasePrice
          },
          metrics: {
            rarity: nft.item.rarity.name,
            floorPrice: nft.item.floorPrice,
            efficiency: 0.1,
            supply: nft.item.supply,
            ratio: 1.0,
            farming_time: 600
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

    render json: if params[:type] == 'item'
      {
        badge: {
          id: @badge.id,
          name: @badge.name,
          rarity: @badge.rarity.name,
          supply: @badge.supply,
          floorPrice: @badge.floorPrice
        },
        metrics: {
          rarity: @badge.rarity.name,
          floorPrice: @badge.floorPrice,
          efficiency: 0.1,
          supply: @badge.supply,
          ratio: 1.0,
          farming_time: 600
        }
      }
    else
      {
        badge: {
          id: @badge.id,
          issueId: @badge.issueId,
          name: @badge.item.name,
          rarity: @badge.item.rarity.name,
          purchasePrice: @badge.purchasePrice
        },
        metrics: {
          rarity: @badge.item.rarity.name,
          floorPrice: @badge.item.floorPrice,
          efficiency: 0.1,
          supply: @badge.item.supply,
          ratio: 1.0,
          farming_time: 600
        }
      }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Badge not found or not accessible" }, status: :not_found
  end
end
