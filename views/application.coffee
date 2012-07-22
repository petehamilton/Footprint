root = exports ? this

$(document).ready ->
  ge = root.ge
  if $('#footprint_map_container').length > 0
    console.log "Loaded"
    console.log ge
    setTimeout () ->
      # console.log "T"
      ge = root.ge
      # console.log ge
    , 2000


  positions = []
  $.getJSON 'checkins.json', (data) =>
    bounds = new google.maps.LatLngBounds()
    positions = []
    for checkin in data
      location = checkin.place.location
      position = {lat: location.latitude, lon: location.longitude}
      positions.push position

  root.goToLocation = (i, distance=500) =>
    lookAt = ge.createLookAt('')
    position = positions[i]
    ge.getOptions().setFlyToSpeed(0.4) #0 -> 5, bigger = faster
    lookAt.setLatitude(position.lat)
    lookAt.setLongitude(position.lon)
    lookAt.setAltitude(0) # Alt in m
    lookAt.setRange(distance) # Distance from alt in m
    lookAt.setHeading(0)
    ge.getView().setAbstractView(lookAt);

  root.tour = (i=0, time=7000) ->
    root.goToLocation(i)
    setTimeout () ->
      root.tour(i + 1, time)
    , time

  root.seePosition = (i) =>
    console.log positions[i]