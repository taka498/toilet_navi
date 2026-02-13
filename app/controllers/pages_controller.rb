class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home terms privacy contact]

  def home; end
  def terms; end
  def privacy; end
  def contact; end
end
