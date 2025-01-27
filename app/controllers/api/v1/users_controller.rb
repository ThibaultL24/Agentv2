class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users
  end

  def show
    @user = User.find(params[:id])
    render json: {
      user: @user,
      stats: calculate_user_stats,
      assets: get_user_assets
    }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    head :no_content
  end

  private

  def calculate_user_stats
    matches = @user.matches
    {
      total_matches: matches.count,
      total_profit: matches.sum(:profit),
      total_bft: matches.sum(:bft_earned),
      total_flex: matches.sum(:flex_earned),
      level_stats: {
        current_level: @user.level,
        experience: @user.experience
      }
    }
  end

  def get_user_assets
    {
      builds: @user.user_builds.count,
      badges: @user.badges.count,
      slots: @user.user_slots.count
    }
  end

  def user_params
    params.require(:user).permit(
      :username, :isPremium, :level, :experience,
      :assetType, :asset, :slotUnlockedId, :maxRarity
    )
  end
end
