

Spree::Admin::ReportsController.class_eval do
  before_filter :add_actions_to_available_reports
  before_filter :basic_report_setup, actions: :actions

  def basic_report_setup
    @products = Spree::Product.all
    @taxons = Spree::Taxon.all
    if defined?(MultiDomainExtension)
      @stores = Store.all
    end
  end

  def stock
    @line = nil
    @active = false
    @report = Spree::StockReport.new(params)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/stock_report' }
      format.csv { render text: @report.to_csv }
    end
  end

  def user_register
    @report = Spree::UserAdvancedReport.new(params)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/user_base' }
      format.csv { render text: @report.to_csv }
    end
  end

  def product_sales
    @report = Spree::ProductSalesReport.new
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/product_sales_report' }
      format.csv { render text: @report.to_csv }
    end
  end

  def no_image
    @report = Spree::ProductReport::NoImage.new(params)
    product_report_render('no_image')
  end

  def no_description
    @report = Spree::ProductReport::NoDescription.new(params)
    product_report_render('no_description')
  end

  def revenue
    @report = Spree::AdvancedReport::IncrementReport::Revenue.new(params)
    base_report_render('revenue')
  end

  def total
    @report = Spree::AdvancedReport::IncrementReport::Total.new(params)
    base_report_render('total')
  end

  def cost
    @report = ::Spree::AdvancedReport::IncrementReport::OrderCost.new(params)
    base_report_render('cost')
  end

  def units
    @report = Spree::AdvancedReport::IncrementReport::Units.new(params)
    base_report_render('units')
  end

  def daily_details
    @report = Spree::AdvancedReport::DailyDetailsReport.new(params)
    render template: 'spree/admin/reports/daily_details'
  end

  def profit
    @report = Spree::AdvancedReport::IncrementReport::Profit.new(params)
    base_report_render('profit')
  end

  def count
    @report = Spree::AdvancedReport::IncrementReport::Count.new(params)
    base_report_render('count')
  end

  def top_products
    @report = Spree::AdvancedReport::TopReport::TopProducts.new(params, 100)
    base_report_top_render('top_products')
  end

  def top_customers
    @report = Spree::AdvancedReport::TopReport::TopCustomers.new(params, 20)
    base_report_top_render('top_customers')
  end

  def geo_revenue
    @report = Spree::AdvancedReport::GeoReport::GeoRevenue.new(params)
    geo_report_render('geo_revenue')
  end

  def geo_units
    @report = Spree::AdvancedReport::GeoReport::GeoUnits.new(params)
    geo_report_render('geo_units')
  end

  def geo_profit
    @report = Spree::AdvancedReport::GeoReport::GeoProfit.new(params)
    geo_report_render('geo_profit')
  end

  def order_details
    @line = nil
    @active = false
    @report = Spree::OrderDetailReport.new(params)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/order_details' }
      format.csv { render text: @report.to_csv }
    end
  end

  def device_scale
    @report = Spree::AdvancedReport::ScaleReport::DeviceScale.new(params)
    scale_report_render('device')
  end

  private

  def actions
    [
      :stock,
      :no_image,
      :no_description,
      :daily_details,
      :product_sales,
      :user_register,
      :profit,
      :revenue,
      :total,
      :cost,
      :units,
      :top_products,
      :top_customers,
      :geo_revenue,
      :geo_units,
      :count,
      :order_details,
      :device_scale
    ]
  end

  def add_actions_to_available_reports
    return if Spree::Admin::ReportsController::available_reports.has_key?(:geo_profit)
    advanced_reports = {}
    actions.each do |action|
      advanced_reports[action] = {
        name: I18n.t('adv_report.' + action.to_s),
        description: I18n.t('adv_report.' + action.to_s)
      }
    end

    Spree::Admin::ReportsController::available_reports.merge!(advanced_reports)
    I18n.locale = Rails.application.config.i18n.default_locale
    I18n.reload!
  end

  def scale_report_render(filename)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/scale_base' }
    end

  end

  def product_report_render(filename)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/product_base' }
      format.csv do
        send_data @report.to_csv
      end
    end
  end

  def geo_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]['report_type'] = params[:advanced_reporting]['report_type'].to_sym if params[:advanced_reporting]['report_type']
    params[:advanced_reporting]['report_type'] ||= :state
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/geo_base' }
      format.csv do
        send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv
      end
    end
  end

  def base_report_top_render(filename)
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/top_base' }
      format.csv do
        send_data @report.ruportdata.to_csv
      end
    end
  end

  def base_report_render(filename)
    params[:advanced_reporting] ||= {}
    params[:advanced_reporting]['report_type'] = params[:advanced_reporting]['report_type'].to_sym if params[:advanced_reporting]['report_type']
    params[:advanced_reporting]['report_type'] ||= :daily
    respond_to do |format|
      format.html { render template: 'spree/admin/reports/increment_base' }
      format.csv do
        if params[:advanced_reporting]['report_type'] == :all
          send_data @report.all_data.to_csv
        else
          send_data @report.ruportdata[params[:advanced_reporting]['report_type']].to_csv
        end
      end
    end
  end

  def report_params
    # TODO: Strong Params
    params
  end
end
