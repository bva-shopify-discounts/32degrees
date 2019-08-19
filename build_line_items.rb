# BUILD LINE ITEMS SCRIPT

# This script outputs a file with all line_items files merged in the correct order. 
# Shopify requires a single script for each section of checkout: line items, shipping, payment.
# Run this file whenever changes are made to line_items files to get a new script to paste into the Shopify admin.

# To run:
# As long as you have ruby installed, from this directory run this file.
# ruby build_line_items.rb

OUTPUT_FILE_PATH = 'line_items_discount_script.rb'

# Headings that divide up the output file and make it more readable
SHARED_HEADER = "\n########## SHARED FUNCTIONS AND CLASSES ##########\n"
CAMPAIGNS_HEADER = "\n########## CAMPAIGN CLASSES ##########\n"
RUN_HEADER = "\n########## INITIALIZE AND RUN CAMPAIGNS ##########\n"

# Add directories to concatenate files into main discount script. 
# Order of this array defines the order they will appear in the master file.
directory_paths = ['shared', 'campaigns', 'run'].map do |relative_path|
  relative_path.include?('shared') ? relative_path + '/' : 'line_items/' + relative_path + '/'
end

# Remove old version and create new.
File.delete(OUTPUT_FILE_PATH) if File.exist?(OUTPUT_FILE_PATH)
File.open(OUTPUT_FILE_PATH,'a') do |output_file|
  directory_paths.each do |path|
    puts "Directory: #{path}"
    output_file << SHARED_HEADER if path.include? 'shared'
    output_file << CAMPAIGNS_HEADER if path.include? 'campaigns'
    output_file << RUN_HEADER if path.include? 'execute'

    # open each file in current directory and write it to the master build script
    Dir.foreach(path) do |file|
      next if file == '.' || file == '..'
      puts "Loading: #{file}"
      text = File.open(path + file, 'r').read
      text.each_line do |line|
        # do not include commented lines. character limit in shopify script editor. 
        # you will hit it surprisingly quickly without doing this. 
        next if line[0] == '#'
        # chomp + newline to standardize newlines and in case End Of File has no newline
        output_file << line.chomp + "\n"
      end
      output_file << "\n"
      output_file << "# End of #{file} \n"
      output_file << "\n"
    end
  end
end
# closes the file at end of block.
