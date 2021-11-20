class FakepayErrors
  MAPPING = {
    1000001 => 'Invalid credit card number',
    1000002 => 'Insufficient funds',
    1000003 => 'CVV failure',
    1000004 => 'Expired card',
    1000005 => 'Invalid zip code',
    1000006 => 'Invalid purchase amount',
    1000007 => 'Invalid token',
    1000008 => 'Invalid params: cannot specify both token and other credit card params like card_number, cvv, expiration_month, expiration_year or zip.'
  }
  # will the last 2 errors be ever rendered to show them to the customer?

  def self.translate(code)
    MAPPING[code]
  end
end