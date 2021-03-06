module Spree
  class ProductSalesReport

    attr_accessor :ruportdata, :data, :params, :taxon, :product, :product_in_taxon, :unfiltered_params

    def sales

      sales = []
      @product_sales = Spree::ProductSale.includes(:product).order('sold desc')

      @product_sales.each do |s|
        @variants = Spree::Variant.find_by(:product_id => s.try(:product_id))
        sales << ReportLine.new(
          s.try(:product).try(:name),
          @variants.try(:sku),
          @variants.try(:weight),
          s.try(:taxon),
          s.try(:brand),
          s.try(:count_on_hand),
          s.try(:sold),
          s.try(:cost_price),
          s.try(:price),
          s.try(:origin_price),
          s.try(:sold_days),
          s.try(:no_stock_days)
        )
      end
      sales
    end

    def to_csv
      sales = self.sales.collect(&:values)
      CSV.generate do |csv|
        csv << [
            'product_name',
            'sku',
            'weight',
            'taxon',
            'brand',
            'count_on_hand',
            'sold',
            'cost_price',
            'price',
            'origin_price',
            'sold_days',
            'no_stock_days'
        ]
        sales.each do |li|
          csv << li
        end
      end
    end

    ReportLine = Struct.new(
        :product_name,
        :sku,
        :weight,
        :taxon,
        :brand,
        :count_on_hand,
        :sold,
        :cost_price,
        :price,
        :origin_price,
        :sold_days,
        :no_stock_days
    )

  end
end