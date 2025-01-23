class Api::V1::GamesController < Api::V1::BaseController
  def index
    @games = Game.all
    render json: @games
  end

  def show
    @game = Game.find(params[:id])
    render json: {
      game: @game,
      currencies: @game.currencies,
      slots: @game.slots
    }
  end
end
