class CheckoutController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user! # Assurez-vous que c'est compatible avec votre système d'auth JWT

  def create
    begin
      @amount = params[:amount].to_d
      @currency_type = params[:currency_type]

      @session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'eur',
            unit_amount: (@amount * 100).to_i,
            product_data: {
              name: 'Boss Fighters Currency Pack',
              description: "#{@currency_type} Pack"
            },
          },
          quantity: 1
        }],
        metadata: {
          currency_type: @currency_type,
          user_id: current_user.id
        },
        mode: 'payment',
        success_url: ENV['FRONTEND_URL'] + '/payment/success?session_id={CHECKOUT_SESSION_ID}',
        cancel_url: ENV['FRONTEND_URL'] + '/payment/cancel'
      )

      render json: {
        sessionId: @session.id,
        sessionUrl: @session.url
      }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def success
    begin
      @session = Stripe::Checkout::Session.retrieve(params[:session_id])
      @payment_intent = Stripe::PaymentIntent.retrieve(@session.payment_intent)

      # Créer la transaction
      transaction = Transaction.create!(
        user: current_user,
        payment_method: PaymentMethod.find_by(provider: 'stripe'),
        amount: @payment_intent.amount / 100.0,
        currency: @payment_intent.currency,
        status: 'completed',
        external_id: @payment_intent.id,
        metadata: {
          currency_type: @session.metadata.currency_type
        }
      )

      render json: {
        status: 'success',
        transaction: transaction,
        payment: @payment_intent
      }, status: :ok
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def cancel
  end
end
