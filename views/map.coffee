root = exports ? this

$(document).ready ->
  if $('#footprint_map_container').length > 0
    mapOptions =
      center: new google.maps.LatLng(-34.397, 150.644),
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions)

    richMarker = (i, label, photos) ->
      # content element of a rich marker
      richMarkerContent    = document.createElement('div');
      console.log photos
      b = $('<div id="marker_' + i + '" style="width:1px; height: 1px; background-color: #; display: block;"><input id="marker_name_' + i + '" type="hidden" value=\'' + label + '\'/><input id="marker_photos_' + i + '" type="hidden" value=\'' + photos.toString().replace('"', '\"') + '\'/><canvas class="marker_canvas" id="marker_canvas_' + i + '" width="400" height="400" style="margin-left:-200px; margin-top:-200px;"></canvas></div>')
      $(richMarkerContent).append(b);

      # console.log richMarkerContent
      return $(richMarkerContent).html()


    markers = []

    $.getJSON '/map/checkins.json', (data) =>
      bounds = new google.maps.LatLngBounds()
      markers = []
      i = 0
      for checkin in data
        location = checkin.place.location
        position = new google.maps.LatLng(location.latitude, location.longitude)

        # Normal maker/indicator
        marker = new google.maps.Marker
          position: position
          map: map
          title: checkin.place.name

        # create a rich marker ("position" and "map" are google maps objects)
        richMarkerContent = richMarker(i, checkin.place.name, JSON.stringify(checkin.photos))
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
      console.log $("#marker_photos_" + i), i
      console.log "GOTJSON", JSON.parse($("#marker_photos_" + i).val())

      photos = JSON.parse($("#marker_photos_" + i).val())

      map.panTo markers[i].position
      map.setZoom(17)

      $(".marker_canvas").removeLayers();

      animatel = (canv, k) =>
          canv.setLayer(7-k, {visible: true}).drawLayers();
          canv.animateLayer(7-k, {
            rotate: k*360/8
          }, (300*k))
        # , (1600 - (200*k))

      setTimeout () =>
        mc = $("#marker_canvas_" + i)

        mc.drawArc({
          layer: true,
          fillStyle: "#fff",
          x: 200, y: 200,
          radius: 0,
          shadowColor: "#000",
          shadowBlur: 5,
        })
        .animateLayer(0, {
            radius: 120,
            index: 0,
          },
          500,
          "swing",
          () =>
            mc.addLayer({
              method: "drawText",
              fillStyle: "#444",
              x: 200, y: 200,
              fromCenter: true,
              font: "10pt Verdana, sans-serif",
              text: $("#marker_name_" + i).val()
            }).drawLayers()

            for j in [0..7]
              if j < photos.length
                source = photos[j]
              else
                source = "http://wm-icons.sourceforge.net/data/wm-icons-current/icons/64x64-gant/empty.png"
              mc.drawImage({
                layer: true,
                index: 0,
                name: "img" + j,
                source: source,
                x: 200,
                y: 200,
                width: 100,
                height: 100,
                fromCenter: true,
                translateX: 0,
                translateY: -150
              })
            for k in [0..7]
              animatel(mc, k)
        )

      , 1000
    
    root.seeMarker = (i) =>
      map.panTo markers[Math.min(i-1, 0)].position
      map.setZoom(17)