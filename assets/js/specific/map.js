$(document).ready(function(){

  var view = window.location.href;
  var geojson = [];

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

  if(view.indexOf("sites") > -1) {

    // Get all Sites

    $.ajax({
      url: "/sites-map",
      dataType: 'json',
      contentType: 'application/json',
      type: 'GET',
      accepts: "application/json",
      success: function(data) {
        getMap(data);
      }, 
      error: function(data) {
        console.log(data);
      }
    });

    // io.socket.get("/site/", function (data, jwres){
    //   var allSites = data;
    //   $.each(allSites.sites, function(index, site){
    //     geojson.push(
    //       {
    //         "type": "Feature",
    //         "geometry": {
    //           "type": "Point",
    //           "coordinates": [site.adress_lng,site.adress_lat]
    //         },
    //         "properties": {
    //           "title": site.name,
    //           "description": site.adress_street +' '+site.adress_number+'<br/>'+site.adress_zip+' '+site.adress_city,
    //           "marker-color": "#fc4353",
    //           'marker-symbol': 'building',
    //           "marker-size": "large",
    //           "url": '/site/show/' + site.id,
    //           "image" : site.mainImage,
    //           "city": site.adress_city,
    //         }
    //       }
    //     );
    //   });

      // Get Session User

      // io.socket.get('/user/show/'+localUserId , function (data, jwres){
      //   var localUser = data.user;
      //   geojson.push(
      //     {
      //       "type": "Feature",
      //       "geometry": {
      //         "type": "Point",
      //         "coordinates": [localUser.adress_lng,localUser.adress_lat]
      //       },
      //       "properties": {
      //         "title": localUser.firstName,
      //         "description": localUser.adress_city,
      //         "marker-color": "#354B60",
      //         'marker-symbol': 'pitch',
      //         "marker-size": "large",
      //         "url": '/user/show/' + localUser.id
      //       }
      //     }
      //   );

        // if (geojson !== undefined) {

          // L.mapbox.accessToken = 'pk.eyJ1IjoiaGVycmtlc3NsZXIiLCJhIjoiRGU5R0JVYyJ9.jrfMyYYLrHEQEeWircmkGA';

          // var map = L.mapbox.map('map', 'herrkessler.k8e97o6c');
          //   // .setView([localUser.adress_lat, localUser.adress_lng], 8);

          // var myLayer = L.mapbox.featureLayer().addTo(map);

          // myLayer.setGeoJSON(geojson);

          // myLayer.on('mouseover', function(e) {
          //     e.layer.openPopup();
          // });
          // myLayer.on('mouseout', function(e) {
          //     e.layer.closePopup();
          // });
          // myLayer.on('click', function(e) {
          //     e.layer.unbindPopup();
          //     var url = window.location.href;
          //     window.location.assign(e.layer.feature.properties.url);
          // });

        // } else {
        //   $('#map').addClass('no-adress');
        // }
  }
});
