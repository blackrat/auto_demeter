require (File.join(File.dirname(__FILE__), 'auto_demeter', 'version'))
require (File.join(File.dirname(__FILE__), 'auto_demeter', 'methods'))
ActiveRecord::Base.send :include, AutoDemeter
ActiveRecord::Associations::BelongsToAssociation.send :include, AutoDemeter
ActiveRecord::Associations::HasOneAssociation.send :include, AutoDemeter
