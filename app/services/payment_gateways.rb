class PaymentGateways
  PROVIDERS = { fakepay: { endpoint: 'https://www.fakepay.io/purchase',
                           api_key: ENV['FAKEPAY_API_KEY'] } }.with_indifferent_access

  def self.endpoint(provider)
    PROVIDERS[provider][:endpoint]
  end

  def self.api_key(provider)
    PROVIDERS[provider][:api_key]
  end
end
