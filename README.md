Shopik was created primarly to learn and expand my knowledge about Ruby on Rails. Currently the project contains:

- Extensive integration with Espago Payment Gateway, including: Secure Web Page payments, One-Time Payments via iFrame, Recurring Payments, saving Payment Methods, using saved Payment Method to perform CIT and MIT transactions as well as reversing and refunding Payments
- Jobs implemented via Sidekiq
- Unit and Request tests implemented via RSpec
- End-to-End tests implemented via Playwright
- Github Actions configured with Sorbet typecheck and RSpec/Playwright tests


### Prerequisites:

- This is an app created to integrate with Espago. You can use it only if you have access to Espago.
- Ruby 3.4.3 or newer
- Rails 8 or newer
- Node.js version 24.x or newer
- Yarn 1.22.x or newer
- Redis server 6.x or newer
- SQLite3
- Bundler
- Git

### Clone the application:

```
git clone https://github.com/KubaJadrzak/shopik.git
cd shopik
```
### Install Ruby gems and JavaScript packages and prepare the database:
```
bin/setup
```
### Setup and seed the database:
```
bin/reset
```

In order to ensure proper functionality, proceed with steps below.

### Adding environmental variables and credentials:

shopik is using the following environmental variables, stored inside `.env` and `.env.test` files (via gem `dotenv`), which have to be created in the root directory of the project:

`.env`
```
APP_HOST_URL=your_host_url
ESPAGO_BASE_URL=espago_base_url
ESPAGO_PUBLIC_KEY=your_espago_public_key
```

`.env.test`

```
APP_HOST_URL=http://localhost:3001
ESPAGO_BASE_URL=espago_base_url
ESPAGO_PUBLIC_KEY=your_espago_public_key
```

shopik is using `Rails credentials`. Your credentials will have to include below information:

```
espago:
    app_id: your_espago_app_id
    password: your_espago_password
    login_basic_auth: your_espago_login_basic_auth
    password_basic_auth: your_espago_password_basic_auth
    checksum_key: your_espago_checksum_key
```
### Start application:

You can start the shopik application using the command:
```
bin/dev
```
This command will start all necessary services, including rails server and sidekiq background jobs

### RSpec: 

shopik is using `RSpec` tests. You can run test suite with: `bin/rspec`. Make sure that `.env.test` and `Rails credentials` are configured properly, as some tests make real requests to Espago and will otherwise fail.

### Playwright: 

shopik is using `Playwright` tests. You can run test suite with: `bin/playwright`. Make sure that `.env.test` and `Rails credentials` are configured properly, as some tests make real requests to Espago and will otherwise fail.

### Sorbet/Tapioca:

shopik is using `Sorbet` with `Tapioca`. You can use the following command to generate rbi files for the project:
```
bin/types
```


