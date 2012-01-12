module AuthorizationRequestHelper
  def resource_owner_is_authenticated(resource_owner = nil)
    resource_owner ||= User.create!
    Doorkeeper.configuration.instance_variable_set(:@authenticate_resource_owner, proc { resource_owner })
  end

  def resource_owner_is_not_authenticated
    Doorkeeper.configuration.instance_variable_set(:@authenticate_resource_owner, proc { redirect_to("/sign_in") })
  end

  def client_exists(client_attributes = {})
    @client = Factory(:application, client_attributes)
  end

  def scope_exist(*args)
    scopes = Doorkeeper.configuration.instance_variable_get(:@scopes) || Doorkeeper::Scopes.new
    scopes.add(Doorkeeper::Scope.new(*args))
    Doorkeeper.configuration.instance_variable_set(:@scopes, scopes)
  end

  def client_should_be_authorized(client)
    client.should have(1).access_grants
  end

  def client_should_not_be_authorized(client)
    client.should have(0).access_grants
  end

  def authorization_code_exists(options)
    @authorization = Factory(:access_grant, :application => options[:client], :scopes => options[:scopes])
  end

  def i_should_be_on_client_callback(client)
    client.redirect_uri.should == "#{current_uri.scheme}://#{current_uri.host}#{current_uri.path}"
  end

  def parse_fragment_params(uri)
    params = {}
    return params unless uri
    fragment = URI.parse(uri).fragment
    pairs = fragment.split('&')
    pairs.each do |pair|
      key, value = pair.split('=')
      params[key] = CGI.unescape(value) if key && value
    end
    params
  end
end

RSpec.configuration.send :include, AuthorizationRequestHelper, :type => :request
