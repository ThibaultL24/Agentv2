class Api::V1::ShowrunnerContractsController < Api::V1::BaseController
  def index
    @contracts = Item.joins(:type, :rarity)
                    .where(types: { name: 'Contract' })
                    .order('rarities.name ASC')

    render json: @contracts.map { |item|
      {
        contract: {
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

  def owned_contracts
    @nfts = Nft.joins(item: [:type, :rarity])
               .where(owner: current_user.id.to_s)
               .where(types: { name: 'Contract' })
               .select('DISTINCT ON (items.id) nfts.*')
               .order('items.id, nfts.created_at DESC')

    render json: @nfts.map { |nft|
      {
        nft_contract: {
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
          rarity: @contract.rarity.as_json(only: [:id, :name, :color]),
          efficiency: @contract.efficiency,
          supply: @contract.supply,
          floorPrice: @contract.floorPrice
        }
      }
    else
      {
        nft_contract: {
          id: @contract.id,
          issueId: @contract.issueId,
          name: @contract.item.name,
          rarity: @contract.item.rarity.as_json(only: [:id, :name, :color]),
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
      owner: current_user.id.to_s,
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
