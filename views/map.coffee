root = exports ? this

$(document).ready ->
  if $('#footprint_map_container').length > 0
    mapOptions =
      center: new google.maps.LatLng(-34.397, 150.644),
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

    richMarker = (i) ->
      # content element of a rich marker
      richMarkerContent    = document.createElement('div');

      # # arrow image
      # arrowImage           = new Image();
      # arrowImage.src           = 'http://www.openclipart.org/image/250px/' +
      #                            'svg_to_png/Anonymous_Arrow_Down_Green.png';

      # # rotation in degree
      # directionDeg         = 144 ;

      # # create a container for the arrow
      # rotationElement      = document.createElement('div');
      # rotationStyles       = 'display:block;' +
      #                            '-ms-transform:      rotate(%rotationdeg);' +
      #                            '-o-transform:       rotate(%rotationdeg);' +
      #                            '-moz-transform:     rotate(%rotationdeg);' +
      #                            '-webkit-transform:  rotate(%rotationdeg);' ;

      # # replace %rotation with the value of directionDeg
      # rotationStyles           = rotationStyles.split('%rotation').join(directionDeg);

      # rotationElement.setAttribute('style', rotationStyles);
      # rotationElement.setAttribute('alt',   'arrow');

      # # append image into the rotation container element
      # rotationElement.appendChild(arrowImage);

      # # append rotation container into the richMarker content element
      # richMarkerContent.appendChild(rotationElement);

      # $(richMarkerContent).attr "height", "300px"
      # $(richMarkerContent).attr "width", "300px"

      # paper = Raphael($(richMarkerContent), "100%", "100%")
      # circle = paper.circle(50, 40, 10);
      # #Sets the fill attribute of the circle to red (#f00)
      # circle.attr("fill", "#f00");

      # #Sets the stroke attribute of the circle to white
      # circle.attr("stroke", "#fff");
      b = $('<div id="marker_' + i + '" style="width:1px; height: 1px; background-color: #; display: block;"><canvas id="marker_canvas_' + i + '" width="400" height="400" style="margin-left:-200px; margin-top:-200px;"></canvas></div>')
      $(richMarkerContent).append(b);

      console.log richMarkerContent
      return $(richMarkerContent).html()


    markers = []

    $.getJSON '/map/checkins.json', (data) =>
      bounds = new google.maps.LatLngBounds()
      markers = []
      i = 0
      for checkin in data
        location = checkin.place.location
        position = new google.maps.LatLng(location.latitude, location.longitude)
        # marker = new google.maps.Marker
        #   position: position
        #   map: map
        #   title: checkin.place.name
              # create a rich marker ("position" and "map" are google maps objects)
        richMarkerContent = richMarker(i)
        marker = new RichMarker
          position    : position
          map         : map
          draggable   : false
          flat        : true
          anchor      : RichMarkerPosition.TOP_RIGHT
          content     : richMarkerContent

        bounds.extend(position)
        markers.push marker
        i += 1
      map.fitBounds(bounds)

    root.goToLocation = (i, distance=500) =>
      console.log markers, i

      map.panTo markers[i].position
      map.setZoom(17)

      setTimeout () ->
        mc = $("#marker_canvas_" + i)
        mc.drawImage({
          source: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/49464_1111745248_2011951642_n.jpg",
          x: 200,
          y: 200,
          width: 100,
          height: 100,
          fromCenter: true,
          translateX: 0, translateY: 0
        });
        # mc.animateLayer(0, {
        #   rotate: 360
        # }, 3000)
      , 2000
    
    root.seeMarker = (i) =>
      map.panTo markers[Math.min(i-1, 0)].position
      map.setZoom(17)