module Alijigock
  def self.store
    store = "Alijigock::Stores::#{(ENV['STORE'] || 'File').capitalize}".constantize.new
    yield(store) if block_given?
    store
  end

  def self.session_id
    @session_id
  end

  def self.session_id=(n)
    @session_id = n
  end
end
