class Api::V1::ShowrunnerContractsController < Api::V1::BaseController
  def index
    @contracts = if params[:status] == 'available'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Showrunner' })
          .where('rarities.name <= ?', current_user.maxRarity)
    else
      current_user.nfts
                 .joins(item: :type)
                 .where(types: { name: 'Showrunner' })
    end

    render json: @contracts
  end

  def show
    @contract = Item.joins(:type)
                   .where(types: { name: 'Showrunner' })
                   .find(params[:id])

    render json: {
      contract: @contract,
      requirements: @contract.contract_requirements,
      progress: @contract.calculate_contract_progress(current_user)
    }
  end

  def accept
    @contract = Item.joins(:type)
                   .where(types: { name: 'Showrunner' })
                   .find(params[:id])

    nft = Nft.new(
      itemId: @contract.id,
      owner: current_user.id,
      purchasePrice: @contract.floorPrice,
      status: 'in_progress'
    )

    if nft.save
      render json: {
        message: 'Contract accepted successfully',
        contract: nft
      }
    else
      render json: { error: 'Cannot accept this contract' }, status: :unprocessable_entity
    end
  end

  def complete
    @nft = current_user.nfts
                      .joins(item: :type)
                      .where(types: { name: 'Showrunner' })
                      .find(params[:id])

    @contract = @nft.item
    progress = @contract.calculate_contract_progress(current_user)

    if progress[:completion_percentage] >= 100
      @nft.update(status: 'completed')
      award_contract_rewards(@contract)
      render json: {
        message: 'Contract completed successfully',
        contract: @nft,
        rewards: calculate_rewards(@contract)
      }
    else
      render json: { error: 'Contract requirements not met' }, status: :unprocessable_entity
    end
  end

  private

  def calculate_rewards(contract)
    requirements = contract.contract_requirements
    progress = contract.calculate_contract_progress(current_user)

    bonus = if progress[:current_win_rate] >= requirements[:min_win_rate] + 10
      (requirements[:reward_amount] * 0.1).round(2)
    else
      0
    end

    {
      amount: requirements[:reward_amount],
      currency: 'FLEX',
      bonus: bonus
    }
  end

  def award_contract_rewards(contract)
    rewards = calculate_rewards(contract)
    # Logique pour attribuer les récompenses à l'utilisateur
    # À implémenter selon votre système de récompenses
  end
end
