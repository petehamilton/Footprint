$(document).ready ->
  if $('#footprint_map_container').length > 0
    map = new GMaps
      div: '#map_canvas'
      lat: -12.043333
      lng: -77.028333

    console.log map

  # $(window).resize () ->
  #   var h = $(window).height(),
  #       offsetTop = 60; // Calculate the top offset

  #   $('#map-canvas').css('height', (h - offsetTop));
  # .resize();