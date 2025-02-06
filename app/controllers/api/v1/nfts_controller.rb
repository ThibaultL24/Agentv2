class Api::V1::NftsController < ApplicationController
  def index
    @nfts = Nft.joins(item: [:type, :rarity])
               .order('created_at DESC')

    render json: {
      nfts: @nfts.map { |nft|
        {
          id: nft.id,
          issueId: nft.issueId,
          itemId: nft.itemId,
          name: nft.item.name,
          type: nft.item.type.as_json(only: [:id, :name]),
          rarity: nft.item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: nft.item.efficiency,
          supply: nft.item.supply,
          floorPrice: nft.item.floorPrice,
          purchasePrice: nft.purchasePrice,
          owner: nft.owner
        }
      }
    }
  end

  def show
    @nft = Nft.joins(item: [:type, :rarity]).find(params[:id])

    render json: {
      nft: {
        id: @nft.id,
        issueId: @nft.issueId,
        itemId: @nft.itemId,
        name: @nft.item.name,
        type: @nft.item.type.as_json(only: [:id, :name]),
        rarity: @nft.item.rarity.as_json(only: [:id, :name, :color]),
        efficiency: @nft.item.efficiency,
        supply: @nft.item.supply,
        floorPrice: @nft.item.floorPrice,
        purchasePrice: @nft.purchasePrice,
        owner: @nft.owner
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found" }, status: :not_found
  end

  def create
    item = Item.find_by(id: nft_params[:itemId])
    return render json: { error: "Item not found." }, status: :unprocessable_entity unless item

    # Vérifier si l'ID existe déjà
    if current_user.nfts.exists?(issueId: nft_params[:issueId])
      return render json: { error: "You have entered the same Id as an existing NFT in your list, please modify it." }, status: :unprocessable_entity
    end

    @nft = Nft.new(
      itemId: item.id,
      issueId: nft_params[:issueId],
      purchasePrice: nft_params[:purchasePrice] || 0.0,
      owner: current_user.id.to_s
    )

    if @nft.save
      render json: {
        nft: {
          id: @nft.id,
          issueId: @nft.issueId,
          itemId: @nft.itemId,
          name: item.name,
          type: item.type.as_json(only: [:id, :name]),
          rarity: item.rarity.as_json(only: [:id, :name, :color]),
          efficiency: item.efficiency,
          supply: item.supply,
          floorPrice: item.floorPrice,
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
        itemId: @nft.itemId,
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
    params.require(:nft).permit(:itemId, :issueId, :purchasePrice)
  end
end
