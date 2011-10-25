module Admin::UsersHelper

  # Generate age range from the bucket number
  #
  def age_range(bucket)
    (bucket*CONFIG[:age_bucket_size]).to_s + "--" + 
    ((bucket+1)*CONFIG[:age_bucket_size]-1).to_s
  end

end
