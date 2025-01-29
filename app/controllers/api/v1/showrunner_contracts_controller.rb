class Api::V1::ShowrunnerContractsController < Api::V1::BaseController
  def index
    @contracts = if params[:status] == 'available'
      Item.joins(:type, :rarity)
          .where(types: { name: 'Showrunner' })
          .where('rarities.name <= ?', current_user.maxRarity)
          .includes(:item_farming, :rarity, :type)
          .order('rarities.name ASC')
    else
      current_user.nfts
                 .joins(item: [:type, :rarity])
                 .includes(item: [:item_farming, :rarity, :type])
                 .where(types: { name: 'Showrunner' })
                 .order('rarities.name ASC')
    end

    render json: @contracts, include: [
      :rarity,
      :type,
      :item_farming
    ]
  end

  def show
    @contract = Item.joins(:type)
                   .where(types: { name: 'Showrunner' })
                   .includes(:item_farming, :rarity, :type)
                   .find(params[:id])

    render json: {
      contract: @contract,
      requirements: @contract.contract_requirements,
      progress: @contract.calculate_contract_progress(current_user)
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Contract not found' }, status: :not_found
  end

  def accept
    @contract = Item.joins(:type)
                   .where(types: { name: 'Showrunner' })
                   .find(params[:id])

    # Vérifier si l'utilisateur a déjà accepté ce contrat
    if current_user.nfts.exists?(itemId: @contract.id, status: ['in_progress', 'completed'])
      return render json: { error: 'Contract already accepted or completed' }, status: :unprocessable_entity
    end

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
      render json: { error: 'Cannot accept this contract', details: nft.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Contract not found' }, status: :not_found
  end

  def complete
    @nft = current_user.nfts
                      .joins(item: :type)
                      .where(types: { name: 'Showrunner' })
                      .find(params[:id])

    return render json: { error: 'Contract is not in progress' }, status: :unprocessable_entity unless @nft.status == 'in_progress'

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
      render json: {
        error: 'Contract requirements not met',
        current_progress: progress
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Contract not found' }, status: :not_found
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
    current_user.update(
      flex_balance: current_user.flex_balance + rewards[:amount] + rewards[:bonus]
    )
  end
end
