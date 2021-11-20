module Api
  module V1
    class PurchasesController < ApplicationController
      def create
        result = SubscriptionsCreator.new(subscription_params, current_user).create
        render json: result[:json], status: result[:status]
      end

      def subscription_params
        params.require(:subscription).permit(
          :product_id,
          shipping_details: [:name, :address, :zip_code], 
          billing_details: [:card_number, :cvv, :zip_code, :expiration_date]
        )
      end
    end
  end
end