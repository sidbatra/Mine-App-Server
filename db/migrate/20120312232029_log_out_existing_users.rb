class LogOutExistingUsers < ActiveRecord::Migration
  def self.up

    columns = [:id,:remember_token_expires_at,:remember_token] 
    values  = User.all.map{|u| [u.id,nil,nil]} 

    User.import columns, values, 
      {:validate => false, 
       :timestamps => false,
       :on_duplicate_key_update => [:remember_token_expires_at,
                                    :remember_token]}

  end

  def self.down
  end
end
