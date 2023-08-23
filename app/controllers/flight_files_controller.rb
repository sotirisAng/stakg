class FlightFilesController < ApplicationController
  before_action :set_flight_file, only: %i[ show edit update destroy get_file]
  after_action :create_csv_from_files, only: %i[ create update ]

  # GET /flight_files or /flight_files.json
  def index
    @flight_files = current_user.flight_files.all
  end

  # GET /flight_files/1 or /flight_files/1.json
  def show
  end

  # GET /flight_files/new
  def new
    @flight_file = FlightFile.new
    @flights = current_user.flights.all
  end

  # GET /flight_files/1/edit
  def edit
    @flights = current_user.flights.all
  end

  # POST /flight_files or /flight_files.json
  def create
    @flight_file = FlightFile.new(flight_file_params)
    @flight_file.user = current_user
    respond_to do |format|
      if @flight_file.save
        format.html { redirect_to flight_file_url(@flight_file), notice: "Flight file was successfully created." }
        format.json { render :show, status: :created, location: @flight_file }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @flight_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flight_files/1 or /flight_files/1.json
  def update
    @flight_file.user = current_user
    respond_to do |format|
      if @flight_file.update(flight_file_params)
        format.html { redirect_to flight_file_url(@flight_file), notice: "Flight file was successfully updated." }
        format.json { render :show, status: :ok, location: @flight_file }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @flight_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flight_files/1 or /flight_files/1.json
  def destroy
    @flight_file.destroy

    respond_to do |format|
      format.html { redirect_to flight_files_url, notice: "Flight file was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def get_file
    send_file @flight_file.file_path, type: "text/csv", x_sendfile: true
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_flight_file
    @flight_file = current_user.flight_files.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "You do not have access to this resource."
  end

  # Only allow a list of trusted parameters through.
  def flight_file_params
    params.require(:flight_file).permit(:collection_name, :files_type, :flight_id, files: [])
  end

  def create_csv_from_files
    @flight_file.create_csv_from_files
  end
end
