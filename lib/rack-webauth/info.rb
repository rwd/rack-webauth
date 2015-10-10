module Rack
  class Webauth
    # Detects & provides webauth related information conveniently from
    # the rack environment.
    #
    # See README and Rack::Webauth::Helpers for usage information & examples.
    #
    class Info
      # Exception raised by Rack::Webauth::Helpers if webauth
      # cannot be accessed / is not available.
      class NotAvailable < Exception ; end

      attr :login
      attr :env
      # explains itself.
      def logged_in? ; @logged_in ; end

      # Read webauth from given environment.
      # Most information (e.g. attributes, privgroups) will
      # be read on demand, though.
      def initialize(env)
        @env = env
        @login = (env["WEBAUTH_USER"] || env["REMOTE_USER"])
        @logged_in = (@login && !@login.empty? && @login != ANONYMOUS)
        # reset login if it was "" or ANONYMOUS
        @login = nil unless @logged_in
      end

      # attributes passed via mod_webauthldap.
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauthldap.html#webauthldapattribute
      #
      # See +detect_attributes+ for details.
      def attributes
        @attributes ||= detect_attributes
      end

      # privgroup of the user.
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauthldap.html#webauthldapprivgroup
      #
      # TOOD: implement detection of multiple privgroups
      def privgroup
        @privgroup ||= env['WEBAUTH_LDAPPRIVGROUP']
      end

      # Rule ("Require" statement) that authenticated this user
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauthldap.html#webauthldapauthrule
      def authrule
        @authrule ||= env['WEBAUTH_LDAPAUTHRULE']
      end

      # Time when the authentication cookie was created.
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauth.html#sectionenv
      #
      # Also see: +token_expiration+, +token_lastused+
      def token_creation
        Time.at(env["WEBAUTH_TOKEN_CREATION"].to_i) if env.key?("WEBAUTH_TOKEN_CREATION")
      end

      # Time when the authentication cookie will expire.
      # This isn't authorative, as WebAuthInactiveExpire may be set.
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauth.html#sectionenv
      #
      # Also see: +token_creation+, +token_lastused+
      def token_expiration
        Time.at(env["WEBAUTH_TOKEN_EXPIRATION"].to_i) if env.key?("WEBAUTH_TOKEN_EXPIRATION")
      end

      # Time the authentication cookie was last used.
      # Only present is WebAuthLastUseUpdateInterval is set.
      #
      # http://webauth.stanford.edu/manual/mod/mod_webauth.html#webauthlastuseupdateinterval
      #
      # Also see: +token_creation+, +token_expiration+
      def token_lastused
        Time.at(env["WEBAUTH_TOKEN_LASTUSED"].to_i) if env.key?("WEBAUTH_TOKEN_LASTUSED")
      end

      private

      #
      # Example:
      #   # Consider this environment:
      #   WEBAUTH_LDAP_FOO = "x"
      #   WEBAUTH_LDAP_FOO1 = "x"
      #   WEBAUTH_LDAP_FOO2 = "y"
      #   WEBAUTH_LDAP_BAR = "z"
      #   # This is what @attributes looks like:
      #   { "FOO" => ["x", "y"], "BAR" => "z" }
      #
      # Don't call this directly. Use +attributes+ instead.
      #
      def detect_attributes
        env.keys.inject({}) do |attrs, key|
          if key =~ /^WEBAUTH_LDAP_(\w+?)(\d+)$/
            # multi-valued attribute
            aname = $~[1]
            ai = $~[2].to_i - 1

            if((! attrs[aname]) ||
               # in case of multi-value WEBAUTH_LDAP_FOO1,
               # WEBAUTH_LDAP_FOO is also set
               # (to a random value, which we discard)
               (attrs[aname] && !(attrs[aname].kind_of?(Array))))

              attrs[aname] = []
            end

            attrs[aname][ai] = env[key]
          elsif key =~ /^WEBAUTH_LDAP_(\w+)$/
            # single-valued attribute
            attrs[ $~[1] ] = env[key]
          else
            # key isn't webauthldap related
          end
          next(attrs)
        end
      end
    end
  end
end
