class SearchController < ApplicationController
  def new
    @toilets = Toilet.includes(:station).limit(50)
  end
end
