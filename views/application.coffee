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

    $.getJSON 'checkins.json', (data) =>
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

# 
# Utility function to calculate the appropriate zoom level for a
# given bounding box and map image size. Uses the formula described
# in the Google Mapki (http://mapki.com/).
# 
# @param  bounds  bounding box (GBounds instance)
# @param  mnode   DOM element containing the map.
# @return         zoom level.
# 
# best_zoom_for_bounds = (bounds, mnode) ->
#     width = mnode.offsetWidth
#     height = mnode.offsetHeight

#     dlat = Math.abs(bounds.maxY - bounds.minY)
#     dlon = Math.abs(bounds.maxX - bounds.minX)
#     if (dlat == 0 && dlon == 0)
#         return 4

#     #Center latitude in radians
#     clat = Math.PI*(bounds.minY + bounds.maxY)/360.

#     C = 0.0000107288
#     z0 = Math.ceil(Math.log(dlat/(C*height))/Math.LN2)
#     z1 = Math.ceil(Math.log(dlon/(C*width*Math.cos(clat)))/Math.LN2)

#     return (z1 > z0) ? z1 : z0
# }