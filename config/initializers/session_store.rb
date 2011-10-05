# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_hasit_session',
  :secret      => '65673ecd72cb0e185df2ebea9cb543670449df5c524d2c45f3a1557555c31e6cb8d02c4f9265d4d0e9e9486edcdd61f72857a995d307a48b860ef21c9134a375'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
