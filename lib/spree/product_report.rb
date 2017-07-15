class Spree::ProductReport
  def name
    "Base Advanced Report"
  end

  def description
    "Base Advanced Report"
  end

  def initialize(params)

  end

  ReportLine = Struct.new(
    :name
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

  def to_csv
    products = self.products.collect(&:values)
    CSV.generate do |csv|
      csv << [
        'product_name'
      ]
      products.each do |li|
        csv << li
      end
    end
  end

end