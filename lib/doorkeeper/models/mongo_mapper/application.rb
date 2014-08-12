module Doorkeeper
  class Application
    include MongoMapper::Document
    safe
    timestamps!

    set_collection_name 'oauth_applications'

    many :authorized_tokens, class_name: 'Doorkeeper::AccessToken'

    key :name,         String
    key :uid,          String
    key :secret,       String
    key :redirect_uri, String
    key :scopes,       String

    def scopes=(value)
      write_attribute :scopes, value if value.present?
    end

    def self.resource_owner_property
      Doorkeeper.configuration.resource_owner_property
    end
    private_class_method :resource_owner_property

    def self.authorized_for(resource_owner)
      ids = AccessToken.where(resource_owner_id: resource_owner.send(resource_owner_property), revoked_at: nil).map(&:application_id)
      find(ids)
    end

    def self.create_indexes
      ensure_index :uid, unique: true
    end
  end
end
