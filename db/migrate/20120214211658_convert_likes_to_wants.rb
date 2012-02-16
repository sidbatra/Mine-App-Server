class ConvertLikesToWants < ActiveRecord::Migration
  def self.up

    columns = [:actionable_id, :actionable_type, :name, :user_id]
    values  = []
    ids     = []

    Action.find_all_by_name(
            ActionName::Like, 
            :include    => :actionable,
            :conditions => {:actionable_type => 'Product'}).each do |action|

      values << [action.actionable_id,
                action.actionable_type,
                ActionName::Want,
                action.user_id] unless action.user_id == action.actionable.user_id

      ids << action.id
    end

    Action.delete_all(:id => ids)

    Action.import columns, values

    columns = [:id,:actions_count]
    values  = Product.all(:include => :actions).map{|p| [p.id,p.actions.length]}

    Product.import columns, values, 
      {:validate => false, :on_duplicate_key_update => [:actions_count,:updated_at]}
  end

  def self.down
  end
end
