root = exports ? this

$(document).ready ->
  # GENERIC STUFF

  positions = []
  $.getJSON '/earth/checkins.json', (data) =>
    bounds = new google.maps.LatLngBounds()
    positions = []
    for checkin in data
      location = checkin.place.location
      position = {name: checkin.place.name, lat: location.latitude, lon: location.longitude}
      positions.push position


  # GOOGLE MAPS SPECIFIC STUFF
  if $('#footprint_map_container').length > 0
    map = new GMaps
      div: '#map_canvas'
      lat: -12.043333
      lng: -77.028333