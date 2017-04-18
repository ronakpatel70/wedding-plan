class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :sender, index: true, polymorphic: true, null: false
      t.references :recipient, index: true, polymorphic: true, null: false
      t.string :from, null: false
      t.string :to, null: false
      t.datetime :read_at
      t.string :subject
      t.text :body, null: false
      t.integer :type, null: false, default: 0
      t.string :template

      t.timestamps null: false
    end
  end
end
