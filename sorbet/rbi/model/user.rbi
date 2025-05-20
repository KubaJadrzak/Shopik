# typed: strict

module Devise
  extend T::Sig

  module ClassMethods
    extend T::Sig

    sig do
      params(
        modules: Symbol,
        options: T::Hash[Symbol, T.untyped]
      ).void
    end
    def devise(*modules, **options); end
  end
end

class ActiveRecord::Base
  extend T::Sig
  extend Devise::ClassMethods
end