json.array!(@texts) do |text|
  json.extract! text, :id, :message, :status, :sender_tel, :recipient_tel, :created_at
  json.sender(text.sender, :id, :name, :cell_phone) if text.sender
  json.recipient(text.recipient, :id, :name, :cell_phone) if text.recipient
end
