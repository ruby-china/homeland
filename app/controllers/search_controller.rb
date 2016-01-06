class SearchController < ApplicationController
  def index
    search_params = {
      query: {
        query_string: {
          query: params[:q],
          default_operator: 'AND',
          minimum_should_match: '90%'
        }
      },
      highlight: {
        pre_tags: ["[h]"],
        post_tags: ["[/h]"],
        fields: { title: {}, body: {}, name: {}, login: {} }
      }
    }
    @result = Elasticsearch::Model.search(search_params, [User, Page, Topic]).paginate(page: params[:page], per_page: 30)
  end
end
