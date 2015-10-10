require 'rack'

module Rack
  #
  # Usage in any rack based app:
  #
  #   # In a rack environment:
  #   use(Rack::Webauth)
  #
  #   # In a view or controller:
  #   include(Rack::Webauth::Helpers)
  #
  #   # In a before filter or helper
  #   # or other middleware:
  #   @current_user = User.find_by_login(webauth.login)
  #
  #   # or whatever...
  #
  #
  # Usage in rails:
  #
  #   # config/application.rb:
  #     require 'rack-webauth'
  #     config.middleware.use(Rack::Webauth)
  #
  #   # ApplicationController:
  #     include(Rack::Webauth::Helpers)
  #     # optionally:
  #     delegate :logged_in?, :to => :webauth
  #
  class Webauth
    # Anonymous login name (if WebAuthOptional is set)
    # Requires webauth patch.
    ANONYMOUS = "<anonymous>"
    # Namespace for rack environment
    NS = "x-rack.webauth-info"

    autoload :Helpers, 'rack-webauth/helpers'
    autoload :Info, 'rack-webauth/info'
    autoload :User, 'rack-webauth/user'
    autoload :WardenStrategy, 'rack-webauth/warden_strategy'

    def initialize(app)
      @app = app
    end

    # put new Info object in env[NS], then continue.
    def call(env)
      env[NS] = Rack::Webauth::Info.new(env)
      @app.call(env)
    end
  end
end
