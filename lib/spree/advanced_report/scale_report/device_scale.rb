class Spree::AdvancedReport::ScaleReport::DeviceScale < Spree::AdvancedReport
  def name
    "Profit by Geography"
  end


  def description
    "Profit divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

  end
end
