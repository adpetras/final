# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
require "geocoder"                                                                    #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

spaces_table = DB.from(:spaces)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts "params: #{params}"
    
    pp spaces_table.all.to_a
    @spaces = spaces_table.all.to_a
    @title = "Home | StudySpaces"
    view "spaces"
end

get "/spaces/:id" do
    puts "params: #{params}"
    
    #pp spaces_table.where(id: params["id"]).to_a[0]
    @spaces = spaces_table.all.to_a
    @space = spaces_table.where(id: params["id"]).to_a[0]
    @reviews = reviews_table.where(space_id: @space[:id]).to_a
    @review_count = reviews_table.where(space_id: @space[:id]).count
    @users_table = users_table
    
    if @review_count > 0
        @avg_rating = (reviews_table.sum(:rating).to_f / @review_count.to_f).round(1)
    else
        @avg_rating = "not yet reviewed"
    end

    location = @space[:address]
    results = Geocoder.search(location)
    lat_lng = results.first.coordinates
    @lat = lat_lng[0]
    @lng = lat_lng[1]
    # create a way to do average review rating

    @google_api_key = ENV["GOOGLE_MAPS_KEY"]

    view "space"
end

get "/spaces/:id/reviews/new" do
    puts "params #{params}"
    
    @space = spaces_table.where(id: params["id"]).to_a[0]
    view "new_review"
end

post "/spaces/:id/reviews/create" do
    puts "params #{params}"

    # find space we are leaving review for
    @space = spaces_table.where(id: params["id"]).to_a[0]

    if @current_user
        # insert data in the reviews data table
        reviews_table.insert(
            space_id: @space[:id],
            user_id: session["user_id"],
            rating: params["rating"],
            comments: params["comments"]
        )
        view "create_review"
    else
        view "error"
    end
end

get "/reviews/:id/edit" do
    puts "params #{params}"

    @review = reviews_table.where(id: params["id"]).to_a[0]
    @space = spaces_table.where(id: @review[:space_id]).to_a[0]
    if @current_user && @current_user[:id] == @review[:user_id]
        view "edit_review"
    else
        view "error"
    end
end

post "/reviews/:id/update" do
    puts "params #{params}"

    @review = reviews_table.where(id: params["id"]).to_a[0]
    @space = spaces_table.where(id: @review[:space_id]).to_a[0]
    
    if @current_user && @current_user[:id] == @review[:user_id]
        # update data in the reviews data table
        reviews_table.where(id: params["id"]).update(
            rating: params["rating"],
            comments: params["comments"]
        )
        view "update_review"
    else
        view "error"
    end
end

get "/reviews/:id/destroy" do
    puts "params #{params}"

    review = reviews_table.where(id: params["id"]).to_a[0]
    @space = spaces_table.where(id: review[:space_id]).to_a[0]

    reviews_table.where(id: params["id"]).delete

    view "destroy_review"
end

get "/users/new" do
    puts "params #{params}"

    view "new_user"
end

post "/users/create" do
    puts "params #{params}"
    
    # insert data in the users data table only if not already signed up
    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            name: params["name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
        )
        view "create_user"
    end
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params #{params}"

    @user = users_table.where(email: params["email"]).to_a[0]
    
    if @user && BCrypt::Password.new(@user[:password]) == params["password"]
        session["user_id"] = @user[:id] 
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    view "logout"
end
