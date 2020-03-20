# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :spaces do
  primary_key :id
  String :name
  String :address
  String :description, text: true
  Boolean :on_campus
  String :pros
  String :cons
  String :photo_name
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :space_id
  foreign_key :user_id
  Integer :rating
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end


# Insert initial (seed) data
spaces_table = DB.from(:spaces)

spaces_table.insert(name: "Deering Library", 
                    address: "1937 Sheridan Rd, Evanston, IL 60208",
                    description: "The Charles Deering Memorial Library was built in 1933 and was modeled after King's College Chapel in Cambridge, England. Deering Library served as the main library until 1970 and now houses several distinctive collections. The library was named for Charles H. Deering, a Northwestern benefactor and a patron to the arts.",
                    on_campus: true,
                    pros: "Quiet and good for deep, focused work. Great architecture and inspiring atmosphere.",
                    cons: "Lack of power outlets. Common tables only so not good for group work or meetings.",
                    photo_name: "deering.jpg")

spaces_table.insert(name: "Kellogg Spanish Steps", 
                    address: "2211 Campus Dr, Evanston, IL 60208",
                    description: "A pair of sweeping 34-foot-wide stairways reminiscent of Rome's renowned Spanish Steps anchor the Collaboration Plaza. The steps serve as a convening place for students and link the lower level, first floor, and second floor of Kellogg's new Global Hub.",
                    on_campus: true,
                    pros: "Plenty of space and good for quick group meetings. You're likely to run into your classmates as they transition between classes.",
                    cons: "No power outlets. Not great for focused work as there are many people who use the steps to socialize.",
                    photo_name: "steps.jpg")

spaces_table.insert(name: "Norris University Center", 
                    address: "1999 Campus Dr, Evanston, IL 60208",
                    description: "It's the student union. A great place to find a secluded study area, common group table and plenty of dining options to grab a quick bite",
                    on_campus: true,
                    pros: "So many different options: quiet study, group study, and many food options.",
                    cons: "Can get busy, especially around finals time. Be prepared to have to walk around for a while before you find that perfect spot!",
                    photo_name: "norris.jpg")

spaces_table.insert(name: "Starbucks on Sherman Avenue", 
                    address: "1734 Sherman Ave, Evanston, IL 60201",
                    description: "Starbucks. It speaks for itself. The Seattle-based coffee chain gone corporate. Good coffee, okay music. A decent all around spot.",
                    on_campus: true,
                    pros: "Caffeine!",
                    cons: "Your clothes smell like espresso afterwards.",
                    photo_name: "starbucks.jpg")

puts "Success!"