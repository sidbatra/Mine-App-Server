class Admin::HealthController < ApplicationController

  # List health of various services
  #
  def index
    @services = [
      {
        :id => HealthReportService::FriendsDigest,
        :time => 1.week.ago},
      {
        :id => HealthReportService::MaintainSearchIndex,
        :time => 1.day.ago},
      {
        :id => HealthReportService::AfterJoinEmails,
        :time => 1.day.ago}]

    @services.each{|s| s[:report] = HealthReport.for_service(s[:id]).last}
  end

end
