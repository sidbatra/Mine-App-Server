class MoveTopShoppersToIntegerForColumn < ActiveRecord::Migration
  def self.up
    AchievementSet.update_all({:for => AchievementSetFor::StarUsers},{:for => 'star_users'})
    AchievementSet.update_all({:for => AchievementSetFor::TopShoppers},{:for => 'top_shoppers'})

    change_column :achievement_sets, :for, :integer
  end

  def self.down
    change_column :achievement_sets, :for, :string

    AchievementSet.update_all({:for => 'star_users'},{:for => AchievementSetFor::StarUsers})
    AchievementSet.update_all({:for => 'top_shoppers'},{:for => AchievementSetFor::TopShoppers})
  end
end
