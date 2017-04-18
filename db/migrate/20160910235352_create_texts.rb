class CreateTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :texts do |t|
      t.references :sender, index: true, polymorphic: true, null: true
      t.references :recipient, index: true, polymorphic: true, null: true
      t.text :message, null: false
      t.integer :group, null: true, default: nil
      t.integer :status, null: false, default: 0
      t.text :sender_tel
      t.text :recipient_tel

      t.timestamps
    end
  end
end
