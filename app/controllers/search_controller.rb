class SearchController < ApplicationController
  allow_unauthenticated_access only: %i[new]

  def new; end
end
