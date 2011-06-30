class PT::DataRow

  attr_accessor :num, :record

  def initialize(orig, dataset)
    @record = orig
    @num = dataset.index(orig) + 1
  end

  def method_missing(method)
    @record.send method
  end

  def to_s
    @record.send(self.to_s_attribute)
  end

  def to_s_attribute
    @n.to_s
  end

end