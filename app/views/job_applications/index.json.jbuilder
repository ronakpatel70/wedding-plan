json.array!(@job_apps) do |job_application|
  json.extract! job_application, :id, :status, :requests, :requested_start, :requested_end
  json.total_time_worked job_application.user.shifts.map { |shift| shift.time_worked || 0 }.sum
  json.user do
    json.extract! job_application.user, :id, :first_name, :last_name, :email, :phone
  end
  json.shifts Shift.where(user: job_application.user, show: @current_show) do |shift|
    json.extract! shift, :id, :start_time, :end_time, :in_time, :out_time, :time_worked
  end
#   json.url job_application_url(job_application, format: :json)
end
