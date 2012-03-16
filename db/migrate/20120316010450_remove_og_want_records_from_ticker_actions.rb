class RemoveOgWantRecordsFromTickerActions < ActiveRecord::Migration
  def self.up
    TickerAction.delete_all(:og_action_type => OGAction::Want)
  end

  def self.down
  end
end
