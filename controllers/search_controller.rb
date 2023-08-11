# encoding: utf-8

module Sinatra
  module BionomiaApi
    module Controller
      module SearchController

        def self.registered(app)

          app.get '/' do
            json_headers
            halt 404
          end

          app.get '/parse' do
            json_headers
            json_response(parse_names)
          end

          app.post '/parse' do
            json_headers
            json_response(parse_names)
          end

          app.get '/agent.json' do
            json_headers
            search_agent
            format_autocomplete_agent.to_json
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
                "@vocab": "http://schema.org/",
                sameAs: {
                  "@id": "sameAs",
                  "@type": "@id"
                },
                "opensearch": "http://a9.com/-/spec/opensearch/1.1/",
                "as": "https://www.w3.org/ns/activitystreams#",
                co_collector: "http://schema.org/colleague"
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

          app.get '/dataset/:id.json' do
            json_headers
            search_dataset_by_uuid(params[:id]).to_json
          end

          app.get '/dataset/:id/badge.svg' do
            svg_headers
            @doc = search_dataset_by_uuid(params[:id])
            if @doc.nil?
              status 404
              haml :dataset_badge_svg_404, layout: false
            else
              haml :dataset_badge_svg, layout: false
            end
          end

          app.get '/:id.json(ld)?' do
            json_ld_headers
            response = {}
            user_by_id
            if @result
              response = {
                "@context": {
                  "@vocab": "http://schema.org/",
                  sameAs: {
                    "@id": "sameAs",
                    "@type": "@id"
                  },
                  co_collector: "https://schema.org/colleague"
                }
              }.merge(format_user_item(@result))
            end
            json_response(response)
          end

        end

      end
    end
  end
end
