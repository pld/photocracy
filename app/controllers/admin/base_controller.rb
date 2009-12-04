class Admin::BaseController < ApplicationController
  # Filters
  skip_before_filter :login_required
  before_filter :admin_required

  def resolve_flag
    flag = Flag.find(params[:id])
    flag.update_attribute(:active, false)
    obj = params[:item_id] ? Item.find(params[:item_id]) : Comment.find(params[:comment_id])

    render :update do |page|
      page["#{obj.class.to_s.downcase}_flag_count_#{obj.id}"].html obj.flags.count_active
      page["#{obj.class.to_s.downcase}_#{obj.id}_flag_#{flag.id}"].html render(:partial => 'admin/shared/flag', :locals => { :flag => flag, :obj => obj, :type => obj.class.to_s.downcase})
    end
  end

  def state
    klass = (params[:controller] =~ /items/) ? Item : Comment
    obj = klass.find(params[:id], :include => :flags)
    obj.send(params[:state])
    render :update do |page|
      page["#{klass.to_s.downcase}_#{obj.id}"].replace render(:partial => klass.to_s.downcase, :locals => { :item => obj, :comment => obj })
    end
  end

  def paginate
    name = params[:controller].gsub(/.*\//,'')
    name = 'items' if name == 'analytics'
    # raise name.inspect
    objs = (name.singularize.capitalize.constantize).page_find(params[:page])
    render :update do |page|
      page[name].html render(:partial => name.singularize, :collection => objs)
      page[:paginate].html will_paginate(objs, :id => :paginate)
    end
  end

  def update_translations(params, record, type)
    translations.values.each do |locale|
      if value = params.delete(locale).values.first
        if translation = record.translations.find_by_locale(locale)
          translation.update_attribute(:value, value)
        else
          translation = Translation.create(:content_id => record.id, :content_type => type, :value => value, :locale => locale)
        end
      end
    end
  end
end