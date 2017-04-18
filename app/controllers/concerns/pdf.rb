module Pdf
  extend ActiveSupport::Concern

  private
    def mailing_labels_pdf(booths, customers)
  		Prawn::Document.new(page_layout: :landscape, left_margin: 24, right_margin: 48, top_margin: 16, bottom_margin: 18) do |pdf|
  			pdf.define_grid(:columns => 5, :rows => 8, :gutter => 0)
  			pdf.default_leading 3
  			page_count = (customers.count / 40.0).ceil
        booths.each do |booth|
          pdf.text booth.vendor.to_s, :align => :center, :valign => :center, :size => 60
          pdf.move_down 60
          pdf.text "Section #{booth.coordinate&.section}", :align => :center, :valign => :center, :size => 30
    			index = 0
    			page_count.times do |page|
      			pdf.start_new_page
      			pdf.draw_text "#{page+1}/#{page_count}", :at => [730, 0]
    				(0..7).each do |row|
    					(0..4).each do |col|
    						pdf.grid(row, col).bounding_box do
    							pdf.move_down 14
    							if customers[index]
    								pdf.text customers[index].to_s, :align => :center, :size => 10
    								pdf.text customers[index].address&.street&.truncate(27), :align => :center, :size => 10
    								pdf.text customers[index].address&.city_state_zip.truncate(27), :align => :center, :size => 10
    							end
    							index += 1
    						end
    					end
    				end
  				end
  			end
  		end
  	end

  	def paper_signs_pdf(booths)
    	Prawn::Document.new(:page_layout => :landscape) do |pdf|
        booths.each_with_index do |booth, index|
          pdf.start_new_page(:layout => :landscape) if index != 0
          pdf.text booth.vendor.to_s, :align => :center, :valign => :center, :size => 96
        end
        string = "<page> of <total>"
        pdf.number_pages string, :at => [pdf.bounds.right - 150, 0], :width => 150,
          :align => :right, :start_count_at => 1, :color => "777777"
      end
  	end

  	def prize_labels_pdf(user, event, eligible, highlighted)
  		Prawn::Document.new(page_layout: :landscape, left_margin: 24, right_margin: 48, top_margin: 16, bottom_margin: 18) do |pdf|
  			pdf.define_grid(:columns => 5, :rows => 8, :gutter => 0)
  			pdf.default_leading 3
  			3.times do |page|
  				(0..7).each do |row|
  					(0..4).each do |col|
  						pdf.grid(row, col).bounding_box do
  							if page == 0 and (row == 0 and col == 0) and eligible
  								pdf.svg `cat app/assets/images/pdf/cake-dots.svg`, :at => [24, 55], :width => 36, :height => 36
  								pdf.bounding_box([62, 72], width: 72, height: 71) do
  									pdf.text "Cake Pull ##{user.id}", :valign => :center, :align => :center
  								end
  							elsif page == 0 && row * 5 + col <= highlighted
  								pdf.svg `cat app/assets/images/pdf/balloons.svg`, :at => [24, 55], :width => 36, :height => 36
  								pdf.bounding_box([62, 71], width: 72, height: 71) do
  									pdf.text "#{user.to_s[0,22]} ##{user.id}", :valign => :center, :align => :center
  								end
  							else
  								pdf.move_down 14
  								pdf.text user.to_s[0,22], :align => :center
  								pdf.text view_context.number_to_phone(user.phone, area_code: true), :align => :center
  								if event then pdf.text event.date.to_s, :align => :center end
  							end
  						end
  					end
  				end
  				pdf.start_new_page if page < 2
  			end
  		end
  	end
end
