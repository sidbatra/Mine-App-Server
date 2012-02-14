class ConvertLikesToWants < ActiveRecord::Migration
  def self.up
    Action.find_all_by_name(
            ActionName::Like, 
            :include    => :actionable,
            :conditions => {:actionable_type => 'Product'}).each do |action|

      Action.find_or_create_by_actionable_id_and_actionable_type_and_name_and_user_id(
              action.actionable_id,
              action.actionable_type,
              ActionName::Want,
              action.user_id) unless action.user_id == action.actionable.user_id

      action.destroy
    end
  end

  def self.down
  end
end
