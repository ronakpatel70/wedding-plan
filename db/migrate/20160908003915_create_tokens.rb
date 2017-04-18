class CreateTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :tokens, id: false do |t|
      t.text :id, primary_key: true
      t.references :user, foreign_key: true, null: false
      t.datetime :expires_at, null: false
    end
  end
end
