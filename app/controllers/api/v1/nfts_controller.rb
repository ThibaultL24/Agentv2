class Api::V1::NftsController < ApplicationController
  def index
    @nfts = current_user.nfts.includes(item: [:type, :rarity])
    render json: @nfts.map { |nft|
      {
        id: nft.id,
        issueId: nft.issueId,
        name: nft.item.name,
        type: nft.item.type.name,
        rarity: nft.item.rarity.name,
        efficiency: nft.item.efficiency,
        floorPrice: nft.item.floorPrice,
        purchasePrice: nft.purchasePrice
      }
    }
  end

  def show
    @nft = Nft.find(params[:id])

    render json: {
      nft: {
        id: @nft.id,
        issueId: @nft.issueId,
        name: @nft.item.name,
        type: @nft.item.type.name,
        rarity: @nft.item.rarity.name,
        efficiency: @nft.item.efficiency,
        supply: @nft.item.supply,
        floorPrice: @nft.item.floorPrice,
        purchasePrice: @nft.purchasePrice,
        color: @nft.item.rarity.color
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found" }, status: :not_found
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
      owner: current_user.id
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

    # On ne permet que la modification de issueId et purchasePrice
    if @nft.update(issueId: nft_params[:issueId], purchasePrice: nft_params[:purchasePrice])
      render json: {
        nft: {
          id: @nft.id,
          issueId: @nft.issueId,
          name: @nft.item.name,
          type: @nft.item.type.name,
          rarity: @nft.item.rarity.name,
          purchasePrice: @nft.purchasePrice
        }
      }
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
    params.require(:nft).permit(:rarity, :issueId, :purchasePrice)
  end
end
