root = exports ? this

$(document).ready ->
  if $('#footprint_map_container').length > 0
    mapOptions =
      center: new google.maps.LatLng(-34.397, 150.644),
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
    # map = new GMaps
    #   div: '#map_canvas'
    #   lat: -12.043333
    #   lng: -77.028333
    #   zoom: 8
    #   mapTypeId: google.maps.MapTypeId.ROADMAP
    markers = []

    $.getJSON '/map/checkins.json', (data) =>
      bounds = new google.maps.LatLngBounds()
      markers = []
      for checkin in data
        location = checkin.place.location
        position = new google.maps.LatLng(location.latitude, location.longitude)
        marker = new google.maps.Marker
          position: position
          map: map
          title: checkin.place.name
        bounds.extend(position)
        markers.push marker
      map.fitBounds(bounds)

    root.goToLocation = (i, distance=500) =>
      map.panTo markers[i].position
      map.setZoom(17)
    
    root.seeMarker = (i) =>
      # bounds = new google.maps.LatLngBounds()
      # console.log map, markers, markers[i], bounds
      # bounds.extend(markers[i].position)
      # map.fitBounds(bounds)
      map.panTo markers[i].position
      map.setZoom(17)
      # center = new GPoint( (maxLon+minLon)/2, (maxLat+minLat)/2 )
      # delta = new GSize( maxLon-minLon, maxLat-minLat)
      # minZoom = map.spec.getLowestZoomLevel(center, delta, map.viewSize)
      
      # map.centerAndZoom(center, minZoom)

      # console.log map