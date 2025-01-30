class Api::V1::ShowrunnerContractsController < Api::V1::BaseController
  def index
    puts "\nUtilisateur connecté:"
    puts "- ID: #{current_user.id}"
    puts "- Username: #{current_user.username}"
    puts "- MaxRarity: #{current_user.maxRarity}"

    if params[:status] == 'available'
      # On récupère les IDs des contrats déjà possédés
      owned_item_ids = current_user.nfts
                                 .joins(item: :type)
                                 .where(types: { name: 'Contract' })
                                 .select(:itemId)
                                 .distinct
                                 .pluck(:itemId)

      puts "\nContrats possédés (IDs): #{owned_item_ids}"

      # On récupère les contrats disponibles
      @contracts = Item.joins(:type, :rarity)
                      .where(types: { name: 'Contract' })
                      .where.not(id: owned_item_ids)
                      .order('rarities.name ASC')

      puts "Contrats disponibles: #{@contracts.map { |b| "#{b.name} (#{b.rarity.name})" }}"

      render json: @contracts.map { |item|
        {
          contract: {
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
      # On récupère les contrats possédés par l'utilisateur
      @nfts = current_user.nfts
                         .joins(item: [:type, :rarity])
                         .where(types: { name: 'Contract' })
                         .select('DISTINCT ON (items.id) nfts.*')
                         .order('items.id, nfts.created_at DESC')

      puts "\nContrats possédés: #{@nfts.map { |nft| "#{nft.item.name} (#{nft.item.rarity.name})" }}"

      render json: @nfts.map { |nft|
        {
          contract: {
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
    @contract = if params[:type] == 'item'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Contract' })
          .find(params[:id])
    else
      current_user.nfts
                 .joins(item: [:type, :rarity])
                 .where(types: { name: 'Contract' })
                 .find(params[:id])
    end

    render json: if params[:type] == 'item'
      {
        contract: {
          id: @contract.id,
          name: @contract.name,
          rarity: @contract.rarity.name,
          efficiency: @contract.efficiency,
          supply: @contract.supply,
          floorPrice: @contract.floorPrice
        }
      }
    else
      {
        contract: {
          id: @contract.id,
          issueId: @contract.issueId,
          name: @contract.item.name,
          rarity: @contract.item.rarity.name,
          efficiency: @contract.item.efficiency,
          supply: @contract.item.supply,
          floorPrice: @contract.item.floorPrice,
          purchasePrice: @contract.purchasePrice
        }
      }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Contract not found or not accessible" }, status: :not_found
  end

  def accept
    @contract = Item.joins(:type)
                   .where(types: { name: 'Contract' })
                   .find(params[:id])

    # Vérifier si l'utilisateur a déjà ce contrat
    if current_user.nfts.exists?(itemId: @contract.id)
      return render json: { error: 'Contract already owned' }, status: :unprocessable_entity
    end

    nft = Nft.new(
      itemId: @contract.id,
      owner: current_user.id,
      purchasePrice: @contract.floorPrice,
      issueId: Nft.where(itemId: @contract.id).count + 1
    )

    if nft.save
      render json: {
        message: 'Contract accepted successfully',
        contract: {
          id: nft.id,
          name: @contract.name,
          rarity: @contract.rarity.name,
          efficiency: @contract.efficiency,
          purchasePrice: nft.purchasePrice,
          issueId: nft.issueId
        }
      }
    else
      render json: { error: 'Cannot accept this contract', details: nft.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Contract not found' }, status: :not_found
  end
end
