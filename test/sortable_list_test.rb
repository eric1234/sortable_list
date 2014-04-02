ENV['RAILS_ENV'] = 'test'
require "minitest/autorun"
require 'active_support/all'
require 'action_view'
require 'sortable_list_helper'

class SortableListTest < Minitest::Test
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include SortableListHelper

  attr_accessor :params

  def setup
    self.params = {}
    SortableListHelper.asc_img = nil
    SortableListHelper.desc_img = nil
    SortableListHelper.neutral_img = nil
    SortableListHelper.position = :before
  end

  def test_normal_column
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>', s(:first_name)
  end

  def test_desc_column
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>',
      s(:first_name, :descend => true)
  end

  def test_default_column
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>',
      s(:first_name, :default => true)
  end

  def test_default_and_desc_column
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>',
      s(:first_name, :default => true)
  end

  def test_current_asc
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC">First Name</a>', s(:first_name)
  end

  def test_current_desc
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC">First Name</a>', s(:first_name)
  end

  def test_label
    assert_equal '<a href="?sort=first_name+ASC">First</a>',
      s(:first_name, :label => 'First')
  end

  def test_images_prepend
    SortableListHelper.asc_img = 'down.png'
    SortableListHelper.desc_img = 'up.png'
    SortableListHelper.neutral_img = 'neutral.png'

    assert_equal '<a href="?sort=first_name+ASC"><img alt="" border="0" src="/images/neutral.png" />&nbsp;First Name</a>', s(:first_name)
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC"><img alt="" border="0" src="/images/down.png" />&nbsp;First Name</a>', s(:first_name)
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC"><img alt="" border="0" src="/images/up.png" />&nbsp;First Name</a>', s(:first_name)
  end

  def test_images_append
    SortableListHelper.asc_img = 'down.png'
    SortableListHelper.desc_img = 'up.png'
    SortableListHelper.neutral_img = 'neutral.png'
    SortableListHelper.position = :after

    assert_equal '<a href="?sort=first_name+ASC">First Name&nbsp;<img alt="" border="0" src="/images/neutral.png" /></a>', s(:first_name)
    params[:sort] = 'first_name DESC'
    assert_equal '<a href="?sort=first_name+ASC">First Name&nbsp;<img alt="" border="0" src="/images/down.png" /></a>', s(:first_name)
    params[:sort] = 'first_name ASC'
    assert_equal '<a href="?sort=first_name+DESC">First Name&nbsp;<img alt="" border="0" src="/images/up.png" /></a>', s(:first_name)
  end

  # Simulate url_for so link_to works
  def url_for(options)
    '?' + options.collect do |key, value|
      "#{key}=#{CGI.escape value}"
    end.join('&')
  end
end
