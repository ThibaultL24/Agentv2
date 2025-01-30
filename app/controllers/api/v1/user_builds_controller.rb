class Api::V1::UserBuildsController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :set_build, only: [:show, :update, :destroy]

  def index
    @builds = current_user.user_builds
    render json: @builds.map { |build|
      {
        id: build.id,
        buildName: build.buildName,
        bonusMultiplier: build.bonusMultiplier,
        perksMultiplier: build.perksMultiplier
      }
    }
  end

  def show
    render json: {
      build: {
        id: @build.id,
        buildName: @build.buildName,
        bonusMultiplier: @build.bonusMultiplier,
        perksMultiplier: @build.perksMultiplier
      },
      performance: calculate_build_metrics
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Build not found or not accessible" }, status: :not_found
  end

  def create
    @build = current_user.user_builds.new(build_params)

    if build_params[:buildName].blank?
      return render json: { error: "You have entered an empty build name." }, status: :unprocessable_entity
    end

    if current_user.user_builds.exists?(buildName: build_params[:buildName])
      return render json: { error: "You have entered the same name as an existing Build in your list, please modify it." }, status: :unprocessable_entity
    end

    if @build.save
      render json: {
        build: {
          id: @build.id,
          buildName: @build.buildName,
          bonusMultiplier: @build.bonusMultiplier,
          perksMultiplier: @build.perksMultiplier
        }
      }, status: :created
    else
      render json: { error: @build.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @build.update(build_params)
      render json: {
        build: {
          id: @build.id,
          buildName: @build.buildName,
          bonusMultiplier: @build.bonusMultiplier,
          perksMultiplier: @build.perksMultiplier
        }
      }
    else
      render json: { error: @build.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Build not found or not accessible" }, status: :not_found
  end

  def destroy
    @build.destroy
    render json: { message: "Build successfully deleted" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Build not found or not accessible" }, status: :not_found
  end

  private

  def set_build
    @build = current_user.user_builds.find(params[:id])
  end

  def calculate_build_metrics
    matches = Match.where(build: @build.buildName).last(10)
    return {} if matches.empty?

    {
      recent_performance: {
        average_profit: matches.sum(&:profit) / matches.size,
        total_bft: matches.sum(&:totalToken),
        total_flex: matches.sum(&:totalFee)
      },
      multipliers: {
        bonus: @build.bonusMultiplier,
        perks: @build.perksMultiplier
      }
    }
  end

  def build_params
    params.require(:user_build).permit(:buildName, :bonusMultiplier, :perksMultiplier)
  end
end
