class Admin::HealthController < ApplicationController

  # List health of various services
  #
  def index
    @services = [
      {
        :id => HealthReportService::AnotherCollectionPrompt,
        :time => 1.day.ago},
      {
        :id => HealthReportService::FriendsDigest,
        :time => 1.day.ago},
      {
        :id => HealthReportService::MaintainSearchIndex,
        :time => 1.day.ago},
      {
        :id => HealthReportService::AnotherItemPrompt,
        :time => 1.week.ago},
      {
        :id => HealthReportService::AddItemsPrompt,
        :time => 3.days.ago},
      {
        :id => HealthReportService::AddFriendsPrompt,
        :time => 3.days.ago},
      #{
      #  :id => HealthReportService::AddStoresPrompt,
      #  :time => 3.days.ago},
      {
        :id => HealthReportService::AddCollectionsPrompt,
        :time => 3.days.ago}]

    @services.each{|s| s[:report] = HealthReport.for_service(s[:id]).last}
  end

end
