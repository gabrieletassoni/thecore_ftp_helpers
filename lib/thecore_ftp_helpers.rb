
require 'thecore'
require 'net/ftp'
require 'thecore_servers'
require "thecore_ftp_helpers/engine"

module ThecoreFtpHelpers
  class Methods
    # Your code goes here...
    def self.list_most_recent_file address, username, password, directory, pattern, close = true, from = nil
      puts "Connecting to FTP"
      ftp = Net::FTP.open address, username, password
      # ftp.passive = false
      puts "Entering directory: #{directory}"
      ftp.chdir(directory)
      puts "Listing all files which respond to this pattern: #{pattern}"
      begin
        files = ftp.nlst(pattern)
      rescue => exception
        # If we are here, maybe it's beacause of passive mode and the network too secure
        # let's switch to active mode and try again
        ftp.passive = false
        files = ftp.nlst(pattern)
      end
      
      puts "Last import time: #{from.strftime('%Y-%m-%d %H:%M:%S.%N')}"
      files = files.select {|f|
        puts "For file: #{f}"
        puts "Filetime: #{ftp.mtime(f).strftime('%Y-%m-%d %H:%M:%S.%N')}"
        puts "File chosen? #{ftp.mtime(f).to_f > from.to_f}"
        ftp.mtime(f).to_f > from.to_f
      } unless from.blank?
      puts "Chosen files: #{files.inspect}"
      most_recent = files.sort_by{|f| ftp.mtime(f).to_f}.last
      puts "Opening File: #{most_recent || "No file has been chosen."}"
      ftp.close if close
      [most_recent, ftp]
    end

    # If destination is nil, the file will just be downloaded to RAM
    def self.download_most_recent_file address, username, password, directory, pattern, destination = nil, from = nil
      most_recent, ftp = list_most_recent_file address, username, password, directory, pattern, false, from
      file_content = ftp.gettextfile(most_recent, destination).force_encoding('ISO-8859-1').encode('UTF-8') unless most_recent.nil?

      #.encode!('UTF-8', 'binary', :invalid => :replace) unless most_recent.nil?
      ftp.close
      file_content
    end

    # ThecoreFtpHelpers::Methods.get_and_parse_most_recent_file '31.196.71.18', 'ideabagno', 'idea2017', 'FTP', 'AQUA*', /^[-;]+$/
    def self.get_and_parse_most_recent_file address, username, password, directory, pattern, skip_lines = nil, quote_char = "\x0C", col_sep = ";", from = nil
      file_content = download_most_recent_file address, username, password, directory, pattern, nil, from
      # , converters: lambda { |h| h.titlecase.strip unless h.nil? }, header_converters: lambda { |h| h.downcase.strip.gsub(' ', '_') unless h.nil? }
      CSV.parse(file_content, col_sep: col_sep, headers: true, skip_blanks: true, force_quotes: true, quote_char: quote_char, skip_lines: skip_lines, converters: lambda { |h| h.titlecase.strip.gsub(",", " ").split.join(" ") unless h.nil? }, header_converters: lambda { |h| h.downcase.strip.gsub(' ', '_').split("_").reject{|c| c.blank? }.uniq.join("_") unless h.nil? }) unless file_content.blank?
    end
  end
end
