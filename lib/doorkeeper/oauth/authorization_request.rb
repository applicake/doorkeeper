module Doorkeeper::OAuth
  class AuthorizationRequest
    include Doorkeeper::Validations
    include Doorkeeper::OAuth::Authorization::URIBuilder
    include Doorkeeper::OAuth::Helpers

    ATTRIBUTES = [
      :response_type,
      :client_id,
      :redirect_uri,
      :scope,
      :state
    ]

    validate :client,        :error => :invalid_client
    validate :redirect_uri,  :error => :invalid_redirect_uri
    validate :attributes,    :error => :invalid_request
    validate :response_type, :error => :unsupported_response_type
    validate :scope,         :error => :invalid_scope

    attr_accessor *ATTRIBUTES
    attr_accessor :resource_owner, :error

    def initialize(resource_owner, attributes)
      ATTRIBUTES.each { |attr| instance_variable_set("@#{attr}", attributes[attr]) }
      @resource_owner = resource_owner
      @scope          ||= Doorkeeper.configuration.default_scope_string
      validate
    end

    def authorize
      return false unless valid?
      @authorization = authorization_method.new(self)
      @authorization.issue_token
    end

    def access_token_exists?
      Doorkeeper::AccessToken.matching_token_for(client, resource_owner, scope).present?
    end

    def deny
      self.error = :access_denied
    end

    def success_redirect_uri
      @authorization.callback
    end

    def invalid_redirect_uri
      uri_builder = is_token_request? ? :uri_with_fragment : :uri_with_query
      send(uri_builder, redirect_uri, {
        :error => error,
        :error_description => error_description,
        :state => state
      })
    end

    def redirect_on_error?
      (error != :invalid_redirect_uri) && (error != :invalid_client)
    end

    def client
      @client ||= Doorkeeper::Application.find_by_uid(client_id)
    end

    def scopes
      Doorkeeper.configuration.scopes.with_names(*scope.split(" ")) if has_scope?
    end

    private

    def has_scope?
      Doorkeeper.configuration.scopes.all.present?
    end

    def validate_attributes
      response_type.present?
    end

    def validate_client
      !!client
    end

    def validate_redirect_uri
      return false unless redirect_uri
      URIChecker.valid_for_authorization?(redirect_uri, client.redirect_uri)
    end

    def validate_response_type
      is_code_request? || is_token_request?
    end

    def validate_scope
      return true unless has_scope?
      ScopeChecker.valid?(scope, configuration.scopes)
    end

    def is_code_request?
      response_type == "code"
    end

    def is_token_request?
      response_type == "token"
    end

    def error_description
      I18n.translate error, :scope => [:doorkeeper, :errors, :messages]
    end

    def configuration
      Doorkeeper.configuration
    end

    def authorization_method
      klass = is_code_request? ? "Code" : "Token"
      "Doorkeeper::OAuth::Authorization::#{klass}".constantize
    end
  end
end
