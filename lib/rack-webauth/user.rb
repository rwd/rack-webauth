module Rack
  class Webauth
    # A default User object, to easily access attributes.
    # Used by WardenStrategy.
    class User
      attr :login

      def initialize(webauth_info)
        @webauth_info = webauth_info
        @login = @webauth_info.login
      end

      def [](attribute)
        @webauth_info.attributes[attribute.to_s.upcase]
      end
    end
  end
end
