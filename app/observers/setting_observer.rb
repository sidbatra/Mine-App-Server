class SettingObserver < ActiveRecord::Observer

  def before_create(setting)
    setting.theme_id = Theme.default.id
  end

end

