class Api::V1::UserBuildsController < ApplicationController
  def index
    @builds = current_user.user_builds
    render json: @builds
  end

  def show
    @build = UserBuild.find(params[:id])
    render json: {
      build: @build,
      performance: calculate_build_metrics
    }
  end

  def create
    @build = UserBuild.new(build_params)
    if @build.save
      render json: @build, status: :created
    else
      render json: @build.errors, status: :unprocessable_entity
    end
  end

  def update
    @build = UserBuild.find(params[:id])
    if @build.update(build_params)
      render json: @build
    else
      render json: @build.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @build = UserBuild.find(params[:id])
    @build.destroy
    head :no_content
  end

  private

  def calculate_build_metrics
    matches = Match.where(build: @build.buildName).last(10)
    {
      recent_performance: {
        average_profit: matches.sum(&:profit) / matches.size,
        total_bft: matches.sum(&:bft_earned),
        total_flex: matches.sum(&:flex_earned)
      },
      multipliers: {
        bonus: @build.bonusMultiplier,
        perks: @build.perksMultiplier
      }
    }
  end

  def build_params
    params.require(:user_build).permit(
      :user_id, :buildName, :player_type,
      :bonusMultiplier, :perksMultiplier
    )
  end
end
