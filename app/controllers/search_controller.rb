class SearchController < BaseController
  FILTERS = %w(users vendors prizes signs positions)

  def index
    @query = params[:query]
    @filter = params[:filter]
    @counts = {}
    limit = params[:limit] ? params[:limit].to_i : nil

    if FILTERS.include?(@filter)
      @results = self.send(@filter, @query, limit, request.query_parameters)
        .map { |o| hash_for(o, @filter) }
      if request.format.html?
        @counts = FILTERS.map { |f| [f, self.send(f, @query, nil).count] }.to_h
      end
    else
      @results = FILTERS.inject([]) do |sum, g|
        objs = self.send(g, @query, limit).map { |o| hash_for(o, g) }
        @counts[g] = objs.count
        limit -= objs.length if limit
        sum.push(*objs)
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @results.to_json }
    end
  end

  private
    def users(q, limit, filters = {})
      users = User.where("first_name ILIKE :q OR last_name ILIKE :q
        OR CONCAT(first_name, ' ', last_name) ILIKE :q
        OR CONCAT(last_name, ' ', first_name) ILIKE :q OR email = :e
        OR phone ILIKE :q", q: "#{q}%", e: q).order(:first_name, :last_name).limit(limit)
      users = users.joins(:roles).where(roles: {type: Role.types[filters[:role]]}) if filters[:role]
      users
    end

    def vendors(q, limit, filters = {})
      Vendor.joins("LEFT OUTER JOIN users_vendors uv ON uv.vendor_id = vendors.id LEFT OUTER JOIN users ON users.id = uv.user_id").where("first_name ILIKE :q OR last_name ILIKE :q
        OR name ILIKE :q OR users.email = :e OR users.phone ILIKE :q
        OR CONCAT(users.first_name, ' ', users.last_name) ILIKE :q
        OR CONCAT(users.last_name, ' ', users.first_name) ILIKE :q
        OR vendors.email = :e OR vendors.phone ILIKE :q OR contact ILIKE :q",
        q: "%#{q}%", e: q).distinct.limit(limit).order(:name)
    end

    def prizes(q, limit, filters = {})
      prizes = Prize.where("name ILIKE ?", "%#{q}%").limit(limit).order(:name)
      prizes = prizes.where(show: filters[:show]) if filters[:show]
      prizes = prizes.where(status: filters[:status]) if filters[:status]
      prizes = prizes.where(type: filters[:type]) if filters[:type]
      prizes
    end

    def signs(q, limit, filters = {})
      Sign.where("front ILIKE :q OR back ILIKE :q", q: "%#{q}%").limit(limit).order(:id)
    end

    def positions(q, limit, filters = {})
      Position.where("name ILIKE ?", "%#{q}%").limit(limit).order(:name)
    end

    def hash_for(obj, group)
      { url: url_for(obj), id: obj.id, type: group.to_s.singularize,
        name: obj.to_s, modified: obj.updated_at,
        description: obj.try(:short_description) || obj.try(:email) || obj.try(:text) || obj.try(:vendor) }
    end
end
