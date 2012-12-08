class Admin::HealthController < ApplicationController
  layout 'admin'

  # List health of various services
  #
  def index
    @services = [
      {
        :id => HealthReportService::FriendsDigest,
        :time => 4.days.ago},
      {
        :id => HealthReportService::MaintainSearchIndex,
        :time => 1.day.ago},
      {
        :id => HealthReportService::MaintainEmailList,
        :time => 1.day.ago},
      {
        :id => HealthReportService::AddPurchaseEmails,
        :time => 1.week.ago},
      {
        :id => HealthReportService::MinePurchaseEmails,
        :time => 1.week.ago}]

    @services.each{|s| s[:report] = HealthReport.for_service(s[:id]).last}
  end

end
