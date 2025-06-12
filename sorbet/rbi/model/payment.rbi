# typed: strict

class Payment < ApplicationRecord

  sig { returns(T.untyped) }
  def payable; end
  
  sig { params(value: T.untyped).void }
  def payable=(value); end
end