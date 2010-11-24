module SortableListHelper
  # The images that should be used to represent assending and
  # desending columns as well as columns that are not sorted.
  # Also you can specify if you want the image before or after the text.
  mattr_accessor :asc_img, :desc_img, :neutral_img, :position
  self.position = :before

  # To use simply put this in your table header
  #
  #     <th><%=s :first_name%></th>
  #
  # This will create markup that looks like the following:
  #
  #     <th><a href="?sort=first_name%20ASC">First Name</a></th>
  #
  # Then in your controller just do:
  #
  #     @users = User.find :all, :order => params[:sort]
  #
  # If the current field is the field being sorted then it will do the opposite
  # direction. So if the user clicked the link for the past request then the
  # same code will now generate
  #
  #     <th><a href="?sort=first_name%20DESC">First Name</a></th>
  #
  # This allows users to reverse the order simply by clicking the link again.
  # In addition sortable_header method takes a option hash as the second
  # argument with the following valid options:
  #
  # label::
  #   If titilize is not guessing your field name correctly you can use
  #   this to give an explicit label.
  # descend::
  #   Set to true if you want this column to initially be decending.
  #   Date columns are often used in this way.
  # default::
  #   Set to true if this column is the default sort column. This means
  #   that if the :sort param has no value this column assumes it is
  #   sorting the data. You should specify one column with
  #   default => true
  #
  # NOTE: This method is aliased as #s for easy programming much like
  # the #h method which escapes #html_escape
  def sortable_header(field, options={})
    dir = 'ASC'
    dir = 'DESC' if options[:descend]
    field = field.to_s

    cur = if params[:sort].present?
      params[:sort]
    elsif options[:default] && params[:sort].blank?
      "#{field} #{dir}"
    end
    if cur
      cur_field, cur_dir = cur.split(/\s*,\s*/).first.split /\s+/
      dir = cur_dir == 'ASC' ? 'DESC' : 'ASC' if cur_field == field
    end

    label = options[:label] || field.titleize

    img = if cur && cur_field == field
      if dir == 'ASC'
        SortableListHelper.asc_img
      else
        SortableListHelper.desc_img
      end
    else
      SortableListHelper.neutral_img
    end
    img = image_tag img, :alt => '', :border => 0 if img

    label = if SortableListHelper.position == :after
      "#{label}&nbsp;#{img}"
    else
      "#{img}&nbsp;#{label}"
    end if img

    args = params.merge :sort => "#{field} #{dir}"
    link_to label.html_safe, args
  end
  alias_method :s, :sortable_header

  class Railtie < Rails::Railtie
    initializer 'sortable_list.register_helper' do
      ActionController::Base.helper SortableListHelper
    end
  end if defined? Rails
end
