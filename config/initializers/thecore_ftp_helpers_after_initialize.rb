
Rails.application.configure do
  config.after_initialize do
    require 'abilities_thecore_ftp_helpers_concern'
  end
end
