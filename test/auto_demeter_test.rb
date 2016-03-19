require 'rubygems'
if RUBY_VERSION >= '1.9'
  require 'minitest/autorun'
  require 'active_record'
else
  require 'test/unit'
  require 'activerecord'
end

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../lib/auto_demeter'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.references :manager
      t.string :name
    end
    create_table :addresses do |t|
      t.references :user
      t.string :postcode
    end
    create_table :managers do |t|
      t.string :name
    end
  end
end

class Manager < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
  belongs_to :manager
  has_one :address
end

class Address < ActiveRecord::Base
  belongs_to :user
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class AutoDemeterTest < (
begin
  MiniTest::Test rescue Test::Unit::TestCase
end)

  def setup
    setup_db
    @paul=Manager.create(:name => 'paul')
    User.create(:name => 'ophelia')
    User.create(:name => 'nigel')
    @michael=User.create(:name => 'michael', :manager => @paul)
    @luke=User.create(:name => 'luke', :manager => @paul)
    @michael_address=Address.create(:postcode => 'n111n', :user => @michael)
    @luke_address=Address.create(:postcode => 'bt401uu', :user => @luke)
    Address.create(:postcode => 'gu261aa')
  end

  def test_happy_path
    assert @luke.respond_to?(:address_postcode)
    assert @luke_address.respond_to?(:user_manager_name)
    assert_equal @luke.address_postcode, @luke_address.postcode
    assert_equal [@michael_address.postcode, @luke_address.postcode], @paul.users.map(&:address_postcode)
    assert_equal @luke.name, @luke_address.user_name
    assert_equal @paul.name, @luke_address.user_manager_name
    assert_equal @paul.name, @luke_address.user_manager.name
    assert_equal @paul.name, @luke_address.user.manager_name
  end
end
