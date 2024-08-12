namespace :all_cards do
  desc "Split all cards into individual [LANG] files"
  task split: :environment do
    logger = TTY::Logger.new
    logger.info("Splitting all cards into individual [LANG] files")

    all_cards_file = ScryfallDataDir.instance.all_cards_latest
    if all_cards_file.nil?
      logger.error("No all-cards file found in scryfall_data directory")
      return
    end

    logger.info("Counting objects")
    line_count = `wc -l scryfall_data/#{all_cards_file}`.strip.split(" ")[0].to_i
    logger.info("Found #{line_count} objects")

    logger.info("Splitting into individual files")

    languages = Set.new
    lang_files = Set.new

    progressbar = TTY::ProgressBar.new("Splitting [:bar] :current/:total :percent", total: line_count, hide_cursor: true, clear: true, head: ">", complete: "=")

    begin
      File.foreach("scryfall_data/#{all_cards_file}").with_index do |line, _line_num|
        next if line.match?(/^\[|\]$/) # Skip first and last lines
        clean_line = line.strip
        clean_line = clean_line[0..-2] if clean_line[-1] == "," # Remove trailing comma
        json = JSON.parse(clean_line)
        current_language = json["lang"]

        current_lang_file = "scryfall_data/all-cards-#{current_language}.json"

        unless languages.include?(current_language)
          languages << current_language
          lang_files << current_lang_file
        end
        File.open(current_lang_file, "a") do |f|
          f.puts clean_line
        end

        progressbar.advance
      end
    ensure
      progressbar.finish
    end

    logger.success("Done")
  end

  desc "Import all cards from individual [LANG] files"
  task import: :environment do
    logger = TTY::Logger.new
    logger.info("Importing all cards from individual [LANG] files")

    languages = Set.new
    lang_files = Set.new

    lang_files = Dir["scryfall_data/all-cards-*.json"]
      .select { |f| f.match?(/all-cards-(en|es)\.json/) }
      .sort

    if lang_files.empty?
      logger.error("No all-cards-[LANG].json files found in scryfall_data directory")
      return
    end

    logger.info("Found #{lang_files.size} #{"file".pluralize(lang_files.size)}")

    lang_files.each do |lang_file|
      current_language = lang_file.match(/(en|es)\.json/)[1]
      logger.info("Importing cards for language: #{current_language}")

      import_card_names_from_file(lang_file)
      #import_card_objects_from_file(lang_file)
    end
  end

  def import_card_names_from_file(lang_file)
    logger = TTY::Logger.new
    logger.info("Importing cards from file: #{lang_file}")

    line_count = `wc -l #{lang_file}`.strip.split(" ")[0].to_i - 2

    lang = lang_file.match(/all-cards-(?<name>[a-z]{2})\.json/)[:name]

    progressbar = TTY::ProgressBar.new("Importing card names :elapsed [:bar] :current/:total :percent",
     total: line_count,
     hide_cursor: true,
     clear: true,
     bar_format: :block,
    )

    file_object = File.foreach(lang_file)

    file_object.each_slice(500) do |lines|
      card_names = lines.map do |line|
        json = JSON.parse(line)
        json["scryfall_id"] = json.delete("id")
        json["lang"] = lang
        { name: json["name"], printed_name: json["printed_name"], flavor_name: json["flavor_name"], lang: json["lang"] }
      end
      
      card_name_only = card_names.filter_map do |card_name|
        next unless card_name[:name].present? && card_name[:printed_name].blank? && card_name[:flavor_name].blank?
        { name: card_name[:name], lang: card_name[:lang] }
      end

      created_names = Card::Name.insert_all(card_name_only, unique_by: [:name, :lang], returning: [:id, :name]).rows.to_h { [_2, _1] }

      card_printed_names = card_names.filter_map do |card_name|
        next unless card_name[:printed_name].present? && card_name[:name].present?
        { 
          card_name_id: created_names[card_name[:name]],
          name: card_name[:printed_name],
          lang: card_name[:lang]
        }
      end

      card_flavor_names = card_names.filter_map do |card_name|
        next unless card_name[:flavor_name].present? && card_name[:name].present?
        { 
          card_name_id: created_names[card_name[:name]],
          name: card_name[:flavor_name],
          lang: card_name[:lang]
        }
      end

      Card::PrintedName.insert_all(card_printed_names, unique_by: [:name, :lang])
      Card::FlavorName.insert_all(card_flavor_names, unique_by: [:name, :lang])

      progressbar.advance(card_names.size)
    end

  ensure
    progressbar.finish
    logger.success("Done")
  end

  def import_card_objects_from_file(lang_file)
    logger = TTY::Logger.new
    logger.info("Importing cards from file: #{lang_file}")

    line_count = `wc -l #{lang_file}`.strip.split(" ")[0].to_i - 2

    lang = lang_file.match(/all-cards-(?<name>[a-z]{2})\.json/)[:name]

    progressbar = TTY::ProgressBar.new("Mapping card objects to their names :elapsed [:bar] :current/:total :percent",
     total: line_count,
     hide_cursor: true,
     clear: true,
     bar_format: :block,
    )

    file_object = File.foreach(lang_file)

    file_object.each_slice(300) do |lines|
      card_objects = lines.map do |line|
        json = JSON.parse(line)
        json["scryfall_id"] = json.delete("id")
        json["lang"] = lang
        card_name_id = Card::Name.where(
          name: json["name"],
          printed_name: json["printed_name"],
          flavor_name: json["flavor_name"],
          lang: json["lang"]
        ).pick(:id)
        { card_name_id: card_name_id, raw_data: json }
      end

      Card::Object.insert_all(card_objects)

      progressbar.advance(card_objects.size)
    end

    logger.success("Done")
  rescue ActiveRecord::NotNullViolation => e
    binding.break
  ensure
    progressbar.finish
  end
end
