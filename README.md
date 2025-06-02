This is an app created to integrate with Espago. You can use it only if you have access to Espago Sandbox.

### Prerequisites:

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
git clone https://github.com/KubaJadrzak/RubitterRewritten.git
cd RubitterRewritten
```
### Install Ruby gems and JavaScript packages:
```
bundle install
yarn install
```
### Set up the database:
```
rails db:create 
rails db:migrate 
rails db:seed
```

### Start the application:
```
bin/dev
```

The application should start and be accessible via `localhost:3000` by default, however in order to ensure proper functionality, proceed with steps below.

### Adding environmental variables and credentials:

RubitterRewritten is using the following environmental variables, stored inside `.env` and `.env.test` files (via gem `dotenv`), which have to be created in the root directory of the project:

`.env`
```
APP_HOST_URL=your_host_url
ESPAGO_BASE_URL=https://sandbox.espago.com
ESPAGO_PUBLIC_KEY=your_espago_public_key
```

`.env.test`

```
APP_HOST_URL=http://localhost:3001
ESPAGO_BASE_URL=https://sandbox.espago.com
ESPAGO_PUBLIC_KEY=your_espago_public_key
```

RubitterRewritten is using `Rails credentials`. You will have to remove existing encrypted credentials since encrypted `credentails.yml.enc` is included in the repository, simply run the following commands (replace `nano` with editor of choice): 

```
rm config/credentials.yml.enc
EDITOR=nano bin/rails credentials:edit
```

Your credentials will have to include below information:

```
espago:
    app_id: your_espago_app_id
    password: your_espago_password
    login_basic_auth: your_espago_login_basic_auth
    password_basic_auth: your_espago_password_basic_auth
    checksum_key: your_espago_checksum_key
```
### Sidekiq:

RubitterRewritten is using `sidekiq`. To correctly run background jobs, simply start sidekiq in new terminal window with: `bundle exec sidekiq`. Make sure that `Redis` is also running on your system.

### RSpec: 

RubitterRewritten is using `RSpec` tests. You can run test suite with: `bundle exec rspec`. Make sure that `.env.test` and `Rails credentials` are configured properly, as some tests make real requests to Espago and will otherwise fail.

### Back Requests:

RubitterRewritten is using `back requests` to update the status of payments, however it also requests from Espago status of all payments which are not finished.
This means that payment statuses will still be updated while running RubitterRewritten on `localhost`, although the statuses will be delayed as payment status requests to Espago are done via background jobs for a specific user on login to application and on account page visit. This means that after completing the payment process refresh of account page may be required to trigger background jobs and update payment statuses.
