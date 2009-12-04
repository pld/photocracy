var Plot = {
  select: function(group) {
    group = '_' + group
    $('.plot' + group).hideAll();
    order = ($('#order' + group).length > 0) ? '_' + this.value('order', group) : '';
    $('#' + this.value('country', group) + '_' + this.value('stat', group) + group + order).show();
  },
  value: function(id, group) {
    return $('#' + id + group).selectedValue();
  }
};
