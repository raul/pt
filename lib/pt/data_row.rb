require 'iconv' unless "older_ruby?".respond_to?(:force_encoding)

class PT::DataRow

  attr_accessor :num, :record, :state

  def initialize(orig, dataset)
    @record = orig
    @num = dataset.index(orig) + 1
    @state = orig.current_state
  end

  def method_missing(method)
    str = @record.send(method).to_s
    str.respond_to?(:force_encoding) ? str.force_encoding('utf-8') : Iconv.iconv('UTF-8', 'UTF-8', str)
  end

  def to_s
    @record.send(self.to_s_attribute)
  end

  def to_s_attribute
    @n.to_s
  end

end
