class CreateUpload < ActiveGraph::Migrations::Base
  disable_transactions!

  def up
    add_constraint :Upload, :uuid
  end

  def down
    drop_constraint :Upload, :uuid
  end
end
