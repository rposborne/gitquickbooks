require 'oauth'
require 'launchy'

module GitQuickBooks
  ##
  # Expose and authorize primary QB account
  class Api
    attr_reader :realm,
                :key,
                :secret,
                :access_token,
                :callback_url,
                :authorize_url

    def initialize
      @key          = ENV['QB_KEY']
      @secret       = ENV['QB_SECRET']
      @realm        = ENV['COMPANY_ID']
      @callback_url = 'https://localhost/oob'
      @qb_oauth     = build_oauth
      @access_token = GitQuickBooks::Cache.new.fetch('key') do
        setup_auth
      end
    end

    def build_oauth
      OAuth::Consumer.new(
        @key,
        @secret,
        site: 'https://oauth.intuit.com',
        request_token_path: '/oauth/v1/get_request_token',
        authorize_url: 'https://appcenter.intuit.com/Connect/Begin',
        access_token_path: '/oauth/v1/get_access_token'
      )
    end

    def setup_auth
      @request_token ||= @qb_oauth.get_request_token(oauth_callback: @callback_url)
      @authorize_url ||= @request_token.authorize_url(oauth_callback: @callback_url)
    end

    def authorize(oauth)
      @access_token = @request_token.get_access_token(oauth_verifier: oauth)
      GitQuickBooks::Cache.new.write('key', @access_token)
    end
  end
end
