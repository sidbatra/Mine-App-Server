class AddUserIdColumnToTickerActions < ActiveRecord::Migration
  def self.up
    add_column :ticker_actions, :user_id, :integer
      
    columns = [:id,:user_id]
    values  = []

    TickerAction.select(:id,:ticker_actionable_id,:ticker_actionable_type).
                 all(:include => :ticker_actionable).each do |t|
      values << [t.id,t.ticker_actionable.user_id] if t.ticker_actionable
    end

    TickerAction.import(columns,values,
                   {:validate => false,
                    :timestamps => false,
                    :on_duplicate_key_update => [:user_id]})

    add_index :ticker_actions, :user_id
  end

  def self.down
    remove_column :ticker_actions, :user_id
  end
end
