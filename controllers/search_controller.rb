# encoding: utf-8

module Sinatra
  module BionomiaApi
    module Controller
      module SearchController

        def self.registered(app)

          app.get '/parse' do
            json_headers
            json_response(parse_names)
          end

          app.post '/parse' do
            json_headers
            json_response(parse_names)
          end

          app.get '/user.json' do
            json_headers
            search_user
            format_autocomplete.to_json
          end

          app.get '/users/search' do
            json_ld_headers
            api_search_user

            first = "#{base_url}/users/search?#{URI.encode_www_form(params.merge({ "page" => 1 }))}"
            prev = nil
            if @pagy.page > 1 && @pagy.page <= @pagy.pages
              prev = "#{base_url}/users/search?#{URI.encode_www_form(params.merge({ "page" => @pagy.page.to_i - 1 }))}"
            end
            current = "#{base_url}/users/search?#{URI.encode_www_form(params)}"
            nxt = nil
            if @pagy.page < @pagy.pages
              nxt = "#{base_url}/users/search?#{URI.encode_www_form(params.merge({ "page" => @pagy.page.to_i + 1 }))}"
            end
            last = "#{base_url}/users/search?#{URI.encode_www_form(params.merge({ "page" => @pagy.pages }))}"

            response = {
              "@context": {
                "@vocab": "http://schema.org",
                "opensearch": "http://a9.com/-/spec/opensearch/1.1/",
                "as": "https://www.w3.org/ns/activitystreams#"
              },
              "@type": "DataFeed",
              "opensearch:totalResults": @pagy.count,
              "opensearch:itemsPerPage": @pagy.items,
              "as:first": first,
              "as:prev": prev,
              "as:current": current,
              "as:next": nxt,
              "as:last": last,
              name: "Bionomia user search results",
              description: "Bionomia user search results expressed as a schema.org JSON-LD DataFeed.
                q={name} is a search by human name;
                families_identified={families_identified} is a comma-separated list of taxonomic families identified;
                families_collected={families_collected} is a comma-separated list of taxonomic families collected;
                date={date} is a date in the form YYYY, YYYY-MM, or YYYY-MM-DD and is compared to birth and death dates;
                page={page} is the page number and there is a fixed 30 items per page;
                strict={true|false} is a boolean for MUST vs SHOULD on families_identified, families_collected, and date",
              license: "https://creativecommons.org/publicdomain/zero/1.0/",
              potentialAction: {
                "@type": "SearchAction",
                target: "#{base_url}/users/search?q={name}&families_identified={families_identified}&families_collected={families_collected}&date={date}&page={page}&strict={true|false}"
              },
              dataFeedElement: format_users
            }
            json_response(response)
          end

        end

      end
    end
  end
end
