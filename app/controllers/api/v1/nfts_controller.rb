class Api::V1::NftsController < ApplicationController
  def index
    @nfts = current_user.nfts.includes(:item)
    render json: @nfts
  end

  def show
    @nft = Nft.find(params[:id])
    render json: {
      nft: @nft,
      item_details: @nft.item,
      metrics: calculate_nft_metrics
    }
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

  def calculate_nft_metrics
    matches = @nft.badge_useds.includes(:match)
    {
      usage: {
        total_matches: matches.count,
        total_profit: matches.sum { |bu| bu.match.profit },
        total_bft_earned: matches.sum { |bu| bu.match.bft_earned }
      },
      item_stats: @nft.item.attributes.slice('efficiency', 'supply', 'floorPrice')
    }
  end

  def nft_params
    params.require(:nft).permit(
      :user_id, :item_id, :tokenId, :isStaked
    )
  end
end
