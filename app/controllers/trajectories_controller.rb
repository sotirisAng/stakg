class TrajectoriesController < ApplicationController
  protect_from_forgery except: :create_trajectory_from_flight
  before_action :set_trajectory, only: %i[ show edit update destroy ]

  # GET /trajectories or /trajectories.json
  def index
    @flights = current_user.flights
    trajectory_ids = @flights.flat_map(&:trajectory_id).uniq
    @trajectories = Trajectory.where(id: trajectory_ids)
  end

  # GET /trajectories/1 or /trajectories/1.json
  def show; end

  # GET /trajectories/new
  def new
    @flights = current_user.flights
    @trajectory = Trajectory.new
  end

  # GET /trajectories/1/edit
  def edit; end

  def create_trajectory_from_flight
    @flight = current_user.flights.find(params[:flight_id])
    unless @flight.trajectory_id.blank?
      @flight.errors.add(:base, "Flight already has a trajectory")
      return
    end
    unless @flight.logfile
      @flight.errors.add(:base, "Cannot create trajectory. No logfile assigned to this flight")
    end
    @trajectory = Trajectory.create_new_from_csv(@flight.logfile)
    @flight.trajectory_id = @trajectory.id
    respond_to do |format|
      if @flight.save
        format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully created." }
        format.json { render :show, status: :created, location: @trajectory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @trajectory.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /trajectories or /trajectories.json
  def create
    @trajectory = Trajectory.new(trajectory_params)

    respond_to do |format|
      if @trajectory.save
        format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully created." }
        format.json { render :show, status: :created, location: @trajectory }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @trajectory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trajectories/1 or /trajectories/1.json
  def update
    respond_to do |format|
      if @trajectory.update(trajectory_params)
        format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully updated." }
        format.json { render :show, status: :ok, location: @trajectory }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @trajectory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trajectories/1 or /trajectories/1.json
  def destroy
    @flight = current_user.flights.find_by(trajectory_id: @trajectory.id)
    @flight.trajectory_id = nil
    @flight.save
    @trajectory.destroy

    respond_to do |format|
      format.html { redirect_to trajectories_url, notice: "Trajectory was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def enrich_trajectory_with_weather
    return unless flight_for_trajectory

    set_trajectory
    @trajectory.get_weather_at_start
    respond_to do |format|
      format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully enriched with weather data." }
      format.json { render :show, status: :ok, location: @trajectory }
    end
  end

  def create_recording_segments
    return unless flight_for_trajectory

    set_trajectory
    @trajectory.create_recording_segments
    respond_to do |format|
      format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully enriched with recording segments." }
      format.json { render :show, status: :ok, location: @trajectory }
    end
  end

  def enrich_with_pois_from_aegean
    return unless flight_for_trajectory

    set_trajectory
    @trajectory.enrich_records_from_aegean
    respond_to do |format|
      format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully enriched with POIs from Aegean RDF Geospatial Repository." }
      format.json { render :show, status: :ok, location: @trajectory }
    end
  end

  def enrich_with_pois_from_osm
    return unless flight_for_trajectory

    set_trajectory
    @trajectory.enrich_records_from_osm
    respond_to do |format|
      format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully enriched with POIs from OSM." }
      format.json { render :show, status: :ok, location: @trajectory }
    end
  end

  def add_recording_positions_from_flight_records
    return unless flight_for_trajectory

    set_trajectory
    flight_records = @flight.flight_file
    @trajectory.add_recording_positions_from_csv(flight_records)
    respond_to do |format|
      format.html { redirect_to trajectory_url(@trajectory), notice: "Trajectory was successfully enriched with recording positions from flight records." }
      format.json { render :show, status: :ok, location: @trajectory }
    end
  end




  private

  def flight_for_trajectory
    (@flight = current_user.flights.find_by(trajectory_id: params[:id]))
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_trajectory
    @trajectory = Trajectory.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def trajectory_params
    params.require(:trajectory).permit(:name)
  end
end
