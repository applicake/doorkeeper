require 'doorkeeper/rails/routes/mapping'
require 'doorkeeper/rails/routes/mapper'

module Doorkeeper
  module Rails
    class Routes
      module Helper
        # TODO: options hash is not being used
        def use_doorkeeper(options = {}, &block)
          Doorkeeper::Rails::Routes.new(self, &block).generate_routes!(options)
        end
      end

      def self.install!
        ActionDispatch::Routing::Mapper.send :include, Doorkeeper::Rails::Routes::Helper
      end

      attr_accessor :routes

      def initialize(routes, &options)
        @routes, @options = routes, options
      end

      def generate_routes!(options)
        @mapping = Mapper.new.map(&@options)
        routes.scope 'oauth', :as => 'oauth' do
          map_route(:authorizations, :authorization_routes)
          map_route(:tokens, :token_routes)
          map_route(:applications, :application_routes)
          map_route(:authorized_applications, :authorized_applications_routes)
          map_route(:token_info, :token_info_routes)
        end
      end

    private
      def map_route(name, method)
        unless @mapping.skipped?(name)
          send method, @mapping[name]
        end
      end

      def authorization_routes(mapping)
        routes.resource(
          :authorization,
          path: 'authorize',
          only: [:create, :update, :destroy],
          as: mapping[:as],
          controller: mapping[:controllers]
        ) do
          routes.get '/:code', action: :show, on: :member
          routes.get '/', action: :new, on: :member
        end
      end

      def token_routes(mapping)
        routes.scope :controller => mapping[:controllers] do
          routes.match 'token', :via => :post, :action => :create, :as => mapping[:as]
        end
      end

      def token_info_routes(mapping)
        routes.scope :controller => mapping[:controllers] do
          routes.match 'token/info', :via => :get, :action => :show, :as => mapping[:as]
        end
      end

      def application_routes(mapping)
        routes.resources :applications, :controller => mapping[:controllers]
      end

      def authorized_applications_routes(mapping)
        routes.resources :authorized_applications, :only => [:index, :destroy], :controller => mapping[:controllers]
      end
    end
  end
end
