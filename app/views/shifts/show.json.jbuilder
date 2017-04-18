json.extract! @shift, :id, :user_id, :show_id, :start_time, :end_time, :in_time, :out_time, :time_worked, :created_at, :updated_at
json.url shift_url(@shift, format: :json)
