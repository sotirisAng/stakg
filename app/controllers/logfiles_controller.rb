class LogfilesController < ApplicationController
  before_action :set_logfile, only: %i[ show edit update destroy ]

  # GET /logfiles or /logfiles.json
  def index
    @logfiles = current_user.logfiles.all
  end

  # GET /logfiles/1 or /logfiles/1.json
  def show
  end

  # GET /logfiles/new
  def new
    @logfile = Logfile.new
    @flights = current_user.flights
  end

  # GET /logfiles/1/edit
  def edit
    @flights = current_user.flights
  end

  def get_url_for_file
    @logfile = current_user.logfiles.find(params[:id])
    url_for(@logfile.file)
  end

  def get_file
    @logfile = current_user.logfiles.find(params[:id])
    send_file @logfile.file_path, type: 'text/csv', x_sendfile: true
  end

  # POST /logfiles or /logfiles.json
  def create
    @logfile = Logfile.new(logfile_params)
    @flights = current_user.flights
    @logfile.user = current_user

    respond_to do |format|
      if @logfile.save
        format.html { redirect_to logfile_url(@logfile), notice: "Logfile was successfully created." }
        format.json { render :show, status: :created, location: @logfile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @logfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /logfiles/1 or /logfiles/1.json
  def update
    @logfile.user = current_user
    respond_to do |format|
      if @logfile.update(logfile_params)
        format.html { redirect_to logfile_url(@logfile), notice: "Logfile was successfully updated." }
        format.json { render :show, status: :ok, location: @logfile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @logfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /logfiles/1 or /logfiles/1.json
  def destroy
    @logfile.destroy

    respond_to do |format|
      format.html { redirect_to logfiles_url, notice: "Logfile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_logfile
    @logfile = current_user.logfiles.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "You do not have access to this resource."
  end

  # Only allow a list of trusted parameters through.
  def logfile_params
    params.require(:logfile).permit(:name, :pilot_type, :file_type, :flight_id, :file)
  end
end
