module Spree
  class RepeatPurchaseRateReport

    def initialize(report_params)
      if report_params['period']

      else
        report_params['period'] = 'month'
      end



    end




  end
end
