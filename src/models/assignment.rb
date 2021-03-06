class Assignment
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime
  property :updated_at, DateTime
  property :active, Boolean, default: true
  property :year, Integer, default: DateTime.now.year, writer: :private

  property :title, String, length: 255
  property :brief, Text
  property :draft, Boolean, default: true
  property :published_at, DateTime
  property :everyone, Boolean, default: false

  property :user_id, Integer
  belongs_to :user

  has n, :posts
  has n, :sections, through: Resource

  attr_accessor :section_ids

  before :save do
    publish
    add_sections
  end

  #############################################################################
  #
  # CLASS METHODS
  #
  #############################################################################

  # Public: Return all active resources marked as drafts, sorted in reverse
  # chronological order by updated_at.
  #
  # Returns a DataMapper Collection.
  def self.drafts
    all(draft: true, active: true, order: :updated_at.desc)
  end

  # Public: Return all active resources marked as published, sorted in reverse
  # chronological order by published time.
  #
  # Returns a DataMapper Collection.
  def self.published
    all(draft: false, active: true, order: :published_at.desc)
  end

  #############################################################################
  #
  # INSTANCE METHODS
  #
  #############################################################################

  # Public: Instead of removing a model from the DB, mark it as inactive. This
  # is to make deletions recoverable and make it unnecessary to detach all
  # associations before deletion.
  #
  # Returns the result of the update call.
  def delete
    self.update(active: false)
  end

  # Public: Returns a string representing the path to this resource.
  #
  # Returns a string.
  def url
    "/assignments/#{self.year}/#{self.id}"
  end

  private

  # Private: Look at sections_id attr_accessor and everyone, as well as
  # sections to either add or remove sections.
  def add_sections
    # If no section_ids were given a set `everyone` to true.
    if self.section_ids.nil?
      self.everyone = true
    else
      self.everyone = false

      self.section_ids.each do |section_id|
        next if !self.sections.get(section_id).nil?
        self.sections.push Section.first(id: section_id.to_i)
      end
    end

    # If `everyone` is true, add all of the sections that aren't already
    # associated.s
    if self.everyone == true
      all_sections = Section.all(year: Date.today.year)
      all_sections.each do |s|
        next if self.sections.include?(s)

        self.sections << s
      end
      return
    end
  end

  # Private: Sets published date if resource is saved with draft==false. Will
  # only set the publish date on the first save unless resource is unpublished.
  # If a resource is a draft, unset published_at.
  def publish
    if self.draft == false && self.published_at.nil?
      self.published_at = DateTime.now
    else
      self.published_at = nil
    end
  end
end