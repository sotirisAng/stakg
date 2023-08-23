class CreateLogfile < ActiveGraph::Migrations::Base
  disable_transactions!

  def up
    add_constraint :Logfile, :uuid
  end

  def down
    drop_constraint :Logfile, :uuid
  end
end
