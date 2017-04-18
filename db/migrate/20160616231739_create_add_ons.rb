class CreateAddOns < ActiveRecord::Migration[5.0]
  def change
    old_counts = [Booth.where("amenities @> ?", "{bag}").count,
      Booth.with_balance.count, Booth.where("amenities @> ?", "{sign}").count]

    create_table :add_ons do |t|
      t.references :booth, index: true, foreign_key: true, null: false
      t.text :type, null: false, index: true
      t.integer :quantity, null: false, default: 1
      t.text :value, index: true
      t.text :description
      t.integer :price, null: false, default: 0

      t.timestamps
    end

    # Convert section_requested to AddOn
    Booth.where.not(section_requested: nil).each do |b|
      b.add_ons.create!(type: 'section', value: b.section_requested)
    end
    remove_column :booths, :section_requested

    # Convert amenities to AddOns
    Booth.where.not(amenities: nil).each do |b|
      b.amenities.each do |a|
        case a
          when 'alcohol' then t, v = 'beverage', 'wine'
          when 'table' then t, v = 'tables', 1
          when 'tables' then t, v = 'tables', 2
          when 'tall' then t, v = 'height', nil
          when 'bag' then t, v = 'bag_promo', nil
          else t, v = a, 1
        end
        b.add_ons.create!(type: t, value: v)
      end
      puts "Booth(#{b.id}): #{b.add_ons.pluck(:type)}"
    end
    remove_column :booths, :amenities

    ['with_bag', 'with_balance', 'with_sign'].each_with_index do |x, i|
      old, new = old_counts[i], Booth.send(x).count
      fail "#{x.humanize} is wrong: got #{new} want #{old}" unless old == new
    end
  end
end
