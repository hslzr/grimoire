namespace :all_cards do
  desc "Split all cards into individual [LANG] files"
  task split: :environment do
    puts ".: Fetching all_cards_* file"
    all_cards_file = ScryfallDataDir.instance.all_cards_latest
    return if all_cards_file.nil?

    puts ".: Counting objects"
    line_count = `wc -l scryfall_data/#{all_cards_file}`.strip.split(" ")[0].to_i
    puts ".: Found #{line_count} objects"

    puts ".: Splitting into individual files"

    languages = Set.new
    lang_files = Set.new

    progressbar = ProgressBar.create(
      title: "Splitting",
      total: line_count,
      format: "%t: |%B| %c/%C %a"
    )

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

      progressbar.increment
    end

    lang_files.each do |lang_file|
      text = File.read(lang_file)
      File.write(lang_file, text[0..-3] + "\n")

      File.open(lang_file, "a") do |f|
        f.puts "]"
      end
    end

    puts "\n.: Done"
  end
end
