require 'net/http'

class UserCharger
  class FailedChargeError < StandardError; end

  def initialize(params, product)
    @product = product
    @card_number = params[:card_number]
    expiration_date_array = params[:expiration_date].split('/')
    @exp_month = expiration_date_array[0]
    @exp_year = expiration_date_array[1]
    @cvv = params[:cvv]
    @zip_code = params[:zip_code] 
    @token = params[:token]
  end
  
  attr_accessor :card_number, :exp_month, :exp_year, :cvv, :zip_code, :token, :product, :response

  def charge
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request['Authorization'] = "Token token=#{api_key}"
    request.body = transaction_params.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http| 
      http.request(request)
    end

    set_response(response)

    successful_charge? ? set_token : raise_exception
  end

  def successful_charge?
    response[:success]
  end

  private

  def raise_exception
    raise FailedChargeError.new FakepayErrors.translate(response['error_code'])
  end

  def set_response(response)
    @response = JSON.parse(response.body).with_indifferent_access
  end
 
  def set_token
    @token = response[:token]
  end

  def api_key
    PaymentGateways.api_key(gateway)
  end

  def gateway
    ENV['PAYMENT_GATEWAY']
  end

  def uri
    @uri ||= URI(gateway_url)
  end

  def gateway_url
    PaymentGateways.endpoint(gateway)
  end

  def transaction_params
    { amount: product.price }.merge(authentication_details)
  end

  def authentication_details
    token ? { token: token} : credit_card_details
  end

  def credit_card_details
    { card_number: card_number,
      cvv: cvv,
      zip_code: zip_code,
      expiration_month: exp_month,
      expiration_year: exp_year }
  end
end