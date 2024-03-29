module AutoDemeter
  private
  def base_names
    @base_names||=self.class.reflect_on_all_associations.find_all { |x| [:has_one, :belongs_to].include?(x.send(:macro)) }.map { |x| x.send(:name).to_s } rescue []
  end

  def children_names
    if @children_names.nil?
      class_name=base_names.map { |x| x.gsub(/^#{self.class.name.underscore}_/, '') }
      class_name=class_name | base_names.map { |x| x.gsub(/^#{self.base_name.underscore}_/, '') } if self.respond_to?(:base_name) && self.class.name!=self.base_name
      @children_names=base_names | class_name
    end
    @children_names
  end

  def reflected_children_regex
    Regexp.new('^(' << children_names.join('|') << ')_(.*[^=])$')
  end

  public
  def respond_through_association?(method_id)
    if children_names && (match_data=method_id.to_s.match(reflected_children_regex)) && match_data[1].present?
      association_name=(self.methods.include?(match_data[1].intern) || self.methods.include?(match_data[1])) ? match_data[1] : "#{self.class.name.underscore}_#{match_data[1]}"
      begin
        if association=send(association_name)
          association.respond_to?(match_data[2])
        elsif association.nil?
          association_name.camelize.constantize.new.respond_to?(match_data[2])
        end
      rescue
        false
      end
    else
      false
    end
  end

  def respond_to?(method_id, public=false)
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
            nil
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