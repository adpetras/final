# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

spaces_table = DB.from(:spaces)
comments_table = DB.from(:comments)

get "/" do
    puts "params: #{params}"
    
    pp spaces_table.all.to_a
    @spaces = spaces_table.all.to_a
    @title = "Home | StudySpaces"
    view "spaces"
end

get "/spaces/:id" do
    puts "params: #{params}"

    pp spaces_table.where(id: params["id"]).to_a[0]
    @space = spaces_table.where(id: params["id"]).to_a[0]
    @comments = comments_table.where(space_id: @space[:id]).to_a
    view "space"
end

get "/spaces/:id/comments/new" do
    puts "params #{params}"
    
    @space = spaces_table.where(id: params["id"]).to_a[0]
    view "new_comment"
end

get "/spaces/:id/comments/create" do
    puts "params #{params}"

    # find space we are leaving comment for
    @space = spaces_table.where(id: params["id"]).to_a[0]

    # insert data in the comments data table
    comments_table.insert(
        space_id: @space[:id],
        name: params["name"],
        email: params["email"],
        rating: params["rating"],
        comments: params["comments"]
    )

    view "create_comment"
end