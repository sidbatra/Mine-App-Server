# Observe events on the Comment model to keep 
# comment related cache stores persistent
#
class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  # Fired when a comment is created
  #
  def after_create(comment)
    expire_comments(comment)
    expire_commentable_collections(comment)
  end

  # Fired when a comment is updated
  #
  def after_update(comment)
    expire_comments(comment)
    expire_commentable_collections(comment)
  end

  # Fired when a comment is destroyed
  #
  def after_destroy(comment)
    expire_comments(comment)
    expire_commentable_collections(comment)
  end

  # Expire comments for the associated commentable
  #
  def expire_comments(comment)
    expire_cache(KEYS[:comment_commentable] % 
        [comment.commentable_id,comment.commentable_type])
  end

  # Expire collections cache for user whose collection
  # has been commented on
  #
  def expire_commentable_collections(comment)
    if comment.commentable_type == Collection.name 
      expire_cache(KEYS[:user_collections] % comment.commentable.user_id)
    end
  end
end
