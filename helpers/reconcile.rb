# encoding: utf-8

module Sinatra
  module BionomiaApi
    module Reconcile

      def manifest
        {
          name: "Bionomia",
          versions: ["0.2"],
          identifierSpace: "https://bionomia.net/",
          schemaSpace: "https://schema.org/",
          view: {
            url: "https://bionomia.net/{{id}}"
          },
          preview: {
            url: "https://bionomia.net/{{id}}",
            width: 400,
            height: 600
          },
          defaultTypes: [
            {
              id: "http://schema.org/Person",
              name: "Person"
            }
          ],
          suggest: {
            property: {
              service_url: "#{base_url}/reconcile",
              service_path: "/suggest/property",
              flyout_service_path: "/flyout/property/${id}"
            }
          }
        }
      end

      def process_single_query(query)
        client = Elasticsearch::Client.new(
          url: Settings.elastic.server,
          request_timeout: 5*60,
          retry_on_failure: true,
          reload_on_failure: true,
          reload_connections: 1_000,
          adapter: :typhoeus
        )
        user_query = build_user_query(query)
        json_response = client.search index: Settings.elastic.user_index, size: 10, body: user_query
        response = JSON.parse(JSON[json_response["hits"]], symbolize_names: true)
        { result: format_reconciled_candidates(response[:hits]) }
      end

      def process_queries(queries)
        client = Elasticsearch::Client.new(
          url: Settings.elastic.server,
          request_timeout: 5*60,
          retry_on_failure: true,
          reload_on_failure: true,
          reload_connections: 1_000,
          adapter: :typhoeus
        )
        queries.map do |key, query|
          properties = {}
          if query[:properties]
            properties = {
              families_identified: query[:properties].map{|o| o[:v] if o[:pid] == "families_identified"}.compact,
              families_collected: query[:properties].map{|o| o[:v] if o[:pid] == "families_collected"}.compact,
              date: query[:properties].map{|o| o[:v] if o[:pid] == "date"}.compact.first
            }
          end
          size = query[:limit] ? query[:limit].to_i : 10
          user_query = build_user_query(query[:query], properties)
          json_response = client.search index: Settings.elastic.user_index, size: size, body: user_query
          response = JSON.parse(JSON[json_response["hits"]], symbolize_names: true)
          { "#{key}": { result: format_reconciled_candidates(response[:hits]) } }
        end.reduce({}, :merge)
      end

      def reconcile_response
        if params[:queries] && params[:queries].length > 0
          begin
            queries = JSON.parse(params[:queries], symbolize_names: true)
            process_queries(queries)
          rescue
            manifest
          end
        elsif params[:query] && params[:query].length > 0
          begin
            process_single_query(params[:query])
          rescue
            manifest
          end
        else
          manifest
        end
      end

      def property_list
        {
          result: [
            {
                id: "families_collected",
                name: "Family collected",
                description: "Taxonomic Family the person to be reconciled has collected."
            },
            {
                id: "families_identified",
                name: "Family identified",
                description: "Taxonomic Family the person to be reconciled has identified."
            },
            {
                id: "date",
                name: "Date",
                description: "Date cross-referenced against birth and death dates when known."
            }
          ]
        }
      end

      def flyout_property
        return {} if !params[:id] || params[:id].length == 0
        description = property_list[:result].select{|hash| hash[:id] == params[:id] }
                                            .first[:description] rescue nil
        return {} if description.nil?
        {
          id: "#{params[:id]}",
          html: "<p style=\"font-size: 0.8em; color: black;\">#{description}</p>"
        }
      end

    end
  end
end
