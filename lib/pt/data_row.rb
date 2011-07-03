require 'iconv'

class PT::DataRow

  attr_accessor :num, :record

  def initialize(orig, dataset)
    @record = orig
    @num = dataset.index(orig) + 1
  end

  def method_missing(method)
    str = @record.send(method).to_s
    str.respond_to?(:force_encoding) ? str.force_encoding('utf-8') : Iconv.iconv('UTF8', 'UTF8', str)
  end

  def to_s
    @record.send(self.to_s_attribute)
  end

  def to_s_attribute
    @n.to_s
  end

end