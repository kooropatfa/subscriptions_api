class SubscriptionsCreator
  class PlanNotFoundError < StandardError; end

  def initialize(params, user)
    @shipping_details = params[:shipping_details]
    @billing_details = params[:billing_details]
    @product = Product.find_by(id: params[:product_id])
    @user = user
    @charger = UserCharger.new(billing_details, product)
  end

  attr_accessor :shipping_details, :billing_details, :product, :user, :subscription, :charger

  def create
    begin
      raise ProductNotFoundError.new 'Product not found.' unless product

      ActiveRecord::Base.transaction do
        charger.charge

        create_subscription if charger.successful_charge?

        { status: 200, json: @subscription.to_json}
      end
    rescue => exception
      { status: 422, json: { message: exception.message }.to_json } 
    end
  end

  private

  def create_subscription
    @subscription = user.subscriptions.create(
      customer_name: shipping_details[:name],
      customer_address: shipping_details[:address],
      customer_zip_code: shipping_details[:zip_code],
      product: product,
      renewal_date: product.billing_interval.months.from_now,
      payment_auth_token: charger.token
    )
  end

  def charge_user
    charger.charge
  end
end