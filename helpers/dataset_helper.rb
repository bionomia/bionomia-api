# encoding: utf-8

module Sinatra
   module BionomiaApi
     module DatasetHelper

      def search_dataset_by_uuid(uuid)
         client = Elasticsearch::Client.new(
           url: Settings.elastic.server,
           request_timeout: 5*60,
           retry_on_failure: true,
           reload_on_failure: true,
           reload_connections: 1_000,
           adapter: :typhoeus
         )
         body = {
           query: {
             term: {
               datasetkey: {
                 value: uuid
               }
             }
           }
         }
         response = client.search index: Settings.elastic.dataset_index, size: 1, body: body
         results = response["hits"].deep_symbolize_keys
         results[:hits][0][:_source] rescue nil
       end

     end
   end
end