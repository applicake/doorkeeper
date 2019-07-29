# frozen_string_literal: true

class EnableDeviceCodeGrant < ActiveRecord::Migration[6.0]
  def change
    add_column :oauth_access_grants, :user_code, :string, null: true
    add_column :oauth_access_grants, :last_polling_at, :datetime
    add_index :oauth_access_grants, :user_code
    change_column :oauth_access_grants, :redirect_uri, :text, null: true
    change_column :oauth_access_grants, :resource_owner_id, :integer, null: true
    change_column :oauth_applications, :redirect_uri, :text, null: true
  end
end
