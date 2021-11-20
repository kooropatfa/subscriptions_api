module JsonHelpers
  def response_body
    @parsed_response ||= JSON.parse(response.body).with_indifferent_access
  end
end