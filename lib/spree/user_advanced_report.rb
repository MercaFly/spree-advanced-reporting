module Spree
  class UserAdvancedReport
    include Ruport
    attr_accessor :users, :total, :date_text, :taxon_text, :ruportdata, :data, :params, :taxon, :product, :unfiltered_params

    def name
      "Base Advanced Report"
    end

    def description
      "Base Advanced Report"
    end

    def initialize(params)
      self.params = params
      self.total = 0

      params[:search] ||= {}


      if params[:search][:created_at_gt].blank?
          params[:search][:created_at_gt] = User.maximum(:created_at).end_of_day - 30.day
      else
        params[:search][:created_at_gt] = Time.zone.parse(params[:search][:created_at_gt]).beginning_of_day rescue ""
      end
      if params[:search][:created_at_lt].blank?
          params[:search][:created_at_lt] = User.maximum(:created_at).end_of_day
      else
        params[:search][:created_at_lt] = Time.zone.parse(params[:search][:created_at_lt]).end_of_day rescue ""
      end

      search = User.search(params[:search])
      self.users = search.result

    end

    def data
      self.users.order("DATE(created_at)").group("DATE(created_at)").count
    end

  end
end
