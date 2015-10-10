module Rack
  class Webauth
    # Helpers. See Rack::Webauth for usage overview.
    module Helpers
      # ActionController support. If this is included in ActionController::Base
      # descendants, it adds itself as a helper as well.
      def self.included(base)
        if defined?(ActionController) && base.kind_of?(ActionController::Base)
          base.send(:helper, self)
        end
      end

      # Helper to access the Rack::Webauth::Info object from environment.
      # Requires either "env" or "request.env" to be available.
      #
      # Example Usage:
      #   webauth.logged_in?       #=> true
      #   webauth.login            #=> "blue"
      #   webauth.attributes       #=> { "FOO" => ["x", "y"], "BAR" => "z" }
      #   webauth.privgroup        #=> "cn=admins,ou=groups,dc=example,dc=com"
      #   webauth.authrule         #=> "valid-user"
      #   webauth.token_creation   #=> Sat Jan 29 20:47:59 +0100 2011
      #   webauth.token_expiration #=> Sun Jan 30 06:47:59 +0100 2011
      #
      def webauth
        (respond_to?(:env) ?
         env[NS] :
         (respond_to?(:request) &&
          request.respond_to?(:env) ?
          request.env[NS] :
          (raise Rack::Webauth::Info::NotAvailable.new("Neither 'env' nor 'request.env' available. Can't access webauth-info"))))
      end
    end
  end
end
