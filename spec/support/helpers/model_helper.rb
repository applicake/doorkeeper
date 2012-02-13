module ModelHelper
  def client_exists(client_attributes = {})
    @client = Factory(:application, client_attributes)
  end

  def create_resource_owner
    @resource_owner = User.create!
  end

  def authorization_code_exists(options = {})
    @authorization = Factory(:access_grant, options)
  end

  def access_grant_should_exists_for(client, resource_owner)
    grant = Doorkeeper::AccessGrant.first
    grant.application.should == client
    grant.resource_owner_id  == resource_owner.id
  end

  def access_token_should_exists_for(client, resource_owner)
    grant = Doorkeeper::AccessToken.first
    grant.application.should == client
    grant.resource_owner_id  == resource_owner.id
  end

  def access_grant_should_not_exists
    Doorkeeper::AccessGrant.all.should be_empty
  end

  def access_token_should_not_exists
    Doorkeeper::AccessToken.all.should be_empty
  end

  def access_grant_should_have_scopes(*args)
    grant = Doorkeeper::AccessGrant.first
    grant.scopes.should == args
  end

  def access_token_should_have_scopes(*args)
    grant = Doorkeeper::AccessToken.first
    grant.scopes.should == args
  end
end

RSpec.configuration.send :include, ModelHelper, :type => :request
