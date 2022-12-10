class TrajectoriesController < ApplicationController
  before_action :set_trajectory, only: %i[ show edit update destroy ]

  # GET /trajectories or /trajectories.json
  def index
    @trajectories = Trajectory.all
  end

  # GET /trajectories/1 or /trajectories/1.json
  def show
  end

  # GET /trajectories/new
  def new
    @trajectory = Trajectory.new
  end

  # GET /trajectories/1/edit
  def edit
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
    @trajectory.destroy

    respond_to do |format|
      format.html { redirect_to trajectories_url, notice: "Trajectory was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trajectory
      @trajectory = Trajectory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def trajectory_params
      params.require(:trajectory).permit(:name)
    end
end
