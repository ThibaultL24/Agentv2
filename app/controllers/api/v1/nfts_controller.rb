class Api::V1::NftsController < ApplicationController
  def index
    @nfts = current_user.nfts.includes(:item)
    render json: @nfts
  end

  def show
    @nft = Nft.find(params[:id])
    calculator = MetricsCalculator.new(@nft.item)

    render json: {
      nft: @nft,
      item_details: @nft.item,
      item_metrics: @nft.item.type.name == 'Badge' ? calculator.calculate_badge_metrics : calculator.calculate_contract_metrics
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "NFT not found" }, status: :not_found
  end

  def create
    @nft = Nft.new(nft_params)
    if @nft.save
      render json: @nft, status: :created
    else
      render json: @nft.errors, status: :unprocessable_entity
    end
  end

  def update
    @nft = Nft.find(params[:id])
    if @nft.update(nft_params)
      render json: @nft
    else
      render json: @nft.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @nft = Nft.find(params[:id])
    @nft.destroy
    head :no_content
  end

  private

  def nft_params
    params.require(:nft).permit(
      :user_id, :item_id, :tokenId, :isStaked
    )
  end
end
