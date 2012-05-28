# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mine_session',
  :secret      => '85ca2d9c80f94d8a14dc4e8631789d79898bd961d7e98bee503b5960df750ddae0ba3430f0693b3e35d015fd61a61e3eb42a0052b79e7128c95b4fc564eafcc8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
 ActionController::Base.session_store = :active_record_store
