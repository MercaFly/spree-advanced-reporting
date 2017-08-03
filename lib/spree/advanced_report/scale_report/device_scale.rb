class Spree::AdvancedReport::ScaleReport::DeviceScale < Spree::AdvancedReport
  def name
    'Device scale'
  end

  def description
    'Device scale'
  end

  def initialize(params)
    super(params)

  end

  def report_data
    @orders = Spree::Order.where('completed_at IS NOT NULL').order('completed_at DESC').limit(100)

    data = [
      ['platform', 'count']
    ]

    channels = @orders.group_by(&:channel)

    channels.each_key {|k| puts k}

    channels.each_key do |k|
      data += [[k, channels[k].count]]
    end
    data
  end

end
