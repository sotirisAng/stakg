class CreatePoint < ActiveGraph::Migrations::Base
  disable_transactions!

  def up
    add_constraint :Point, :uuid
  end

  def down
    drop_constraint :Point, :uuid
  end
end
