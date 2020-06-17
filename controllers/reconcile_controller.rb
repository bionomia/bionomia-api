# encoding: utf-8

module Sinatra
  module BionomiaApi
    module Controller
      module ReconcileController

        def self.registered(app)

          app.get '/reconcile' do
            json_headers
            json_response(reconcile_response)
          end

          app.post '/reconcile' do
            json_headers
            json_response(reconcile_response)
          end

          app.get '/reconcile/suggest/property' do
            json_headers
            json_response(property_list)
          end

          app.get '/reconcile/flyout/property/:id' do
            json_headers
            json_response(flyout_property)
          end

        end

      end
    end
  end
end
