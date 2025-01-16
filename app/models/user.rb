class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  # Associations
  has_many :nfts, foreign_key: :owner, primary_key: :openLootID
  has_many :matches
  has_many :user_slots
  has_many :user_builds

  # JWT token generation
  def generate_jwt
    JWT.encode(
      {
        id: id,
        exp: 60.days.from_now.to_i,
        email: email
      },
      Rails.application.credentials.devise_jwt_secret_key!,
      'HS256'
    )
  end
end
