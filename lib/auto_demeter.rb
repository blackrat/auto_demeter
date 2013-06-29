require "auto_demeter/version"
require 'auto_demeter/methods'

class ActiveRecord::Base
  include AutoDemeter
end

class ActiveRecord::Associations::BelongsToAssociation
  include AutoDemeter
end

class ActiveRecord::Associations::HasOneAssociation
  include AutoDemeter
end
