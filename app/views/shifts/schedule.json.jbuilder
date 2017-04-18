json.array!(@users) do |user|
  json.extract! user.shifts.where(show: @current_show).order(:start_time).first, :id, :in_time, :out_time, :time_worked, :start_time, :end_time, :status
  json.user do
     json.extract! user, :id, :first_name, :last_name, :email, :phone
  end
end
