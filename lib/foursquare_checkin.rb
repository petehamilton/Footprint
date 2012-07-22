# EXAMPLE CHECKIN OBJECT

class FoursquareCheckin
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