Spree::Core::Engine.add_routes do
  namespace :admin do

    resources :reports, only: [] do
      collection do
        get :no_image
        get :no_description
        get :stock
        get :product_sales
        get :user_register
        get :revenue
        get :total
        get :cost
        get :count
        get :units
        get :profit
        get :top_customers
        get :top_products
        get :geo_revenue
        get :geo_units
        get :geo_profit
        get :daily_details
        get :order_details
        get :device_scale
      end
    end
  end
end
