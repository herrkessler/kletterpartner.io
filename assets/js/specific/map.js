$(document).ready(function(){

  var view = window.location.href;
  var geojson = [];

  function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    if (sParam === undefined) {
      return sURLVariables[0];
    } else {
      for (var i = 0; i < sURLVariables.length; i++) {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam) {
          return sParameterName[1];
        }
      }
    }
  }

  function getMap(data) {
    $.each(data, function(index, site){
      geojson.push(
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [site.lng,site.lat]
          },
          "properties": {
            "title": site.title,
            "description": site.street +'<br/>'+site.zip+' '+site.town,
            "marker-color": "#fc4353",
            'marker-symbol': 'building',
            "marker-size": "large",
            "url": '/sites/' + site.id,
            "image" : site.mainImage,
            "city": site.town,
          }
        }
      );
    });

    L.mapbox.accessToken = 'pk.eyJ1IjoiaGVycmtlc3NsZXIiLCJhIjoiRGU5R0JVYyJ9.jrfMyYYLrHEQEeWircmkGA';

    var map = L.mapbox.map('map', 'herrkessler.k8e97o6c');
      // .setView([localUser.adress_lat, localUser.adress_lng], 8);

    var myLayer = L.mapbox.featureLayer().addTo(map);

    myLayer.setGeoJSON(geojson);

    myLayer.on('mouseover', function(e) {
        e.layer.openPopup();
    });
    myLayer.on('mouseout', function(e) {
        e.layer.closePopup();
    });
    myLayer.on('click', function(e) {
        e.layer.unbindPopup();
        var url = window.location.href;
        window.location.assign(e.layer.feature.properties.url);
    });
  }

  // Map for /sites

  $.ajax({
    url: "/sites-map?" + getUrlParameter(),
    dataType: 'json',
    contentType: 'application/json',
    type: 'GET',
    accepts: "application/json",
    success: function(data) {
      console.log(data);
      getMap(data);
    }, 
    error: function(data) {
      console.log(data);
    }
  });
});
