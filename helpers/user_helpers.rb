# encoding: utf-8

module Sinatra
  module BionomiaApi
    module UserHelpers

      def search_user
        @results = []
        searched_term = params[:q] || nil
        return if !searched_term

        page = (params[:page] || 1).to_i

        client = Elasticsearch::Client.new url: Settings.elastic.server, request_timeout: 5*60, retry_on_failure: true, reload_on_failure: true
        client.transport.reload_connections!
        body = build_name_query(searched_term)
        from = (page -1) * 30

        response = client.search index: Settings.elastic.user_index, from: from, size: 30, body: body
        results = JSON.parse(JSON[response["hits"]], symbolize_names: true)

        @pagy = Pagy.new(count: results[:total][:value], items: 30, page: page)
        @results = results[:hits]
      end

      def api_search_user
        @results = []
        @pagy = OpenStruct.new
        @pagy.page = 0
        @pagy.pages = 0
        items = 30
        searched_term = params[:q] || nil
        page = (params[:page] || 1).to_i
        if page <= 0
          page = 1
        end

        if searched_term
          client = Elasticsearch::Client.new url: Settings.elastic.server, request_timeout: 5*60, retry_on_failure: true, reload_on_failure: true
          client.transport.reload_connections!
          @query = build_user_query(searched_term, params.transform_keys(&:to_sym))
          from = (page -1) * 30

          response = client.search index: Settings.elastic.user_index, from: from, size: items, body: @query
          results = JSON.parse(JSON[response["hits"]], symbolize_names: true)

          total = results[:total][:value]

          if page*items > total && total > items
            page = total % items == 0 ? total/items : (total/items).to_i + 1
          end

          @pagy = Pagy.new(count: total, items: items, page: page)
          @results = results[:hits]
        end
      end

    end
  end
end
