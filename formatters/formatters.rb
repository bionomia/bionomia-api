# encoding: utf-8
class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

module Sinatra
  module BionomiaApi
    module Formatters

      def base_url
        "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      end

      def json_headers
        cross_origin
        content_type "application/json", charset: 'utf-8'
      end

      def json_ld_headers
        cross_origin
        content_type "application/ld+json", charset: 'utf-8'
      end

      def json_response(response)
        if params[:callback]
          content_type "application/x-javascript", charset: 'utf-8'
          params[:callback] + '(' + JSON.pretty_generate(response) + ');'
        else
          JSON.pretty_generate(response)
        end
      end

      def format_reconciled_candidates(response)
        response.map do |n|
          id = n[:_source][:orcid] || n[:_source][:wikidata]
          {
            id: "#{id}",
            name: n[:_source][:fullname],
            type: [
              id: "http://schema.org/Person",
              name: "Person"
            ],
            score: n[:_score].ceil(1),
            match: (n[:_score] >= 40 ? true : false)
          }
        end
      end

      def format_users
        @results.map do |n|
          if n[:_source][:orcid]
            attr = {
              item: {
                "@id": "https://bionomia.net/#{n[:_source][:orcid]}",
                sameAs: "https://orcid.org/#{n[:_source][:orcid]}"
              }
            }
          else
            attr = {
              item: {
                "@id": "https://bionomia.net/#{n[:_source][:wikidata]}",
                sameAs: "http://www.wikidata.org/entity/#{n[:_source][:wikidata]}",
                birthDate: n[:_source][:date_born],
                deathDate: n[:_source][:date_died]
              }
            }
          end
          {
            "@type": "DataFeedItem",
            item: {
              "@type": "Person",
              "@id": "",
              name: n[:_source][:fullname],
              givenName: n[:_source][:given],
              familyName: n[:_source][:family],
              alternateName: [n[:_source][:fullname_reverse]] + n[:_source][:other_names],
              knowsAbout: [{
                "@type": "ItemList",
                name: "families_identified",
                itemListElement: n[:_source][:families_identified].map{|n|
                  { "@type": "ListItem", name: n }
                }
              },
              {
                "@type": "ItemList",
                name: "families_collected",
                itemListElement: n[:_source][:families_collected].map{|n|
                  { "@type": "ListItem", name: n }
                }
              }]
            }
          }.deep_merge(attr)
        end
      end

    end
  end
end
