# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-without-signature"
gem "decidim-initiatives", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-without-signature"
gem "decidim-initiatives_no_signature_allowed", path: "."

gem "puma", ">= 4.3.3"
gem "uglifier", "~> 4.1"

gem "bootsnap"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", git: "https://github.com/OpenSourcePolitics/decidim.git", branch: "alt/petition-without-signature"
end

group :development do
  gem "faker", "~> 1.9"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
