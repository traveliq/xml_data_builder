require 'builder'
require 'active_support/inflector'
class XmlDataBuilder

  class CDATA < String

    def initialize(template = nil)
      super(template.to_s)
    end

  end
  
  def initialize(data, options = {})
    @data, @options = data, options
  end

  def document
    indent = @options[:indent] || 2
    output = String.new
    xml = Builder::XmlMarkup.new(:target => output, :indent => indent)
    xml.instruct!
    to_xml(xml, @data)
    return output
  end

  private

  def to_xml(parent, data)
    raise ArgumentError, "Expected a Hash, got #{data.inspect}" unless data.is_a? Hash
    data.each do |key, value|
      case value
      when Hash
        parent.__send__(key.to_sym) do |child|
          to_xml(child, value)
        end
      when Array
        parent.__send__(key.to_sym) do
          value.each do |single_value|
            case single_value
            when Hash
              parent.__send__(key.to_s.singularize.to_sym) do |child|
                to_xml(child, single_value)
              end
            else
              raise ArgumentError, "Unable to handle nested arrays" if single_value.is_a? Array
              parent.__send__(key.to_s.singularize.to_sym, single_value)
            end
          end
        end
      when CDATA
        parent.__send__(key.to_sym) do |child|
          parent.cdata! value
        end         
      when Symbol
        parent.__send__(key.to_s.to_sym, value.to_s)
      else
        parent.__send__(key.to_s.to_sym, value)
      end  
    end
  end
end