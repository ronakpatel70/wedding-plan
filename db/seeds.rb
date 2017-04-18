# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

sr = Location.create(name: 'Santa Rosa', handle: 'santa-rosa', address: Address.new(name: 'Wells Fargo Center for the Arts', street: '50 Mark West Springs Road', city: 'Santa Rosa', state: 'CA', zip: '95403'))
Show.create(start: '2015-01-17 12:00', end: '2015-01-17 17:00', location: sr)
Show.create(start: '2015-09-20 12:00', end: '2015-09-20 17:00', location: sr)
Show.create(start: '2016-01-16 12:00', end: '2016-01-16 17:00', location: sr)
Show.create(start: '2016-09-18 12:00', end: '2016-09-18 17:00', location: sr)

windsor = Address.create(name: 'Dylan Waits', street: '590 Shagbark St', city: 'Windsor', state: 'CA', zip: '95492')
dylan = User.create(email: 'dylan@waits.io', first_name: 'Dylan', last_name: 'Waits', phone: '7075272685', password: 'password', address: windsor, receive_email: true, receive_sms: true, roles: [Role.new(type: 0), Role.new(type: 1)])
adrian = User.create(email: 'acousens.wcb@gmail.com', first_name: 'Adrian', last_name: 'Cousens', phone: '7075555555', password: 'password', address: nil, receive_email: true, receive_sms: true, roles: [Role.new(type: 0), Role.new(type: 1)])
User.create([{email: 'megan@waits.io', first_name: 'Megan', last_name: 'Waits', phone: '7078360339', roles: [Role.new(type: 1)]},
  {email: 'brennan@example.com', first_name: 'Brennan', last_name: 'Westerson', roles: [Role.new(type: 1)]},
  {email: 'isaac@example.com', first_name: 'Isaac', last_name: 'Scneider', roles: [Role.new(type: 1)]},
  {email: 'emiko@example.com', first_name: 'Emiko', last_name: 'Ogasawara', roles: [Role.new(type: 1)]}])

event = Event.create(date: '2017-01-01', joined_rewards_at: '2015-10-28')
event.users << dylan
event.users << adrian

token = Stripe::Token.create :card => { :name => "Test Card", :number => "4242424242424242", :exp_month => 10, :exp_year => 2016, :cvc => "314" }
Card.create_with_token token, dylan
Ticket.create(user: dylan, show_id: 3, quantity: 3)
Ticket.create(user: dylan, show_id: 3, free: true)

Vendor.create(name: 'Test', email: 'test@example.com', phone: '707.544.3695', contact: 'Adrian', industry: 'specialty', users: [adrian])
Vendor.create(name: 'Wine Country Bride', email: 'wcb@example.com', phone: '707.544.3695', contact: 'Cirkl', industry: 'apparel', users: [dylan])
Vendor.create(name: 'Premier Productions', email: 'premier@example.com', phone: '707.555.5555', contact: 'Jay', industry: 'dj', users: [adrian])
s = Sign.create(front: 'Wine Country Bride', back: 'Premier Productions', vendor_ids: [2, 3])
Sign.create(front: 'Premier Productions', vendor_ids: [3])
Sign.create(front: 'Test Sign', vendor_ids: [1])
Booth.create(show_id: 2, vendor_id: 2, status: 'approved', section_requested: '7', size: '6x6', amenities: ['table', 'linen', 'sign'], payment_method: 'cash')
Booth.create(show_id: 3, vendor_id: 3, status: 'approved', section_requested: '3', size: '6x8', amenities: ['sign', 'power'], payment_method: 'cash')
Booth.create(show_id: 3, vendor_id: 2, status: 'approved', section_requested: '7', size: '6x6', amenities: ['table', 'linen', 'sign'], payment_method: 'cash')

Prize.create(show_id: 3, vendor_id: 2, name: 'Test Prize', quantity: 25, value: 15000, rules: 'A bunch of rules.', type: 'discount', status: 'approved')
Prize.create(show_id: 3, vendor_id: 2, name: 'Gift Card', quantity: 10, value: 1000, rules: 'A bunch of rules.', type: 'standalone', status: 'approved')
Prize.create(show_id: 3, vendor_id: 2, name: 'Free Wedding', quantity: 1, value: 1000000, rules: 'A bunch of rules.', type: 'grand', status: 'approved')
Prize.create(show_id: 3, vendor_id: 2, name: 'Expensive Face Paint', quantity: 1, value: 1000, rules: 'A bunch of rules.', type: 'grand', status: 'approved')
Prize.create(show_id: 3, vendor_id: 2, name: 'Free Cake', quantity: 1, value: 50000, rules: 'A bunch of rules.', type: 'highlighted', status: 'approved')
Package.create(show_id: 3, type: 'grand', name: '$20,000 Free Wedding Giveaway', prize_ids: [3])
Package.create(show_id: 3, type: 'grand', name: '$15,000 Makeover Package', prize_ids: [4])

Booking.create(vendor_id: 2, event: event)
Booking.create(vendor_id: 2, event: nil, date: '2016-03-03')
Booking.create(vendor_id: 3, event: nil, date: '2016-03-04')

Position.create([{name: 'Cashier', short_description: 'Take money', quantity: 4, default_start: '10:30', default_end: '16:30'},
  {name: 'Data Entry', short_description: 'Help people register', quantity: 4, default_start: '10:30', default_end: '16:30'},
  {name: 'Line Host', short_description: '...', quantity: 2, default_start: '10:30', default_end: '16:30'},
  {name: 'Cake Pull', short_description: '...', quantity: 3, default_start: '10:30', default_end: '16:30'},
  {name: 'Vendor Check In', short_description: '...', quantity: 6, default_start: '7:30', default_end: '10:30'},
  {name: 'Breaker', short_description: '...', quantity: 2, default_start: '13:30', default_end: '16:30'},
  {name: 'Cleanup', short_description: '...', quantity: 10, default_start: '16:30', default_end: '19:30'},
  {name: 'CTO', short_description: 'Fix stuff', quantity: 1, default_start: '7:30', default_end: '17:30'}])
