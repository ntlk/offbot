source 'https://rubygems.org'

gem 'rails', '3.2.3'

gem 'haml'
gem 'haml-rails'
gem 'devise'
gem 'uuid'
gem 'acts-as-taggable-on'
gem 'twitter-text'
gem 'jquery-rails'
gem 'roadie'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
	gem 'sqlite3'
end

group :production do
	gem 'pg'
end

# everyone loves a unicorn, especially one that is a webserver
gem 'unicorn'
