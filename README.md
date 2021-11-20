This is my solution of coding challenge described here https://www.fakepay.io/challenge


## System requirements

This application requires gems in following versions installed on the system:

- Ruby [2.7.1]
- Rails [6.1.4.1]

## 1. Setup the application

#### Install required gems

```ruby
bundle install
```

#### Setup the databas

```ruby
rails db:create
rails db:migrate
```

#### Start server

```ruby
rails s
```

## 2. Create an API user

To create new user send a POST request to  
```bash
/api/v1/users/
```
with body of following format:
```json
{ "user": {"password": "at_least_6_characters", "email": "valid@email.com"} } 
```

## 3. Obtain authentication token

To get an authentication token send a POST request to 
```bash
/api/oauth/token/
```
with body of following format:
```json
{ "password": ,
  "email": ,
  "grant_type": "password" }
```

## 4. Authenticate requests

To authenticate your calls to the API the `access_token` parameter is required to be present in the top-level of your request body.

## 5. Purchases API

To attempt a purchase of new Product subscription submit a POST request to `/api/v1/purchase` endpoint.
To be valid the request needs to contain following parameters with correct values:

```json
  { "product_id": ,
    "shipping_details": {
      "name": ,
      "address": ,
      "zip_code": 
    },
    "billing_details": {
      "card_number": ,
      "cvv": ,
      "zip_code": ,
      "expiration_date": # format: MM/YYYY
    }
  }
```

##### After successful purchase controller responds with newly created subscription:

```json
  { "id": 1,
    "customer_name": "Donnie Ducko",
    "customer_address": "123 Steep Street",
    "customer_zip_code": "12345",
    "renewal_date": "2021-12-20T16:13:29.745Z",
    "payment_auth_token": "toooooken",
    "product_id": 1,
    "user_id": 1,
    "created_at": "2021-11-20T16:13:29.754Z",
    "updated_at": "2021-11-20T16:13:29.754Z" }
```

Actually it should be some Purchase object to keep the naming consistent but for simplicity sake I'wm just returning subscription here.
I don't think it should contain payment_auth_token for example.
But it could include product details as the product is already retrieved from the database.

##### Purchase failure results with a response containing appropirate error message and status code 422:

```json
 { "message": "Expired card" }
```