# encoding: utf-8

module Sinatra
  module BionomiaApi
    module Queries

      def query_user_by_id(id)
        {
          query: {
            bool: {
              should: [
                { term: { orcid: { value: id } } },
                { term: { wikidata: { value: id } } }
              ]
            }
          }
        }
      end

      def parse_names
        output = []
        return output if params[:names].nil?
        lines = params[:names].split("\r\n")[0..999]
        lines.each do |line|
          item = { original: line.dup, parsed: [] }
          parsed_names = DwcAgent.parse(line)
          parsed_names.each do |name|
            item[:parsed] << DwcAgent.clean(name).to_h
          end
          output << item
        end
        output
      end

      def build_name_query(search, obj = {})
        qry = {
            query: {
              bool: {
                must: [
                  {
                    multi_match: {
                      query:      search,
                      type:       :cross_fields,
                      analyzer:   :fullname_index,
                      fields:     [
                        "family^3",
                        "given",
                        "fullname^5",
                        "other_names",
                        "*.edge"
                      ],
                    }
                  }
                ],
                should: [
                  rank_feature: {
                    field: "rank"
                  }
                ],
                filter: []
              }
            },
            sort: [
              "_score",
              { family: { order: :asc } },
              { given: { order: :asc } }
            ]
          }
        if obj.has_key? :is_public
          qry[:query][:bool][:filter] << { term: { is_public: obj[:is_public] } }
        end
        if obj.has_key? :has_occurrences
          qry[:query][:bool][:filter] << { term: { has_occurrences: obj[:has_occurrences] } }
        end
        qry
      end

      def build_user_query(name, obj = {})
        body = {
            query: {
              bool: {
                must: [
                  multi_match: {
                    query:      name,
                    type:       :cross_fields,
                    analyzer:   :fullname_index,
                    fields:     ["family^5", "given^3", "fullname", "other_names", "*.edge"],
                  }
                ],
                should: []
              }
            }
          }
        if obj.has_key?(:strict) && obj[:strict].downcase == "true"
          must_should = :must
        else
          must_should = :should
        end
        if obj.has_key?(:families_collected)
          collected = obj[:families_collected].is_a?(String) ? obj[:families_collected].split(",") : obj[:families_collected]
          collected.each do |family|
            body[:query][:bool][must_should] << { nested: { path: "recorded", query: { term: { "recorded.family": family } } } }
          end
        end
        if obj.has_key?(:families_identified)
          identified = obj[:families_identified].is_a?(String) ? obj[:families_identified].split(",") : obj[:families_identified]
          identified.each do |family|
            body[:query][:bool][must_should] << { nested: { path: "identified", query: { term: { "identified.family": family } } } }
          end
        end
        if obj.has_key?(:date)
          date = /\A\d{4}\z/.match?(obj[:date]) ? "#{obj[:date]}-01-01" : obj[:date]
          date = /\A\d{4}-\d{2}\z/.match(date) ? "#{date}-01" : date
          date = DateTime.parse(date).strftime('%Y-%m-%d') rescue nil
          if date
            body[:query][:bool][must_should] << { range: { date_born: { lt: date } }}
            body[:query][:bool][must_should] << { range: { date_died: { gte: date } }}
          end
        end
        body
      end

    end
  end
end
