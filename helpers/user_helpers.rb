# encoding: utf-8

module Sinatra
  module BionomiaApi
    module UserHelpers

      def search_user
        @results = []
        searched_term = params[:q] || nil
        return if !searched_term

        page = (params[:page] || 1).to_i
        limit = (params[:limit] || 30).to_i
        is_public = params[:is_public] || ""
        has_occurrences = params[:has_occurrences] || ""

        opts = {}
        if is_public.downcase == "true"
          opts[:is_public] = true
        elsif is_public.downcase == "false"
          opts[:is_public] = false
        end
        if has_occurrences.downcase == "true"
          opts[:has_occurrences] = true
        elsif has_occurrences.downcase == "false"
          opts[:has_occurrences] = false
        end

        client = Elasticsearch::Client.new(
          url: Settings.elastic.server,
          request_timeout: 5*60,
          retry_on_failure: true,
          reload_on_failure: true,
          reload_connections: 1_000,
          adapter: :typhoeus
        )
        body = build_name_query(searched_term, opts)
        from = (page -1) * limit

        response = client.search index: Settings.elastic.user_index, from: from, size: limit, body: body
        results = JSON.parse(JSON[response["hits"]], symbolize_names: true)

        @pagy = Pagy.new(count: results[:total][:value], items: limit, page: page)
        @results = results[:hits]
      end

      def search_agent
        @results = []
        filters = []
        searched_term = params[:q] || nil
        return if !searched_term

        page = (params[:page] || 1).to_i
        limit = (params[:limit] || 30).to_i

        client = Elasticsearch::Client.new(
          url: Settings.elastic.server,
          request_timeout: 5*60,
          retry_on_failure: true,
          reload_on_failure: true,
          reload_connections: 1_000,
          adapter: :typhoeus
        )
        body = build_name_query(searched_term)
        from = (page -1) * limit

        response = client.search index: Settings.elastic.agent_index, from: from, size: limit, body: body
        results = JSON.parse(JSON[response["hits"]], symbolize_names: true)

        @pagy = Pagy.new(count: results[:total][:value], items: limit, page: page)
        @results = results[:hits]
      end

      def api_search_user
        @results = []
        @pagy = OpenStruct.new
        @pagy.page = 0
        @pagy.pages = 0

        searched_term = params[:q] || nil
        page = (params[:page] || 1).to_i
        limit = (params[:limit] || 30).to_i
        if page <= 0
          page = 1
        end

        if searched_term
          client = Elasticsearch::Client.new(
            url: Settings.elastic.server,
            request_timeout: 5*60,
            retry_on_failure: true,
            reload_on_failure: true,
            reload_connections: 1_000,
            adapter: :typhoeus
          )
          @query = build_user_query(searched_term, params.transform_keys(&:to_sym))
          from = (page -1) * limit

          response = client.search index: Settings.elastic.user_index, from: from, size: limit, body: @query
          results = JSON.parse(JSON[response["hits"]], symbolize_names: true)

          total = results[:total][:value]

          if page*limit > total && total > limit
            page = total % limit == 0 ? total/limit : (total/limit).to_i + 1
          end

          @pagy = Pagy.new(count: total, items: limit, page: page)
          @results = results[:hits]
        end
      end

      def user_by_id
        @result = {}
        searched_term = params[:id] || nil
        return if !searched_term

        client = Elasticsearch::Client.new(
          url: Settings.elastic.server,
          request_timeout: 5*60,
          retry_on_failure: true,
          reload_on_failure: true,
          reload_connections: 1_000,
          adapter: :typhoeus
        )
        body = query_user_by_id(searched_term)

        response = client.search index: Settings.elastic.user_index, body: body
        results = JSON.parse(JSON[response["hits"]], symbolize_names: true)
        @result = results[:hits].first
      end

    end
  end
end
