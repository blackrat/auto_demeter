# AutoDemeter

AutoDemeter is an automated delegator to associations. The name comes from the rule of demeter is a mechanism to try to
prevent the bad things that happen when that rule is violated.

It's a little like the new &. (praying dot), but also works with older versions
of Ruby.

It was created after spending hours refactoring lots of ancient code that reached through models and associations with little
regard for the fact that there could be a nil somewhere which would make the whole thing blow up and the fact that I hated
the alternative of checking nil manually at every point whilst on the route to refactoring properly.



## Installation

Add this line to your application's Gemfile:

    gem 'auto_demeter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install auto_demeter

## Usage

You can replace things like:

    @object.user.manager.name

with

    @object.user_manager_name

and rather than blowing up when user or manager return nil, the method itself will return nil.

It also let's you do things like:

    @object.users.map(&:manager_name)

without having to define manager_name on the association.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Todo

1. Tests
2. More tests around the is and is_not mechanism
3. Potentially deprecate the is and is_not mechanism which should really be handled in a different gem.