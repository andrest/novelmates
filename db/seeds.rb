puts 'hello'
u1 = User.create(firstname: "Janek", lastname: "Kukk", email:"janek@janek.com", password: "janek", active: "true")
u2 = User.create(firstname: "Julia", lastname: "Tuul", email:"julia@julia.com", password: "julia", active: "true")
u3 = User.create(firstname: "Andres", lastname: "Tuul", email:"andres@andres.com", password: "andres", active: "true")
u4 = User.create(firstname: "Yoni", lastname: "Regev", email:"yoni@yoni.com", password: "yoni", active: "true")

i1 = Interest.create(isbn: "0762448652", category: "How to apply")
i2 = Interest.create(isbn: "0762448652", category: "Author discussion")
i3 = Interest.create(isbn: "0762448652", category: "Social implications")

m1 = Meetup.create(name: "Lets talk business", city: '2643743', creator: u1._id, books: [ '0762448652' ] )
m2 = Meetup.create(name: "Going fishing", city: '2643743', creator: u2._id, books: [ '0762448652' ] )
m3 = Meetup.create(name: "Should be a movie", city: '2643743', creator: u3._id, books: [ '0762448652' ] )
m4 = Meetup.create(name: "Changed my life", city: '2643743', creator: u3._id, books: [ '0762448652' ] )
m5 = Meetup.create(name: "What a letdown", city: '2643743', creator: u3._id, books: [ '0762448652' ] )
m6 = Meetup.create(name: "Best book, ever.", city: '2643743', creator: u4._id, books: [ '0762448652' ] )

m7 = Meetup.create(name: "Changed my life", city: '2640729', creator: u2._id, books: [ '0762448652' ] )
m8 = Meetup.create(name: "What a letdown", city: '2640729', creator: u1._id, books: [ '0762448652' ] )
m9 = Meetup.create(name: "Best book, ever.", city: '2640729', creator: u4._id, books: [ '0762448652' ] )


u1.interests = [i1, i2]
u2.interests = [i1, i2]
u3.interests = [i2, i3]
u4.interests = [i3, i2, i1]

p "seeded"
# u2.interests = Interest.new(category: "Author discussion", users: [u1._id, u2._id] )