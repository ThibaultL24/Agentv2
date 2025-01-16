module Authentication
  extend ActiveSupport::Concern

  def current_user
    @current_user
  end
end
