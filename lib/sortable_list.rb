module SortableListHelper
  # The images that should be used to represent assending and
  # desending columns as well as columns that are not sorted.
  # Also you can specify if you want the image before or after the text.
  mattr_accessor :asc_img, :desc_img, :neutral_img, :position
  self.position = :before

  # To use simply put this in your table header
  #
  #     <th><%=s :first_name %></th>
  #
  # This will create markup that looks like the following:
  #
  #     <th><a href="?sort=first_name%20ASC">First Name</a></th>
  #
  # Then in your controller just do:
  #
  #     @users = User.find :all, order: params[:sort]
  #
  # If the current field is the field being sorted then it will do the
  # opposite direction. So if the user clicked the link for the past
  # request then the same code will now generate
  #
  #     <th><a href="?sort=first_name%20DESC">First Name</a></th>
  #
  # This allows users to reverse the order simply by clicking the link
  # again. Also takes an option hash with the following options:
  #
  # label::
  #   By default the label is simply titleized. This is not always
  #   correct. You can manually specify the label with this option.
  # class_name::
  #   Instead of titleizing the field the class specified will be used
  #   to pull the human_attribute_name for titlization. This passes
  #   through i18n allows you to localize the labels. Also the table
  #   name will be included. Useful if your table is pulling from
  #   multiple models that might have the same name. Assumes an
  #   ActiveRecord model.
  # descend::
  #   Set to true if you want this column to initially be decending.
  #   Date columns are often used in this way.
  # default::
  #   Set to true if this column is the default sort column. This means
  #   that if the :sort param has no value this column assumes it is
  #   sorting the data. You should specify one column with
  #   default: true
  #
  # NOTE: This method is aliased as #s for easy programming much like
  # the #h method which aliases #html_escape
  def sortable_header(field, options={})
    dir = 'ASC'
    dir = 'DESC' if options[:descend]
    klass = options[:class_name].constantize if options[:class_name]
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

    label = if options[:label]
      options[:label]
    elsif klass
      klass.human_attribute_name field
    else
      field.titleize
    end

    img = if cur && cur_field == field
      if dir == 'ASC'
        SortableListHelper.asc_img
      else
        SortableListHelper.desc_img
      end
    else
      SortableListHelper.neutral_img
    end
    img = image_tag img, alt: '', border: 0 if img

    label = if SortableListHelper.position == :after
      "#{label}&nbsp;#{img}"
    else
      "#{img}&nbsp;#{label}"
    end if img

    # field should in general equal to klass.columns_hash[field].name.
    # But doing the lookup provides a hook allowing for a seperation
    # between the attribute name and the column name. The class could
    # return a hash not indexed by the column name but instead a
    # distinct attribute name.
    if klass && (column = klass.columns_hash[field])
      field = "#{klass.quoted_table_name}.#{klass.connection.quote_column_name column.name}"
    end

    args = params.merge sort: "#{field} #{dir}"
    link_to label.html_safe, args
  end
  alias_method :s, :sortable_header

  class Railtie < Rails::Railtie
    initializer 'sortable_list.register_helper' do
      ActionController::Base.helper SortableListHelper
    end
  end if defined? Rails
end
