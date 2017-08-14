module Spree
  class StockReport

    attr_accessor :ruportdata, :data, :params, :taxon, :product, :product_in_taxon, :unfiltered_params

    def initialize(report_params)
      #{advanced_reporting"=>{"taxon_id"=>"2001", "product_id"=>""}, "search"=>{"completed_at_gt"=>"2017/08/01", "completed_at_lt"=>"2017/08/02"}, "button"=>"", "controller"=>"spree/admin/reports", "action"=>"stock"}

      if report_params[:search][:completed_at_gt] == '' || report_params[:search][:completed_at_lt] == ''
        @begin_date = Time.now - 1.month
        @end_date = Time.now
      else
        @begin_date = report_params[:search][:completed_at_gt]
        @end_date = report_params[:search][:completed_at_lt]
      end

      self.product_in_taxon = true
      if report_params[:advanced_reporting]
        if report_params[:advanced_reporting][:taxon_id] && report_params[:advanced_reporting][:taxon_id] != ''
          self.taxon = Taxon.find(report_params[:advanced_reporting][:taxon_id])
        end
        if report_params[:advanced_reporting][:product_id] && report_params[:advanced_reporting][:product_id] != ''
          self.product = Product.find(report_params[:advanced_reporting][:product_id])
        end
      end
      if self.taxon && self.product && !self.product.taxons.include?(self.taxon)
        self.product_in_taxon = false
      end

      @stock_movements = Spree::StockMovement.
          includes(stock_item: [variant: [:product, :prices, :origin_prices]]).
          select('SUM(quantity) AS sum_quantity, stock_item_id').
          where(created_at: [@begin_date..@end_date]).
          where(:originator_type => 'Spree::Shipment').
          where('quantity <= 0').
          order('sum_quantity ASC').
          group(:stock_item_id)
    end

    def stock_movements
      moves = []
      if !self.product.nil? && product_in_taxon
        @stock_movements = @stock_movements.select { |m| m.stock_item.try(:variant).try(:product) == self.product }
      elsif !self.taxon.nil?
        @stock_movements = @stock_movements.select { |m| m.stock_item.try(:variant).try(:product) && m.stock_item.try(:variant).try(:product).taxons.include?(self.taxon) }
      end

      @stock_movements.each do |move|
        moves << ReportLine.new(
            move.stock_item.try(:variant).try(:product).try(:name),
            move.stock_item.try(:count_on_hand),
            move.try(:sum_quantity),
            move.stock_item.try(:variant).try(:cost_price),
            move.stock_item.try(:variant).try(:prices).try(:first).try(:amount),
            move.stock_item.try(:variant).try(:origin_prices).try(:first).try(:amount),
            move.stock_item.try(:variant).try(:sku),
            move.stock_item.try(:variant).try(:product).try(:available_on),
        )
      end
      moves
    end

    def to_csv
      stock_movements = self.stock_movements.collect(&:values)
      CSV.generate do |csv|
        csv << [
            'product_name',
            'count_on_hand',
            'sold',
            'cost_price',
            'price',
            'origin_price',
            'sku',
            'available_on'
        ]
        stock_movements.each do |li|
          csv << li
        end
      end
    end

    ReportLine = Struct.new(
        :product_name,
        :count_on_hand,
        :sold,
        :cost_price,
        :price,
        :origin_price,
        :sku,
        :available_on
    )

  end
end