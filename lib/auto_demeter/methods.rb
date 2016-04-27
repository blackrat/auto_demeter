module AutoDemeter
  private
  def base_names
    @base_names||=self.class.reflect_on_all_associations.find_all { |x| [:has_one, :belongs_to].include?(x.send(:macro)) }.map { |x| x.send(:name).to_s }
  end

  def children_names
    class_name=base_names.map { |x| x.gsub(/^#{self.class.name.underscore}_/, '') }
    class_name=class_name | base_names.map { |x| x.gsub(/^#{self.base_name.underscore}_/, '') } if self.respond_to?(:base_name) && self.class.name!=self.base_name
    @children_names||=base_names | class_name
  end

  def reflected_children_regex
    Regexp.new('^(' << children_names.join('|') << ')_(.*[^=])$')
  end

  def respond_through_association?(method_id)
    if children_names && (match_data=method_id.to_s.match(reflected_children_regex)) && match_data[1].present?
      association_name=self.methods.include?(match_data[1]) ? match_data[1] : "#{self.class.name.underscore}_#{match_data[1]}"
      begin
        send(association_name) ? true : match_data[2][0..2] == 'is_'
      rescue
        false
      end
    else
      false
    end
  end

  public
  def respond_to?(method_id)
    super || (method_id != :base_name && respond_through_association?(method_id))
  end

  def method_missing(method_id, *args, &block)
    begin
      super
    rescue NoMethodError, NameError => e
      if match_data=method_id.to_s.match(reflected_children_regex)
        association_name=self.respond_to?(match_data[1]) ? match_data[1] : "#{self.class.name.underscore}_#{match_data[1]}"
        begin
          if association=send(association_name)
            association.send(match_data[2], *args, &block)
          else
            match_data[2][0..2] == 'is_' ? match_data[2][3..6] == 'not_' : nil
          end
        rescue Exception
          raise e
        end
      else
        raise
      end
    end
  end
end