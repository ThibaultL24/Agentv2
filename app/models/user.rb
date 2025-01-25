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

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  # Permettre l'attribution massive de ces champs
  attr_accessor :username

  # JWT token generation
  def generate_jwt
    JWT.encode(
      {
        id: id,
        exp: 60.days.from_now.to_i
      },
      Rails.application.credentials.devise_jwt_secret_key!
    )
  end

  def jwt_payload
    {
      'sub' => id,
      'email' => email,
      'username' => username,
      'openLootID' => openLootID
    }
  end

  def on_jwt_dispatch(_token, _payload)
    # Vous pouvez ajouter ici une logique supplémentaire lors de la création du token
  end

  after_create :send_welcome_email

  private

  def send_welcome_email
    NotificationMailer.welcome_email(self).deliver_later
  end
end
