json.extract! @user, :id, :first_name, :last_name, :email, :phone, :event_role
json.address @user.address, :street, :city, :state, :zip
if @user.events.present?
    json.event @user.events.first, :id, :date, :joined_rewards_at
end
json.url user_url(@user, format: :json)
