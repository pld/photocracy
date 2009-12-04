var Google = {
  optimize: function() {
    try {
    var pageTracker=_gat._getTracker("UA-8796271-1");
    pageTracker._trackPageview("/2654905852/goal");
    }catch(err){}
  },
  conversion: function(label) {
    function init () {
      var image = new Image(1,1);
      image.src = "http://www.googleadservices.com/pagead/conversion/1053141316/?label=" + label +"&amp;guid=ON&amp;script=0";
    }
    $('document').ready(function() {
      init();
    });
  },
  gaSSDSLoad: function(acct) {
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www."), pageTracker, s;
    s = document.createElement('script');
    s.src = gaJsHost + 'google-analytics.com/ga.js';
    s.type = 'text/javascript';
    s.onloadDone = false;
    function init () {
      pageTracker = _gat._getTracker(acct);
      pageTracker._trackPageview();
    }
    s.onload = function () {
      s.onloadDone = true;
      init();
    };
    s.onreadystatechange = function() {
      if (('loaded' === s.readyState || 'complete' === s.readyState) && !s.onloadDone) {
        s.onloadDone = true;
        init();
      }
    };
    document.getElementsByTagName('head')[0].appendChild(s);
  },
  map: function(wins, losses, id, center) {
    $('document').ready(function() {
      $('body').bind('onunload', GUnload);
    });
    $.timer(500, function(timer) {
      Google.mapInit(wins, losses, id, center);
      timer.stop();
    });
  },
  mapInit: function(wins, losses, id, center) {
    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById(id));
      var greenIcon = new GIcon(G_DEFAULT_ICON);
      greenIcon.image = "http://www.google.com/intl/en_us/mapfiles/ms/micons/green-dot.png";
      greenIcon.iconSize = new GSize(32, 32);
      for (var i = 0; i < wins.length; i++) {
        var point = new GLatLng(wins[i][0], wins[i][1]);
        map.addOverlay(new GMarker(point, {icon:greenIcon}));
      }
      for (i = 0; i < losses.length; i++) {
        point = new GLatLng(losses[i][0], losses[i][1]);
        map.addOverlay(new GMarker(point));
      }
      if(typeof(center) == 'undefined') { map.setCenter(point, 1); }
      else { map.setCenter(new GLatLng(center[0], center[1]), center[2]); }
      map.setUIToDefault();
    }
  },
  addMarker: function(map, lat, lng, options) {
    var point = GLatLng(lat, lng);
    map.addOverlay(new GMarker(point, options));
  }
}