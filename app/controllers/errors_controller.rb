class ErrorsController < ApplicationController

  add_breadcrumb "Home", :root_path

  def not_found
    render :status => 404
  end
 
  def internal_error
    render :status => 500
  end
end
