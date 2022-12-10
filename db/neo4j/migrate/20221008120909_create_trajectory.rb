class CreateTrajectory < ActiveGraph::Migrations::Base
  disable_transactions!

  def up
    add_constraint :Trajectory, :uuid
  end

  def down
    drop_constraint :Trajectory, :uuid
  end
end
