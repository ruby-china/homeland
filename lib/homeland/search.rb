module Homeland
  class Search
    attr_accessor :term, :terms

    INVALID_CHARS = /[:()&!'"]/

    def initialize(term)
      if term.present?
        term = term.to_s.squish.gsub(INVALID_CHARS, "")
        @terms = Search.jieba.cut(term)
        @term = @terms.join(" ")

        @results = []
      end
    end

    def query_results
      SearchDocument.select("ts_headline(search_documents.content, #{ts_query}) as hit_content")
        .select(:id, :searchable_type, :searchable_id)
        .where("tokens @@ #{ts_query}")
        .order("#{ts_query} DESC")
        .order("TS_RANK_CD(tokens, #{ts_query}) DESC")
    end

    class << self
      def jieba
        return @jieba if defined? @jieba

        @jieba = JiebaRb::Segment.new
      end
    end

    def self.prepare_data(q)
      jieba.cut(q.squish).join(" ")
    end

    def ts_query
      @ts_query ||= begin
                      all_terms = @term.split
                      query = SearchDocument.sanitize_sql(all_terms.map { |t| "#{PG::Connection.escape_string(t)}:*" }.join(" & "))
                      "TO_TSQUERY('simple', '#{query}')"
                    end
    end
  end
end
