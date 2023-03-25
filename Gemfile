source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

gem "rails",                      "7.0.4"
gem "image_processing",           "1.12.2"
gem "active_storage_validations", "0.9.8"
gem "bcrypt",                     "3.1.18"
gem "faker",                      "2.21.0"
gem "will_paginate",              "3.3.1"
gem "bootstrap-will_paginate",    "1.0.0"
gem "bootstrap-sass",             "3.4.1"
gem "sassc-rails",                "2.1.2"
gem "sprockets-rails",            "3.4.2"
gem "importmap-rails",            "1.1.5"
gem "turbo-rails",                "1.1.1"
gem "stimulus-rails",             "1.0.4"
gem "jbuilder",                   "2.11.5"
gem 'puma',                       '6.1.1'
gem 'bootsnap',                   '>=1.15.0', require: false
gem "jquery-rails"
gem 'chartkick'
gem 'groupdate'
gem 'ruby-openai'
gem 'rexml'

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'wkhtmltopdf-heroku'

gem 'pay',                        '~> 2.0'
gem 'stripe', '< 6.0',            '>= 2.8'
# gem 'clicksend_client',           '>=5.0.0'
gem 'clicksend_client', :git => 'https://github.com/ClickSend/clicksend-ruby.git'

group :development, :test do
  gem "sqlite3", "1.4.2"
  gem "debug",   "1.5.0"
end

group :development do
  gem "web-console", "4.2.0"
end

group :test do
  gem "capybara",                 "3.37.1"
  gem "selenium-webdriver",       "4.2.0"
  gem "webdrivers",               "5.0.0"
  gem "rails-controller-testing", "1.0.5"
  gem "minitest",                 "5.15.0"
  gem "minitest-reporters",       "1.5.0"
  gem "guard",                    "2.18.0"
  gem "guard-minitest",           "2.4.6"
end

group :production do
  gem "pg",         "1.3.5"
  gem "aws-sdk-s3", "1.114.0", require: false
end

