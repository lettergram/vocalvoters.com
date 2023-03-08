source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.5'

gem 'rails',                      '>=6.1.3.2'
gem 'image_processing',           '1.9.3'
gem 'mini_magick',                '4.9.5'
gem 'active_storage_validations', '0.8.9'
gem 'bcrypt',                     '3.1.13'
gem 'faker',                      '2.11.0'
gem 'will_paginate',              '3.3.0'
gem 'bootstrap-will_paginate',    '1.0.0'
gem 'bootstrap-sass',             '3.4.1'
gem 'puma',                       '6.1.0'
gem 'sass-rails',                 '6.0.0'
gem 'webpacker',                  '>=5.2.1'
gem 'turbolinks',                 '5.2.1'
gem 'jbuilder',                   '2.10.0'
gem 'bootsnap',                   '>=1.15.0', require: false
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
  gem 'sqlite3', '1.4.2'
  gem 'byebug',  '11.1.3', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console',        '4.1.0'
  gem 'rack-mini-profiler', '2.3.1'
  gem 'listen',             '3.4.1'
  gem 'spring',             '~> 4.1'
end

group :test do
  gem 'capybara',                 '3.35.3'
  gem 'selenium-webdriver',       '3.142.7'
  gem 'webdrivers',               '4.6.0'
  gem 'rails-controller-testing', '1.0.5'
  gem 'minitest',                 '>=5.11.3'
  gem 'minitest-reporters',       '1.3.8'
  gem 'guard',                    '2.16.2'
  gem 'guard-minitest',           '2.4.6'
  gem 'rexml'
end

group :production do
  gem 'pg',         '1.2.3'
  gem 'aws-sdk-s3', '1.87.0', require: false
end
