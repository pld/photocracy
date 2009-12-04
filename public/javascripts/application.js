var Locale = {
  setStyle: function(locale) {
    var set = false;
    switch(locale) {
      case 'jp':
        set = '12px 0.7%'
        break;
      case 'es':
        set = '12px 1.8%'
      default:
        break;
    }
    if (set != false) {
      $("div.links .nav a").each(function(el) {
        $(this).css({padding: set});
      });
    }
  }
};
var Message = {
  notify: function(text, hide_after) { this.message(text, 'notice', hide_after); },
  error: function(text, hide_after) { this.message(text, 'error', hide_after); },
  message: function(text, class_, hide_after) {
    id = 'flash_' + class_ + '_content';
    $('#flash_' + class_).html('<h2 id="' + id + '" class="' + class_ + '">' + text + '</h2>');
    if (typeof(hide_after) == 'number' && hide_after > 0) {
      setTimeout(function() {
        $('#' + id).fadeOut(1000);
      }, hide_after);
    }
  },
  delayedHide: function(time) { setTimeout(function() { $('#flash_notice_content').fadeOut(time/3); }, time); }
};
var Back = {
  no: function() { window.location.href = '#1'; },
  check: function() { setTimeout("Back.timed()", 1); },
  timed: function() { if (window.location.href.indexOf('#1') > -1) { window.location.href=window.location.pathname; } }
};
var Item = {
  submit: function() {
    $('#item_submit').css({ 'border': '2px solid #000' });
    if (!$('#item_agree').attr('checked')) {
      $('#agree').addClass('errorExplanation');
      $('#agree-error').show();
      $('#item_submit').css({ 'border': '2px solid #CCC' });
      return false;
    } else {
      $('#agree').removeClass('errorExplanation');
      $('#agree-error').hide();
      return true;
    }
  },
  changeType: function(name, instructions) {
    $('.options a').each(function(el) { $(this).removeClass('active'); });
    $('#' + name + '_link').addClass('active');
    $('.upload tr.file-types').each(function(el) { $(this).hide(); });
    $('#item_type').attr('value', name);
    $('#' + name).show();
    $('#instructions').html(instructions);
  }
};
function includeJS(filename) {
  var html_doc = document.getElementsByTagName('head').item(0);
  var js = document.createElement('script');
  js.setAttribute('language', 'javascript');
  js.setAttribute('type', 'text/javascript');
  js.setAttribute('src', filename);
  html_doc.appendChild(js);
  return false;
}
jQuery.timer = function (interval, callback) {
  var interval = interval || 100;
  if (!callback) return false;
  _timer = function (interval, callback) {
    this.stop = function () { clearInterval(self.id); };
    this.internalCallback = function () { callback(self); };
    this.reset = function (val) {
      if (self.id) clearInterval(self.id);
      var val = val || 100;
      this.id = setInterval(this.internalCallback, val);
    };
    this.interval = interval;
    this.id = setInterval(this.internalCallback, this.interval);
    var self = this;
  };
  return new _timer(interval, callback);
};
jQuery.fn.toggleHtml = function(html1, html2) {
  (this.html() == html1) ? this.html(html2) : this.html(html1);
  return this;
};
jQuery.fn.selectedValue = function() { return this.attr('options')[this.attr('selectedIndex')].value; };
jQuery.fn.strip = function() { return this.html().replace(/^\s*|\s*$/g,''); };
jQuery.fn.hideAll = function() { this.each(function(s, index) { $(this).hide() }); };
jQuery.fn.showAll = function() { this.each(function(s, index) { $(this).show() }); };
jQuery.fn.fadeOutAll = function(delay) { this.each(function(s, index) { $(this).fadeOut(delay) }); };
jQuery.fn.fadeInAll = function(delay) { this.each(function(s, index) { $(this).fadeIn(delay) }); };
(function(jQuery){
  jQuery.each(['backgroundColor', 'borderBottomColor', 'borderLeftColor', 'borderRightColor', 'borderTopColor', 'color', 'outlineColor'], function(i,attr){
    jQuery.fx.step[attr] = function(fx){
      if ( fx.state == 0 ) {
        fx.start = getColor( fx.elem, attr );
        fx.end = getRGB( fx.end );
      }
      fx.elem.style[attr] = "rgb(" + [
        Math.max(Math.min( parseInt((fx.pos * (fx.end[0] - fx.start[0])) + fx.start[0]), 255), 0),
        Math.max(Math.min( parseInt((fx.pos * (fx.end[1] - fx.start[1])) + fx.start[1]), 255), 0),
        Math.max(Math.min( parseInt((fx.pos * (fx.end[2] - fx.start[2])) + fx.start[2]), 255), 0)
      ].join(",") + ")";
    }
  });
  function getRGB(color) {
    var result;
    if ( color && color.constructor == Array && color.length == 3 )
      return color;
    if (result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color))
      return [parseInt(result[1]), parseInt(result[2]), parseInt(result[3])];
    if (result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(color))
      return [parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55];
    if (result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(color))
      return [parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16)];
    if (result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(color))
      return [parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16)];
    return colors[jQuery.trim(color).toLowerCase()];
  }
  function getColor(elem, attr) {
    var color;
    do {
      color = jQuery.curCSS(elem, attr);
      if ( color != '' && color != 'transparent' || jQuery.nodeName(elem, "body") ) { break; };
      attr = "backgroundColor";
    } while ( elem = elem.parentNode );
    return getRGB(color);
  };
  var colors = {
    aqua:[0,255,255],
    azure:[240,255,255],
    beige:[245,245,220],
    black:[0,0,0],
    blue:[0,0,255],
    brown:[165,42,42],
    cyan:[0,255,255],
    darkblue:[0,0,139],
    darkcyan:[0,139,139],
    darkgrey:[169,169,169],
    darkgreen:[0,100,0],
    darkkhaki:[189,183,107],
    darkmagenta:[139,0,139],
    darkolivegreen:[85,107,47],
    darkorange:[255,140,0],
    darkorchid:[153,50,204],
    darkred:[139,0,0],
    darksalmon:[233,150,122],
    darkviolet:[148,0,211],
    fuchsia:[255,0,255],
    gold:[255,215,0],
    green:[0,128,0],
    indigo:[75,0,130],
    khaki:[240,230,140],
    lightblue:[173,216,230],
    lightcyan:[224,255,255],
    lightgreen:[144,238,144],
    lightgrey:[211,211,211],
    lightpink:[255,182,193],
    lightyellow:[255,255,224],
    lime:[0,255,0],
    magenta:[255,0,255],
    maroon:[128,0,0],
    navy:[0,0,128],
    olive:[128,128,0],
    orange:[255,165,0],
    pink:[255,192,203],
    purple:[128,0,128],
    violet:[128,0,128],
    red:[255,0,0],
    silver:[192,192,192],
    white:[255,255,255],
    yellow:[255,255,0]
  };
})(jQuery);
$(document).ajaxSend(function(event, request, settings) {
  if (settings.type == 'GET' || settings.type == 'get' || typeof(AUTH_TOKEN) == "undefined") return;
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});
jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} });