require 'json'

module NetworkMock
  def mock_request(response_status, response_body_hash)
    http = double
    response = double(status: response_status, body: response_body_hash.to_json)

    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Post))
        .and_return(response)
  end
end