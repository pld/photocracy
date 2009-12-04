var Mouse = {
  store: '#tracking',
  clear: function(alt) { $(this.store).html(Mouse.imageLocations(alt)); },
  get: function() { return $(Mouse.store).html(); },
  append: function(str) { $(Mouse.store).html(Mouse.get() + str); },
  storePosition: function(e) {
    var type = 'm';
    if(e.type == 'mousedown') { type = 'd'; } else if(e.type == 'mouseup') { type = 'u'; }
    Mouse.append(type + '(' + Prompt.Time.get() + ',' + e.pageX + ',' + e.pageY + ')');
  },
  imageLocations: function(alt) {
    side = 'l';
    left = '#item_left';
    right = '#item_right';
    if (alt) {
      left += '_alt';
      right += '_alt';
    }
    $(Mouse.store).html('');
    $.timer(0, function(timer) {
      try {
        $([$(left + ' .roundedfg img'), $(right + ' .roundedfg img')]).each(function(el) {
          img = $(this);
          var pos = img.position();
          Mouse.append(side + '(' + pos.left + ',' + pos.top + ',' + img.attr('width') + ',' + img.attr('height') + ')');
          side = 'r';
        });        
        timer.stop();
      } catch(err) {
        timer.reset(100);
      }
    });
  }
};
$('document').ready(function() {
  Mouse.imageLocations();
  $('body').bind('mousemove', Mouse.storePosition);
  $('body').bind('mousedown', Mouse.storePosition);
  $('body').bind('mouseup', Mouse.storePosition);
});