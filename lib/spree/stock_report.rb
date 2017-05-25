module Spree
  class StockReport
    def initialize(report_params)
      if !report_params[:begin_date] && !report_params[:end_date]
        @begin_date = Time.now - 1.month
        @end_date = Time.now
      else
        @begin_date = report_params[:begin_date]
        @end_date = report_params[:end_date]
      end

      @stock_movements = Spree::StockMovement.
          select('SUM(quantity) AS sum_quantity, stock_item_id').
          where(created_at: [@begin_date..@end_date]).
          where('originator_type': 'Spree::Shipment').
          where('quantity <= 0').
          order('sum_quantity ASC').
          group(:stock_item_id)
    end

    def stock_movements
      moves = []

      @stock_movements.each do |move|
        moves << ReportLine.new(
            move.stock_item.try(:variant).try(:product).try(:name),
            move.stock_item.try(:count_on_hand),
            move.try(:sum_quantity),
            move.stock_item.try(:variant).try(:price),
            move.stock_item.try(:variant).try(:origin_price),
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
        :price,
        :origin_price,
        :sku,
        :available_on
    )

  end
end