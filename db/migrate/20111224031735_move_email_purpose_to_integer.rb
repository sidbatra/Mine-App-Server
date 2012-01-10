class MoveEmailPurposeToInteger < ActiveRecord::Migration
  def self.up

    Email.update_all(
      {:purpose => EmailPurpose::NewComment},
      {:purpose => 'new_comment'})

    Email.update_all(
      {:purpose => EmailPurpose::NewFollower},
      {:purpose => 'new_follower'})

    Email.update_all(
      {:purpose => EmailPurpose::NewBulkFollowers},
      {:purpose => 'new_bulk_followers'})

    Email.update_all(
      {:purpose => EmailPurpose::StarUser},
      {:purpose => 'star_user'})

    Email.update_all(
      {:purpose => EmailPurpose::TopShopper},
      {:purpose => 'top_shopper'})

    Email.update_all(
      {:purpose => EmailPurpose::NewAction},
      {:purpose => 'new_action'})

    Email.update_all(
      {:purpose => EmailPurpose::Dormant},
      {:purpose => 'dormant'})

    Email.update_all(
      {:purpose => EmailPurpose::OnToday},
      {:purpose => 'ontoday'})

    Email.update_all(
      {:purpose => EmailPurpose::CollectMore},
      {:purpose => 'collect_more'})

    Email.update_all(
      {:purpose => EmailPurpose::InviteMore},
      {:purpose => 'invite_more'})

    change_column :emails, :purpose, :integer
  end

  def self.down
    change_column :emails, :purpose, :string

    Email.update_all(
      {:purpose => 'new_comment'},
      {:purpose => EmailPurpose::NewComment})

    Email.update_all(
      {:purpose => 'new_follower'},
      {:purpose => EmailPurpose::NewFollower})

    Email.update_all(
      {:purpose => 'new_bulk_followers'},
      {:purpose => EmailPurpose::NewBulkFollowers})

    Email.update_all(
      {:purpose => 'star_user'},
      {:purpose => EmailPurpose::StarUser})

    Email.update_all(
      {:purpose => 'top_shopper'},
      {:purpose => EmailPurpose::TopShopper})

    Email.update_all(
      {:purpose => 'new_action'},
      {:purpose => EmailPurpose::NewAction})

    Email.update_all(
      {:purpose => 'dormant'},
      {:purpose => EmailPurpose::Dormant})

    Email.update_all(
      {:purpose => 'ontoday'},
      {:purpose => EmailPurpose::OnToday})

    Email.update_all(
      {:purpose => 'collect_more'},
      {:purpose => EmailPurpose::CollectMore})

    Email.update_all(
      {:purpose => 'invite_more'},
      {:purpose => EmailPurpose::InviteMore})
  end
end
