class Spree::AdvancedReport::GeoReport::GeoRevenue < Spree::AdvancedReport::GeoReport
  def name
    "Revenue by Geography"
  end

  def column
    "Revenue"
  end

  def description
    "Revenue divided geographically, into states and countries"
  end

  def initialize(params)
    super(params)

    data = { :state => {}, :country => {} }
    orders.each do |order|
      revenue = revenue(order)
      if order.ship_address && order.ship_address.state

        data[:state][order.ship_address.state_id] ||= {
          :name => order.ship_address.state.name,
          :abbr => order.ship_address.state.abbr,
          :revenue => 0
        }
        data[:state][order.ship_address.state_id][:revenue] += revenue
      end
      if order.ship_address && order.ship_address.country
        data[:country][order.ship_address.country_id] ||= {
          :name => order.ship_address.country.name,
          :abbr => order.ship_address.state.abbr,
          :revenue => 0
        }
        data[:country][order.ship_address.country_id][:revenue] += revenue
      end
    end
    [:state, :country].each do |type|
      ruportdata[type] = Table(%w[location abbr Revenue])
      data[type].each { |k, v| ruportdata[type] << { "location" => v[:name], 'abbr' => v[:abbr], "Revenue" => v[:revenue] } }
      ruportdata[type].sort_rows_by!(["Revenue"], :order => :descending)
      ruportdata[type].rename_column("location", type.to_s.capitalize)
      ruportdata[type].replace_column("Revenue") { |r| "$%0.2f" % r.Revenue }
    end
  end
end
