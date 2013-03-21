require 'omniauth'
require 'samlr'

module OmniAuth
  module Strategies
    class SAML
      include OmniAuth::Strategy

      option :name_identifier_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

      def request_phase
        session["user_return_to"] = request.params['redirect_to'] if request.params['redirect_to']

        saml_request = Samlr::Request.new(options)
        redirect(saml_request.url(options[:idp_sso_target_url], {:RelayState => request.url}))
      end

      def callback_phase
        raise Samlr::SamlrError.new("Missing SAMLResponse") unless request.params['SAMLResponse']
        saml_response = Samlr::Response.new(request.params['SAMLResponse'], fingerprint_or_cert)

        saml_response.verify!
        @name_id = saml_response.name_id
        @attributes = saml_response.attributes
        super
      rescue Samlr::SamlrError => e
        msg = "Invalid SAML Ticket"
        msg << ": #{e.message}" if e.message
        #logger.error "[SAML] Error: #{msg}"
        ex = OmniAuth::Strategies::SAML::ValidationError.new(msg)
        ex.saml_response = response
        fail!(:invalid_ticket, ex)
      end

      uid { @name_id }

      info do
        @attributes
        # {
        #   :name  => @attributes[:name],
        #   :email => @attributes[:email] || @attributes[:mail],
        #   :first_name => @attributes[:first_name] || @attributes[:firstname] || @attributes[:firstName],
        #   :last_name => @attributes[:last_name] || @attributes[:lastname] || @attributes[:lastName]
        # }
      end

      extra { { :raw_info => @attributes } }

      def fingerprint_or_cert
        if options[:idp_cert_fingerprint]
          {:fingerprint => options[:idp_cert_fingerprint]}
        else
          {:certificate => OpenSSL::X509::Certificate.new(options[:idp_cert])}
        end
      end

    end
  end
end

OmniAuth.config.add_camelization 'saml', 'SAML'
