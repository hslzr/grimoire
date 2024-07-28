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
          File.open(current_lang_file, "w") do |f|
            f.puts "["
          end
        end
        File.open(current_lang_file, "a") do |f|
          f.puts clean_line + ","
        end

        progressbar.advance
      end

      lang_files.each do |lang_file|
        text = File.read(lang_file)
        File.write(lang_file, text[0..-3] + "\n")

        File.open(lang_file, "a") do |f|
          f.puts "]"
        end
      end
    ensure
      progressbar.finish
    end

    logger.success("Done")
  end
end
