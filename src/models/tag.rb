class Tag
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :modified_at, DateTime

  property :name, String, length: 64
  property :year, Integer

  has n, :theses, through: Resource

  def self.current_year
    all(:year => ENV['CURRENT_YEAR'].to_i(10), order: :name.asc)
  end
end
