module AutoDemeter
  def children_names
    base_names=self.class.reflect_on_all_associations.find_all { |x| [:has_one, :belongs_to].include?(x.instance_variable_get("@macro")) }.map { |x| x.instance_variable_get("@name").to_s }
    class_name=base_names.map { |x| x.gsub(/^#{self.class.name.underscore}_/, '') }
    class_name=class_name | base_names.map { |x| x.gsub(/^#{self.base_name.underscore}_/, '') } if self.respond_to?(:base_name) && self.class.name!=self.base_name
    base_names | class_name
  end

  def reflected_children_regex
    Regexp.new('^(' << children_names.join('|') << ')_(.*[^=])$')
  end

  def respond_through_association?(method_id)
    return false unless children_names
    if (match_data=method_id.to_s.match(reflected_children_regex)) && match_data[1].present?
      association_name=self.methods.include?(match_data[1]) ? match_data[1] : "#{self.class.name.underscore}_#{match_data[1]}"
      if send(association_name)
        true
      else
        match_data[2][0..2] == 'is_' ? true : false
      end
    else
      false
    end
  end

  def method_missing(method_id, *args, &block)
    begin
      super
    rescue NoMethodError, NameError
      if match_data=method_id.to_s.match(reflected_children_regex)
        association_name=self.respond_to?(match_data[1]) ? match_data[1] : "#{self.class.name.underscore}_#{match_data[1]}"
        if association=send(association_name)
          association.send(match_data[2], *args, &block)
        else
          match_data[2][0..2] == 'is_' ? match_data[2][3..6] == 'not_' : nil
        end
      else
        raise
      end
    end
  end
end