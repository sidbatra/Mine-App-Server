class MakeCommentsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :comments, :commentable_type, :string
    add_column :comments, :commentable_id, :integer

    Comment.all.each do |comment|
      comment.commentable_id = comment.product_id
      comment.commentable_type = 'Product'
      comment.save!
    end

    remove_column :comments, :product_id

    add_index :comments, [:commentable_id,:commentable_type]
  end

  def self.down
    add_column :comments, :product_id, :integer

    Comment.all.each do |comment|
      comment.product_id = comment.commentable_id
      comment.save!
    end

    remove_column :comments, :commentable_id
    remove_column :comments, :commentable_type

    add_index :comments, :product_id
  end
end
