class RdfResourceController < ApplicationController
  def show
    @resource = RdfResource.find(params[:id])
    respond_to do |format|
      format.json { render json: @resource }
      format.html { render 'rdf_resources/show' }
    end

  end

end