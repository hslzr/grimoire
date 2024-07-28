class ScryfallDataDir
  include Singleton

  def initialize
    super
    @data_dir = Dir.open(Rails.root.join("scryfall_data"))
  end

  def all_cards_files
    @all_cards_files ||= @data_dir.children
      .select { |f| f.match?(/\Aall-cards-\d+.*\.json/) }
      .sort
  end

  def all_cards_latest
    all_cards_files.last
  end
end
