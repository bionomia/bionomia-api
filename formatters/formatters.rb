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
        content_type "application/json", charset: 'utf-8'
      end

      def svg_headers
        content_type "image/svg+xml", charset: 'utf-8'
      end

      def json_ld_headers
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

      def format_user(n)
        lifespan = n[:_source][:wikidata] ? format_lifespan(n[:_source]) : nil
        uri = n[:_source][:wikidata] \
                ? "http://www.wikidata.org/entity/#{n[:_source][:wikidata]}" \
                : "https://orcid.org/#{n[:_source][:orcid]}"
        { id: n[:_source][:id],
          score: n[:_score],
          orcid: n[:_source][:orcid],
          wikidata: n[:_source][:wikidata],
          uri: uri,
          fullname: n[:_source][:fullname],
          fullname_reverse: n[:_source][:fullname_reverse],
          other_names: n[:_source][:other_names],
          thumbnail: n[:_source][:thumbnail],
          lifespan: lifespan,
          description: n[:_source][:description],
          is_public: n[:_source][:is_public],
          has_occurrences: n[:_source][:has_occurrences]
        }
      end

      def format_agent(n)
        { id: n[:_source][:id],
          score: n[:_score],
          fullname: n[:_source][:fullname],
          fullname_reverse: n[:_source][:fullname_reverse]
        }
      end

      def format_autocomplete
        @results.map{ |n| format_user(n) }
      end

      def format_autocomplete_agent
        @results.map{ |n| format_agent(n) }
      end

      def format_users
        @results.map do |n|
          {
            "@type": "DataFeedItem",
            item: format_user_item(n)
          }
        end
      end

      def format_user_item(n)
        return {} if !n
        if n[:_source][:orcid]
          attr = {
            "@id": "https://bionomia.net/#{n[:_source][:orcid]}",
            sameAs: "https://orcid.org/#{n[:_source][:orcid]}"
          }
        else
          attr = {
            "@id": "https://bionomia.net/#{n[:_source][:wikidata]}",
            sameAs: "http://www.wikidata.org/entity/#{n[:_source][:wikidata]}",
            birthDate: n[:_source][:date_born],
            deathDate: n[:_source][:date_died]
          }
        end
        {
          "@type": "Person",
          "@id": "",
          sameAs: "",
          name: n[:_source][:fullname],
          givenName: n[:_source][:given],
          familyName: n[:_source][:family],
          alternateName: [n[:_source][:fullname_reverse]] + n[:_source][:other_names],
          co_collector: n[:_source][:co_collectors].map do |colleague|
            - same_as = colleague[:orcid] ? "https://orcid.org/#{colleague[:orcid]}" : "http://www.wikidata.org/entity/#{colleague[:wikidata]}"
            {
              "@type": "Person",
              "@id": "https://bionomia.net/#{colleague[:orcid] || colleague[:wikidata]}",
              sameAS: same_as,
              name: colleague[:fullname]
            }
          end,
          knowsAbout: [{
            "@type": "ItemList",
            name: "families_identified",
            itemListElement: n[:_source][:identified].map{|n|
              { "@type": "ListItem", name: n[:family] }
            }.uniq
          },
          {
            "@type": "ItemList",
            name: "families_collected",
            itemListElement: n[:_source][:recorded].map{|n|
              { "@type": "ListItem", name: n[:family] }
            }.uniq
          }]
        }.merge(attr)
      end

      def format_lifespan(user)
        date_born = Date.parse(user[:date_born]) rescue nil
        date_died = Date.parse(user[:date_died]) rescue nil

        if user[:date_born_precision] == "day"
          born = date_born.strftime('%B %e, %Y')
        elsif user[:date_born_precision] == "month"
          born = date_born.strftime('%B %Y')
        elsif user[:date_born_precision] == "year"
          born = date_born.strftime('%Y')
        else
          born = "?"
        end

        if user[:date_died_precision] == "day"
          died = date_died.strftime('%B %e, %Y')
        elsif user[:date_died_precision] == "month"
          died = date_died.strftime('%B %Y')
        elsif user[:date_died_precision] == "year"
          died = date_died.strftime('%Y')
        else
          died = "?"
        end

        ["&#42; " + born, died + " &dagger;"].join(" &ndash; ")
      end

    end
  end
end
