module Admin::BaseHelper
  def active_link(obj)
    obj.active ? 'active' : 'suspended'
  end

  def flags_link(obj)
    link_to_function 'show flags', "$('#flags_#{obj.id}').toggle();$(this).toggleHtml('hide flags', 'show flags')", :id => "flag_link_#{obj.id}"
  end

  def state_links(obj)
    if obj.active
      link_to_remote('suspend', :url => { :action => :state, :id => obj.id, :state => 'suspend' })
    else
      link_to_remote('activate', :url => { :action => :state, :id => obj.id, :state => 'activate' })
    end
  end
end