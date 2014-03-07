#!ruby
require 'oj'

class Serializer
  def self.serialize v
    raise 'no root rule defined' unless @class
    # return anything the walk method returns
    root = @class.new.walk(v, &@block)
  end
  def self.hash &block
    @class = Hash
    @block = block
  end
  
  class Hash < ::Hash
    def walk v, &block
      unless block
        # check if the leaf is convertible to hash
        v.respond_to? :to_h or
          raise 'leaf is not convertible to hash (does not respond to :to_h), supply a block with appropriate rules'
        # just return the hash representation of the leaf
        return v.to_h
      end
      
      @v = v
      instance_exec(v, &block)
      self
    end
    def attr name
      self[name] = @v.send(name)
    end
  end
end

Person = Struct.new(:name, :age)

class JustAHash < Serializer
  hash
end
puts Oj.dump(JustAHash.serialize(Person.new('John', 20))) == '{":name":"John",":age":20}'
puts Oj.dump(JustAHash.serialize(Person.new('John', 20))) == '{":name":"John",":age":20}'


class HashWithAttrs < Serializer
  hash do
    attr :age
    attr :name
  end
end
puts Oj.dump(HashWithAttrs.serialize(Person.new('John', 20))) == '{":age":20,":name":"John"}'