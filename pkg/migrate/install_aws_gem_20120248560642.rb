class InstallAwsGem < Brant::Migration
  def self.up
    system("sudo gem install aws --version 2.5.6")
  end

  def self.down
    system("sudo gem uninstall aws --version 2.5.6")
  end
end
