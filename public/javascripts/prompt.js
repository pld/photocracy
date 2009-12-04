var Item = {
  Highlight: {
    add_: function(id) { $('#item_' + id).css({'border': '3px solid #11F', 'border-top': '2px solid #11F', 'border-bottom': '2px solid #11F', 'margin': '0 4px'}); },
    remove_: function(id) { $('#item_' + id).css({'border': '1px solid #FFF', 'border-top': '1px solid #FFF', 'border-bottom': '1px solid #FFF', 'margin': '1px 6px'}); }
  },
  unlock: function(id) { $(id).removeClass('prompt-off'); },
  lock: function(id) {
    $(id).addClass('prompt-off'); 
  },
  click: function(id, step) {
    Back.no();
    this.Highlight.add_(id);
    if(Prompt.Time.toFast()) {
      $('#slow_container').css({backgroundColor: '#FF6464'});
      $('#slow').show();
      setTimeout(function() {
        $('#slow').fadeOut(1000);
        $('#slow_container').animate({backgroundColor: '#FFFFFF'});
      }, 1500);
      setTimeout(function() {
        Item.Highlight.remove_(id);
      }, Prompt.Delay.quick);
      return false;
    } else {
      Progress.step(step);
      Prompt.fade();
      Prompt.Time.set();
      if ($('#click_message').css('display') != 'none') {
        $('#click_message').fadeOut(Prompt.Delay.quick);
      }
      return true;
    }
  },
  validFlag: function(suffix) {
    return $('#flag_flag_type_id_' + suffix).attr('selectedIndex') > 0
  },
  flag: function(suffix) {
    if (this.validFlag(suffix)) {
      Back.no();
      Prompt.fade();
      Prompt.Time.reset_();
      $('#flag_errors').hide();
      $('#flag_item_left').fadeOut();
      $('#flag_item_right').fadeOut();
      $('#flag_content_left').html('');
      $('#flag_content_right').html('');
    } else {
      $('#flag_errors').show();
    }
  }
};
var Prompt = {
  color: 'rgb(102, 102, 255)',
  fade: function() {
    var left = '#item_left';
    var prev_left = '#item_left';
    var right = '#item_right';
    var prev_right = '#item_right';
    var from = '';
    var to = '';
    if ($('#item_left_alt').css('display') == 'none') {
      left += '_alt';
      right += '_alt';
      to = '_alt';
    } else {
      prev_left += '_alt';
      prev_right += '_alt';
      from = '_alt';
    }
      $([$(prev_left), $(prev_right), $('#versus'), $('#skip_outer')]).each(function(el) {
        $(this).fadeOut(Prompt.Delay.longer);
      });
      Item.lock(prev_left);
      if ($(left).strip() != '') {
        setTimeout(function() { Prompt.appear(left, right, prev_left, prev_right); }, Prompt.Delay.longer);
      }
    Last.switchTo(from, to);
  },
  appear: function(left, right, prev_left, prev_right, no_reset) {
    $.timer(100, function(timer) {
      if ($(left).hasClass('prompt-off') == false) {
        $('#flag_item_id_left').attr('value', $(left + ' a:first-child').attr('id'));
        $('#flag_item_id_right').attr('value', $(right + ' a:first-child').attr('id'));
        $(prev_left).hide()
        $(prev_right).hide()
        $(left).fadeIn(Prompt.Delay.quick);
        $(right).fadeIn(Prompt.Delay.quick);
        Prompt.showOptions();
        if (typeof(no_reset) == 'undefined') { Prompt.Time.reset_(); }
        timer.stop();
      } else { timer.reset(100); }
    });
  },
  with_: function(step) {
    alt = $('#item_left_alt').css('display') == 'none'
    string = 'response_time=' + this.Time.fetch() + '&alt=' + alt;
    string += '&mouse=' + Mouse.get() + '&new_question=' + Progress.next(step) + '&second_last=' + Progress.secondLast(step);
    Mouse.clear(alt);
    return string;
  },
  skip: function(width) {
    Back.no();
    this.fade();
    this.Time.reset_();
    Progress.step(width);
  },
  showOptions: function() { 
    $([$('#versus'), $('#skip_outer')]).each(function(el) { $(this).fadeIn(Prompt.Delay.quick); });
  },
  hideOptions: function() { 
    $([$('#versus'), $('#skip_outer')]).each(function(el) { $(this).fadeOut(Prompt.Delay.quick); });
  },
  update: function(left_id, right_id, left, right, unlock) {
    $.timer(100, function(timer) {
      if ($(left_id).css('display') == 'none' || $(left_id).strip() == '') {
        Prompt.Timers.unset(left);
        $(left_id).html(left);
        $(right_id).html(right);
        if (left != '' && (typeof(unlock) == 'undefined' || unlock == true)) { Item.unlock(left_id); }
        timer.stop();
      } else {
        Prompt.Timers.set(left, timer);
        timer.reset(100)
      }
    });
  },
  Delay: { longer: 600, quick: 350 },
  Time: {
    store: '#timing',
    minWait: 150,
    fetch: function() { return $(this.store).html() },
    unix: function() { return (new Date()).getTime(); },
    reset_: function() { $(this.store).html(this.unix()); },
    get: function() { return parseInt(this.unix()) - parseInt(this.fetch()); },
    set: function() { $(this.store).html(this.get()); },
    toFast: function() {
      return (this.get() < this.minWait);
    }
  },
  Timers: {
    timer: null,
    timer_alt: null,
    set: function(timer, left) {
      if (left == '#item_left') { Prompt.Timers.timer = timer; } else { Prompt.Timers.timer_alt = timer }
    },
    stop_: function() {
      if (Prompt.Timers.timer) {
        Prompt.Timers.timer.stop();
        Prompt.Timers.timer = null
      }
      if (Prompt.Timers.timer_alt) {
        Prompt.Timers.timer_alt.stop();
        Prompt.Timers.timer_alt = null;
      }
    },
    unset: function(left) {
      if (left == '#item_left') { Prompt.Timers.timer = null; } else { Prompt.Timers.timer_alt = null }
    }
  }
};
var Progress = {
  currentPercent: function() { return parseFloat($('#progress').css('width')); },
  next: function(step) { return Progress.currentPercent() > 99 - step; },
  secondLast: function(step) {
    current = Progress.currentPercent()
    return (current > 99 - step * 2.5 && current < 99 - step * 1.5);
  },
  step: function(size) {
    Progress.update(Progress.currentPercent() + parseFloat(size));
  },
  update: function(width) {
    var bars = this.bars();
    var count = 0;
    var mid = Math.floor((bars.size() / 2));
    if ($(this.bars()[0]).css('opacity') != '1') { width = 0; }
    bars.each(function(el) {
      el = $(this);
      if (width > 98) { width = 100;
      } else if (width < 0.01) { width = 0.01; }
      el.animate({ 'width': width + '%' }, 1500);
      count += 1;
      width += (count <= mid) ? 0.1 : -0.1;
    });
  },
  _reset: function() {
    var bars = this.bars();
    bars.each(function(el) { $(this).fadeOut(2 * Prompt.Delay.longer); });
    setTimeout(function() {
      Progress.zero();
      bars.each(function(el) { $(this).fadeIn(Prompt.Delay.quick); });
    }, 2 * Prompt.Delay.longer);
  },
  zero: function() {
    var count = 0;
    var bars = this.bars();
    var mid = Math.floor((bars.size() / 2));
    var width = 0.2;
    bars.each(function(el) {
      $(this).css({ 'width': width + '%' });
      count += 1;
      width += (count <= mid) ? 0.1 : -0.1;
    });
  },
  bars: function() { return $('.progress-bar'); }
};
var Last = {
  switchTo: function(from, to) {
    $(['last_left', 'last_right', 'last_percent_left', 'last_percent_right']).each(function(el) {
      $('#' + this + from).fadeOut(Prompt.Delay.longer);
    });
    $('.last_text').fadeOutAll(Prompt.Delay.longer);
    setTimeout(function() {
      $(['last_left', 'last_right', 'last_percent_left', 'last_percent_right']).each(function(el) {
        $('#' + this + to).fadeIn(Prompt.Delay.quick);
      $('.last_text').fadeInAll(Prompt.Delay.longer);
      });
    }, Prompt.Delay.longer);
  },
  update: function(left, right, left_percent, right_percent, suffix) {
    $('#last_left' + suffix).html(left);
    $('#last_right' + suffix).html(right);
    $('#last_percent_left' + suffix).html(left_percent);
    $('#last_percent_right' + suffix).html(right_percent);
  }
};
var Question = {
  Delay: {
    fadeIn: 1000,
    fadeOut: 500,
    hideFlash: 1500,
    firstFlash: 500,
    secondFlash: 750,
    showPrompt: 1750,
    highlight: 0
  },
  flash: function(final_color) {
    Question.items().each(function(el) {
      $(this).animate({ backgroundColor: final_color });
    });
  },
  items: function() {
    return $('h1 table td.question .rounded *, h1 table td.question .roundedfg');
  },
  updateStart: function(left_id, right_id) {
    $('#question_box').fadeTo(Question.Delay.fadeOut, 0.01);
    $([$(left_id), $(right_id)]).each(function(el) { $(this).hide(); });
  },
  updateEnd: function(left, right, prev_left, prev_right) {
    Progress._reset()
    setTimeout(function() {
      $('#question_box').fadeTo(Question.Delay.fadeIn, 1);
      setTimeout(function() {
        setTimeout(function() { Progress.zero(); Question.flash(Prompt.color); },Question.Delay.highlight);
        setTimeout(function() { Progress.zero(); Question.flash('rgb(200, 200, 255)'); }, Question.Delay.firstFlash);
        setTimeout(function() { Progress.zero(); Question.flash(Prompt.color); }, Question.Delay.secondFlash);
        setTimeout(function() { Progress.zero(); Question.flash('rgb(255, 255, 255)'); }, Question.Delay.hideFlash);
        setTimeout(function() {
          Item.unlock(left);
          Prompt.appear(left, right, prev_left, prev_right);
        }, Question.Delay.showPrompt);
      }, Question.Delay.fadeIn) ;
    }, Question.Delay.fadeOut);
  }
};