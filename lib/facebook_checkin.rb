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
class FacebookCheckin
  def initialize(checkin_object)
    @checkin_object = checkin_object
  end

  def name
    @checkin_object['place']['name']
  end

  def lat
    @checkin_object['place']['location']['latitude']
  end

  def lon
    @checkin_object['place']['location']['longitude']
  end

  def to_s
    "#{name}\n" +
    "    #{lat}\n" +
    "    #{lon}\n"
  end
end