class Spree::AdvancedReport::IncrementReport::Total < Spree::AdvancedReport::IncrementReport
  def name
    "Total"
  end

  def column
    "Total"
  end

  def description
    "The sum of order total prices, contains shipping and tax"
  end

  def initialize(params)
    super(params)
    self.total = 0

    self.orders.each do |order|
      date = {}
      INCREMENTS.each do |type|
        date[type] = get_bucket(type, order.completed_at)
        data[type][date[type]] ||= {
          :value => 0,
          :display => get_display(type, order.completed_at)
        }
      end
      t = order.total
      if !self.product.nil? && product_in_taxon
        t = order.line_items.select { |li| li.product == self.product }.inject(0) { |a, b| a += b.quantity * b.price }
      elsif !self.taxon.nil?
        t = order.line_items.select { |li| li.product && li.product.taxons.include?(self.taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
      end
      t = 0 if !self.product_in_taxon
      INCREMENTS.each { |type| data[type][date[type]][:value] += t }

      self.total += t

    end

    generate_ruport_data

    INCREMENTS.each { |type| ruportdata[type].replace_column("Total") { |r| "$%0.2f" % r["Total"] } }
  end

  def format_total
    '$' + ((self.total * 100).round.to_f / 100).to_s
  end
end
