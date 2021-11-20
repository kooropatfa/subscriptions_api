describe "POST api/v1/puchase", :type => :request do
  let(:user)                     { create(:user) }
  let(:user_access_token)        { ::Doorkeeper::AccessToken.create(resource_owner_id: user.id ) }
  let!(:token)                   { user_access_token.token }
  let!(:product)                 { create(:product) }
  let(:valid_card_number)        { 4242424242424242 }
  let(:invalid_card_number)      { 4242424242424241 }
  let(:insufficient_card_number) { 4242424242420089 }
  let(:cvv)                      { 123 }
  let(:future)                   { 1.year.from_now }
  let(:expiration_date)          { "#{future.month}/#{future.year}" }

  let(:shipping_details)         { { name: Faker::Name.name,
                                     zip_code: Faker::Address.zip_code,
                                     address: Faker::Address.street_address } }
                                     
  let(:billing_details)          { { cvv: cvv,
                                     card_number: valid_card_number,
                                     expiration_date: expiration_date,
                                     zip_code: Faker::Address.zip_code  } }

  let(:params)                   { { shipping_details: shipping_details,
                                     billing_details: billing_details,
                                     product_id: product.id } }

  subject {
    post "/api/v1/purchase", params: { access_token: token, subscription: params }
  }

  # before(:each) { subject }

  context 'valid card details' do
    context 'successful purchase' do
      before { mock_request(200, { token: :toooooken, success: true, error_code: :null } )}

      it 'returns new subscription and expected status code' do
        subject

        expect(response_body[:product_id]).to eq(product.id)
        expect(response_body[:user_id]).to eq(user.id)
      end

      it 'creates new subsription with payment auth token' do
        expect{ subject }.to change{ user.subscriptions.count }.by(1)

        subscription = user.subscriptions.last
        expect(response_body[:payment_auth_token]).to be
        expect(response_body[:id]).to eq subscription.id
        expect(subscription.payment_auth_token).to eq(response_body[:payment_auth_token])
      end
    end
    
    context 'insufficient funds' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000002 })
        billing_details.merge!({card_number: insufficient_card_number})
      end

      it 'returns error message and expected status code' do
        subject
        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('Insufficient funds')
      end
    end 

    context 'invalid amount' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000006 }) 
        allow_any_instance_of(Product).to receive(:price).and_return(-997)
      end

      it 'returns error message and expected status code' do
        subject
        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('Invalid purchase amount')
      end
    end
  end

  context 'invalid card' do
    context 'invalid card number' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000001 })  
        billing_details.merge!({card_number: invalid_card_number})
      end 

      it 'returns error message and expected status code' do
        subject

        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('Invalid credit card number')
      end
    end

    context 'invalid CVV' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000003 })  
        billing_details.merge!({cvv: 997})
      end 

      it 'returns error message and expected status code' do
        subject

        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('CVV failure')
      end
    end

    context 'expired card' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000004 }) 
        billing_details.merge!({expiration_date: '01/2001'})
      end 

      it 'returns error message and expected status code' do
        subject

        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('Expired card')
      end
    end

    context 'invalid ZIP code' do
      before do
        mock_request(200, { token: :null, success: false, error_code: 1000005 }) 
        billing_details.merge!({zip_code: nil})
      end 

      it 'returns error message and expected status code' do
        subject
        expect(response).to have_http_status(422)
        expect(response_body[:message]).to eq('Invalid zip code')
      end
    end
  end
end