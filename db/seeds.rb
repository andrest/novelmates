puts 'Dropping'
Mongoid.purge!

# =================================== DATA =================================== 
puts 'Initalise data'

cities = ['2643743', '2643123'] # , '2640729', '2653941']
isbns = ["0762448652","0553804685","0553804677","0679735771","0745660789","030746363X","0751532711","0195374614","0140291873","0374275637","0307593312","0553380958","0061977969","0743273567","0307588688","0316037702","0060892994","0140132716","075640407X","0553803719","0553565699","0006480101","055358202X","055357342X","0375826696","0345538374","0006480098","0575088877","0140449264","031286504X","0345368584","0192833987","0393058638","080305971X","042507160X","076532119X","0465030785","0434020230","0684824299","0805390456","0393316041","0672325861","0201310058","0553588486","0545010225","0345391802","0439785960","0679783261","0439554934","0140283331","0618346252","0143037889","0199291152","0671027387","0552151696","0307277674","0671657135","0465026567","0201485419","0321566157","0060186399","0262032937","0596006624","0060920432","0671027034","0061122416","0142001783","0618346260","0393312836","0618260307","0156012197"]
isbns = isbns[0..11]
interests = {}
users = []
venues = []
meetups = []
# =================================== MANUAL =================================== 

puts 'Manual Seeding'

u1 = User.create(firstname: "Janek", lastname: "Kukk", email:"janek@janek.com", password: "janek", active: "true")
u2 = User.create(firstname: "Julia", lastname: "Tuul", email:"julia@julia.com", password: "julia", active: "true")
u3 = User.create(firstname: "Andres", lastname: "Tuul", email:"punkar@gmail.com", password: "andres", weekly_digest: "true", active: "true")
u4 = User.create(firstname: "Yoni", lastname: "Regev", email:"yoni@yoni.com", password: "yoni", active: "true")

i1 = Interest.create(isbn: "0762448652", category: "Dissecting the storyline")
i2 = Interest.create(isbn: "0762448652", category: "Author discussion")
i3 = Interest.create(isbn: "0762448652", category: "Social implications")

u1.interests = [i1, i2]
u2.interests = [i1, i2]
u3.interests = [i2, i3]
u4.interests = [i3, i2, i1]

m1 = Meetup.create(name: "Lets talk business", city: '2643743', creator: u1._id, books: '0762448652')
m2 = Meetup.create(name: "Going fishing", city: '2643743', creator: u2._id, books: '0762448652')
m3 = Meetup.create(name: "Should be a movie", city: '2643743', creator: u3._id, books: '0762448652')
m4 = Meetup.create(name: "Changed my life", city: '2643743', creator: u3._id, books: '0762448652')
m5 = Meetup.create(name: "What a letdown", city: '2643743', creator: u3._id, books: '0762448652')
m6 = Meetup.create(name: "Best book, ever.", city: '2643743', creator: u4._id, books: '0762448652')

m7 = Meetup.create(name: "Changed my life", city: '2640729', creator: u2._id, books: '0762448652')
m8 = Meetup.create(name: "What a letdown", city: '2640729', creator: u1._id, books: '0762448652')
m9 = Meetup.create(name: "Best book, ever.", city: '2640729', creator: u4._id, books: '0762448652')

v1 = Venue.new(name: "Monmouth Coffee", address: 'Monmouth Coffee, Covent Garden, London', notes: 'Reservation for "Mary"')
v2 = Venue.new(name: "Flat White", address: 'Flat White, SoHo, London', notes: 'Reservation for "Mary"')
v3 = Venue.new(name: "Andrew Edmunds", address: 'Lexington St, SoHo, London', notes: 'Reservation for "Mary"')

m1.venue = v1
m2.venue = v2
m3.venue = v3

interests = {"0762448652" => [i1, i2, i3]}
users = [u1, u2, u3, u4]
venues = [v1, v2, v3]
meetups = [m1, m2, m3]

puts 'Automatic Seeding'

# =================================== INTERESTS =================================== 
puts '  Generate Interests'

isbns.each do |isbn|
  interests_for_isbn = []
  (1..6).each do |i|
    interests_for_isbn.push Interest.create(
      isbn: isbn,
      category: Faker::Company.catch_phrase
      )
  end
  interests[isbn] = interests_for_isbn
end
# =================================== USERS =================================== 
puts '  Generate Users'

(1..40).each do |i|
  users.push User.create(
    firstname: Faker::Name.first_name,
    lastname: Faker::Name.last_name,
    email: Faker::Internet.email,
    password: "password",
    active: "true",
    location: Faker::Address.city+', '+Faker::Address.country,
    weekly_digest: "false"
    )
end

# =================================== VENUES =================================== 
puts '  Generate Venues'

(1..2).each do |i|
  venues.push Venue.new(
            name: Faker::Company.name, 
            address: 'Monmouth Coffee, Covent Garden, London', 
            notes: 'Reservation for "Mary"')
end

# =================================== MEETUPS =================================== 
puts '  Generate Meetups'

(1..25).each do |i|
  u = users.sample._id
  meetups.push Meetup.create(
                name: Faker::Lorem.sentence(3), 
                city: cities.sample, 
                creator: u,
                user_ids: [u], 
                books: isbns.sample,
                venue: venues.sample,
                date: Time.now+((rand(21)+1)*24*60*60) )
  # u.meetup_ids << meetups.last._id
end

# =================================== OTHER =================================== 
puts '  Link models up'

# puts '    Users-Interests'
# users.each do |u|
#   interest_bunch = interests.sample(rand(6)+1)
#   interest_ids = interest_bunch.map { |i| i._id }
#   u.interest_ids = interest_ids
#   interest_bunch.each { |i| i.user_ids = i.user_ids << u._id; }
# end

puts '    Meetups-Users'

meetups.each do |m|
  user_bunch = users.sample(rand(8)+1)
  user_ids = user_bunch.map { |u| u._id }
  # ap user_ids
  m.user_ids = user_ids
  m.save
  user_bunch.each do |u| 
    u.meetup_ids = u.meetup_ids << m._id

    interest_bunch = interests[m.books].sample(rand(3)+1)
    interest_ids = interest_bunch.map { |i| i._id }
    u.interest_ids = interest_ids
    interest_bunch.each { |i| i.user_ids = i.user_ids << u._id; i.save; }
    u.save
  end

  # next if rand(100) > 50
  # m.venue = Venue.new(name: "Monmouth Coffee", address: 'Monmouth Coffee, Covent Garden, London', notes: 'Reservation for "Mary"')
end

puts 'Seeded! :)'
# u2.interests = Interest.new(category: "Author discussion", users: [u1._id, u2._id] )