
require 'thecore'
require 'net/ftp'
require 'thecore_servers'
require "thecore_ftp_helpers/engine"

module ThecoreFtpHelpers
  class Methods
    # Your code goes here...
    def self.list_most_recent_file address, username, password, directory, pattern, close = true
      ftp = Net::FTP.open address, username, password
      ftp.chdir(directory)
      files = ftp.nlst(pattern)
      most_recent = files.sort_by{|f| ftp.mtime(f)}.last
      ftp.close if close
      [most_recent, ftp]
    end

    # If destination is nil, the file will just be downloaded to RAM
    def self.download_most_recent_file address, username, password, directory, pattern, destination = nil
      most_recent, ftp = list_most_recent_file address, username, password, directory, pattern, false
      file_content = ftp.gettextfile(most_recent, destination) unless most_recent.nil?
      ftp.close
      file_content
    end

    # ThecoreFtpHelpers::Methods.get_and_parse_most_recent_file '31.196.71.18', 'ideabagno', 'idea2017', 'FTP', 'AQUA*', /^[-;]+$/
    def self.get_and_parse_most_recent_file address, username, password, directory, pattern, skip_lines = nil, quote_char = "\x0C", col_sep = ";"
      file_content = download_most_recent_file address, username, password, directory, pattern
      # , converters: lambda { |h| h.titlecase.strip unless h.nil? }, header_converters: lambda { |h| h.downcase.strip.gsub(' ', '_') unless h.nil? }
      CSV.parse(file_content, col_sep: col_sep, headers: true, skip_blanks: true, force_quotes: true, quote_char: quote_char, skip_lines: skip_lines, converters: lambda { |h| h.titlecase.strip unless h.nil? }, header_converters: lambda { |h| h.downcase.strip.gsub(' ', '_') unless h.nil? }) unless file_content.blank?
    end
  end
end
