module Doorkeeper
  module Models
    module Mongoid3
      module Scopes
        extend ActiveSupport::Concern

        included do
          def scopes=(value)
            write_attribute :scopes, value if value.present?
          end
        end
      end
    end
  end
end
