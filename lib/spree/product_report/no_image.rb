class Spree::ProductReport::NoImage < Spree::ProductReport

  def name
    "No Image Report"
  end

  def description
    "No Image Report"
  end

  def initialize(params)
    @product = Spree::Product.all.select { |p| p.images.count == 0 }
  end

  ReportLine = Struct.new(
    :name,
  )

  def products
    products = []

    @product.each do |p|
      products << ReportLine.new(
        p.name
      )
    end
    products
  end
end
