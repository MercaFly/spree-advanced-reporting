class Spree::ProductReport::NoDescription < Spree::ProductReport

  def name
    "No Description Report"
  end

  def description
    "No Description Report"
  end

  def initialize(params)
    @product = Spree::Product.all.select { |p| p.description = '' }
  end


end
