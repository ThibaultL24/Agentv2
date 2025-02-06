class Api::V1::NftsController < ApplicationController
  def index
    @nfts = Nft.joins(item: [:type, :rarity])
               .where(owner: current_user.id.to_s)
               .select('DISTINCT ON (items.id) nfts.*')
               .order('items.id, nfts.created_at DESC')

    render json: {
      nfts: @nfts.map { |nft|
        nft_json = {
          id: nft.id,
          issueId: nft.issueId,
          name: nft.item.name,
          type: nft.item.type.as_json(only: [:id, :name]),
          rarity: nft.item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: nft.item.efficiency,
          supply: nft.item.supply,
          floorPrice: nft.item.floorPrice,
          purchasePrice: nft.purchasePrice
        }

        # Ajouter une clé spécifique selon le type de NFT
        case nft.item.type.name
        when 'Badge'
          { nft_badge: nft_json }
        when 'Contract'
          { nft_contract: nft_json }
        else
          { nft: nft_json }
        end
      }
    }
  end

  def show
    @nft = current_user.nfts
                      .joins(item: [:type, :rarity])
                      .find(params[:id])

    nft_json = {
      id: @nft.id,
      issueId: @nft.issueId,
      name: @nft.item.name,
      type: @nft.item.type.as_json(only: [:id, :name]),
      rarity: @nft.item.rarity.as_json(only: [:id, :name, :color]),
      efficiency: @nft.item.efficiency,
      supply: @nft.item.supply,
      floorPrice: @nft.item.floorPrice,
      purchasePrice: @nft.purchasePrice
    }

    # Utiliser la clé appropriée selon le type de NFT
    response_key = case @nft.item.type.name
                   when 'Badge' then :nft_badge
                   when 'Contract' then :nft_contract
                   else :nft
                   end

    render json: { response_key => nft_json }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found or not accessible" }, status: :not_found
  end

  def create
    rarity = Rarity.find_by(name: nft_params[:rarity])
    return render json: { error: "Select a Rarity for your NFT." }, status: :unprocessable_entity unless rarity

    item = Item.find_by(rarity: rarity)
    return render json: { error: "No item found for this rarity." }, status: :unprocessable_entity unless item

    # Vérifier si l'ID existe déjà
    if current_user.nfts.exists?(issueId: nft_params[:issueId])
      return render json: { error: "You have entered the same Id as an existing NFT in your list, please modify it." }, status: :unprocessable_entity
    end

    @nft = Nft.new(
      item: item,
      issueId: nft_params[:issueId],
      purchasePrice: nft_params[:purchasePrice] || 0.0,
      owner: current_user.id.to_s
    )

    if @nft.save
      render json: {
        nft: {
          id: @nft.id,
          issueId: @nft.issueId,
          name: @nft.item.name,
          type: @nft.item.type.name,
          rarity: @nft.item.rarity.name,
          purchasePrice: @nft.purchasePrice
        }
      }, status: :created
    else
      render json: { error: @nft.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @nft = current_user.nfts.find(params[:id])

    if @nft.update(nft_params)
      nft_json = {
        id: @nft.id,
        issueId: @nft.issueId,
        name: @nft.item.name,
        type: @nft.item.type.as_json(only: [:id, :name]),
        rarity: @nft.item.rarity.as_json(only: [:id, :name, :color]),
        efficiency: @nft.item.efficiency,
        supply: @nft.item.supply,
        floorPrice: @nft.item.floorPrice,
        purchasePrice: @nft.purchasePrice
      }

      # Utiliser la clé appropriée selon le type de NFT
      response_key = case @nft.item.type.name
                     when 'Badge' then :nft_badge
                     when 'Contract' then :nft_contract
                     else :nft
                     end

      render json: { response_key => nft_json }
    else
      render json: { error: @nft.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found or not accessible" }, status: :not_found
  end

  def destroy
    @nft = current_user.nfts.find(params[:id])
    @nft.destroy
    render json: { message: "NFT successfully deleted" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found or not accessible" }, status: :not_found
  end

  private

  def nft_params
    params.require(:nft).permit(:issueId, :purchasePrice)
  end
end
