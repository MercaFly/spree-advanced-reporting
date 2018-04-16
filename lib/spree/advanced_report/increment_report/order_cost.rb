class Spree::AdvancedReport::IncrementReport::OrderCost < Spree::AdvancedReport::IncrementReport
  def name
    "Cost"
  end

  def column
    "Cost"
  end

  def description
    "Total order profit is the sum of item quantity, times item price, minus item cost"
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
      cost = cost(order)
      INCREMENTS.each { |type| data[type][date[type]][:value] += cost }
      self.total += cost
    end

    generate_ruport_data

    INCREMENTS.each { |type| ruportdata[type].replace_column("OrderCost") { |r| "€%0.2f" % r["OrderCost"] } }
  end

  def format_total
    '€' + ((self.total*100).round.to_f / 100).to_s
  end
end
