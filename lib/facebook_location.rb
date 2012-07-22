# EXAMPLE CHECKIN OBJECT
# {
#    "id"   =>"10150656420956658",
#    "from"   =>   {
#       "name"      =>"Peter Hamilton",
#       "id"      =>"693566657"
#    },
#    "place"   =>   {
#       "id"      =>"36132613726",
#       "name"      =>"Royal Albert Hall",
#       "location"      =>      {
#          "street"         =>"Kensington Gore",
#          "city"         =>"London",
#          "country"         =>"United Kingdom",
#          "zip"         =>"SW7 2AP",
#          "latitude"         =>51.50104825405,
#          "longitude"         =>-0.17741884149293
#       }
#    },
#    "application"   =>   {
#       "name"      =>"Facebook for Android",
#       "namespace"      =>"fbandroid",
#       "id"      =>"350685531728"
#    },
#    "created_time"   =>"2012-04-09T19:31:34+0000   ", "   likes"=>   {
#       "data"      =>      [
#          {
#             "id"            =>"1162977671",
#             "name"            =>"April Riglar"
#          }
#       ],
#       "paging"      =>      {
#          "next"         =>"https://graph.facebook.com/10150656420956658/likes?access_token=AAADWlnbZBZCHUBACJGrkSbkjM28BiesVSOujYOGFlvWL5QVjj2zZCeZBsc5oJgWMOMfBsp3jnV9a2kFjPK4lUXLlAZC4DctTBTrXBKlteSwZDZD&limit=25&offset=25&__after_id=1162977671"
#       }
#    },
#    "tags"   =>   {
#       "data"      =>      [
#          {
#             "id"            =>"1299124808",
#             "name"            =>"Ben Hamilton"
#          },
#          {
#             "id"            =>"1428321232",
#             "name"            =>"Annie Hamilton"
#          }
#       ],
#       "paging"      =>      {
#          "next"         =>"https://graph.facebook.com/10150656420956658/tags?access_token=AAADWlnbZBZCHUBACJGrkSbkjM28BiesVSOujYOGFlvWL5QVjj2zZCeZBsc5oJgWMOMfBsp3jnV9a2kFjPK4lUXLlAZC4DctTBTrXBKlteSwZDZD&limit=25&offset=25&__after_id=1428321232"
#       }
#    }
# }
class FacebookLocation
  attr_accessor :location_object
  @location_object = nil

  def initialize(location_object)
    @location_object = location_object
  end

  def name
    @location_object['place']['name']
  end

  def lat
    @location_object['place']['location']['latitude']
  end

  def lon
    @location_object['place']['location']['longitude']
  end

  def type
    @location_object['type']
  end

  def created_date
    Date.strptime("#{@location_object['created_time'][0..9]}", "%Y-%m-%d")
  end

  def to_s
    "#{name}\n" +
    "    #{type}\n" +
    "    #{created_date}\n" +
    "    #{lat}\n" +
    "    #{lon}\n" +
    "    #{@location_object.inspect}"
  end

  def get_images(session)
    # return ["https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/181132_4077098961783_1777774991_s.jpg","https://fbcdn-photos-a.akamaihd.net/hphotos-ak-ash3/553166_3540399873646_915375718_s.jpg"]
    # return [] if type != "photo" #Fix if can get photos for checkin
    @graph  = Koala::Facebook::API.new(session[:facebook_access_token])

    if @photos.nil?
      query = "SELECT src, created FROM photo WHERE object_id IN (SELECT object_id FROM photo_tag WHERE subject=me() AND created >= #{created_date.to_time.to_i} ORDER BY created ASC LIMIT 8) ORDER BY created ASC "
      photos = @graph.fql_query(query)
      puts "#{query} :: #{photos.inspect}"
      photos.map!{|p| p["src"]}
      @photos ||= photos
    end
    return @photos[0..8]
  end

  def to_json(options={})
    @location_object.to_json
  end
end