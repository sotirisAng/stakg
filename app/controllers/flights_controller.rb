class FlightsController < ApplicationController
  before_action :set_flight, only: %i[ show edit update destroy create_trajectory_from_flight ]

  # GET /flights or /flights.json
  def index
    @flights = current_user.flights.all
  end

  # GET /flights/1 or /flights/1.json
  def show
  end

  # GET /flights/new
  def new
    @flight = Flight.new
  end

  # GET /flights/1/edit
  def edit
  end

  # POST /flights or /flights.json
  def create
    @flight = Flight.new(flight_params)
    @flight.user = current_user
    respond_to do |format|
      # @flight.logfile.save
      # @flight.flight_file.save
      if @flight.save
        format.html { redirect_to flight_url(@flight), notice: "Flight was successfully created." }
        format.json { render :show, status: :created, location: @flight }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flights/1 or /flights/1.json
  def update
    @flight.user = current_user
    respond_to do |format|
      if @flight.update(flight_params)
        format.html { redirect_to flight_url(@flight), notice: "Flight was successfully updated." }
        format.json { render :show, status: :ok, location: @flight }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flights/1 or /flights/1.json
  def destroy
    @flight.destroy

    respond_to do |format|
      format.html { redirect_to flights_url, notice: "Flight was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def create_trajectory_from_flight
    unless @flight.trajectory_id.blank?
      @flight.errors.add(:base, "Flight already has a trajectory")
      return
    end
    unless @flight.logfile
      @flight.errors.add(:base, "Cannot create trajectory. No logfile assigned to this flight")
    end
    trajectory = Trajectory.create_new_from_csv(@flight.logfile)
    @flight.trajectory_id = trajectory.id
    respond_to do |format|
      if @flight.save
        format.html { redirect_to flight_url(@flight), notice: "Trajectory was successfully created." }
        format.json { render :show, status: :created, location: @flight }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flight
      @flight = current_user.flights.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "You do not have access to this resource."
    end

    # Only allow a list of trusted parameters through.
    def flight_params
      params.require(:flight).permit(:name, :description)

      #   params.require(:flight).permit(:name, logfile_attributes: [:name, :pilot_type, :file_type, :file ], flight_file_attributes: [:collection_name, :files_type, :flight_id, files: []])
      # #
    end

end

