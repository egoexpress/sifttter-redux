require 'sifttter_redux/cli_message'
require 'sifttter_redux/configuration'
require 'sifttter_redux/date_range_maker'
require 'sifttter_redux/dbu'
require 'sifttter_redux/dropbox_uploader'
require 'sifttter_redux/sifttter'
require 'sifttter_redux/version'

#  ======================================================
#  SifttterRedux Module
#
#  Wrapper module for all other modules in this project
#  ======================================================

module SifttterRedux
  attr_accessor :verbose

  #  ====================================================
  #  Constants
  #  ====================================================
  DBU_CONFIG_FILEPATH = File.join(ENV['HOME'], '.dropbox_uploader')
  DBU_LOCAL_FILEPATH = '/usr/local/opt'

  DO_LOCAL_FILEPATH = '/tmp/dayone'
  DO_REMOTE_FILEPATH = "/Apps/Day\\ One/Journal.dayone/entries"

  SFT_LOCAL_FILEPATH = '/tmp/sifttter'
  SFT_REMOTE_FILEPATH = '/Apps/ifttt/sifttter'

  SRD_CONFIG_FILEPATH = File.join(ENV['HOME'], '.sifttter_redux')
  SRD_LOG_FILEPATH = File.join(ENV['HOME'], '.sifttter_redux_log')

  #  ====================================================
  #  Methods
  #  ====================================================
  #  ----------------------------------------------------
  #  cleanup_temp_files method
  #
  #  Removes temporary directories and their contents
  #  @return Void
  #  ----------------------------------------------------
  def self.cleanup_temp_files
    dirs = [
      Configuration['sifttter_redux']['dayone_local_filepath'],
      Configuration['sifttter_redux']['sifttter_local_filepath']
    ]

    CLIMessage::info_block('Removing temporary local files...') do 
      dirs.each do |d|
        FileUtils.rm_rf(d)
        CLIMessage::debug("Removed directory: #{ d }")
      end
    end
  end
  
  #  ----------------------------------------------------
  #  install_wizard method
  #
  #  Runs a wizard that installs Dropbox Uploader on the
  #  local filesystem.
  #  @return Void
  #  ----------------------------------------------------
  def self.dbu_install_wizard(reinit = false)
    valid_path_chosen = false
    
    CLIMessage::section_block('CONFIGURING DROPBOX UPLOADER...') do
      until valid_path_chosen
        # Prompt the user for a location to save Dropbox Uploader.
        if reinit && !Configuration['db_uploader']['base_filepath'].nil?
          default = Configuration['db_uploader']['base_filepath']
        else
          default = DBU_LOCAL_FILEPATH
        end
        path = CLIMessage::prompt_for_filepath('Location for Dropbox-Uploader', default)
        path = default if path.empty?
        path.chop! if path.end_with?('/')
        
        # If the entered directory exists, clone the repository.
        if File.directory?(path)
          valid_path_chosen = true
          
          dbu_path = File.join(path, 'Dropbox-Uploader')
          executable_path = File.join(dbu_path, 'dropbox_uploader.sh')

          if File.directory?(dbu_path)
            CLIMessage::warning("Using pre-existing Dropbox Uploader at #{ dbu_path }...")
          else
            CLIMessage::info_block("Downloading Dropbox Uploader to #{ dbu_path }...", 'Done.', true) do
              system "git clone https://github.com/andreafabrizi/Dropbox-Uploader.git #{ dbu_path }"
            end
          end

          # If the user has never configured Dropbox Uploader, have them do it here.
          unless File.exists?(DBU_CONFIG_FILEPATH)
            CLIMessage::info_block('Initializing Dropbox Uploader...') { system "#{ executable_path }" }
          end

          Configuration::add_section('db_uploader') unless reinit
          Configuration['db_uploader'].merge!('base_filepath' => path, 'dbu_filepath' => dbu_path, 'exe_filepath' => executable_path)
        else
          CLIMessage::error("Sorry, but #{ path } isn't a valid directory.")
        end
      end
    end
  end

  #  ----------------------------------------------------
  #  get_dates_from_options method
  #
  #  Creates a date range from the supplied command line
  #  options.
  #  @param options A Hash of command line options
  #  @return Range
  #  ----------------------------------------------------
  def self.get_dates_from_options(options)
    CLIMessage::section_block('EXECUTING...') do
      if options[:c] || options[:n] || options[:w] || options[:y] || options[:f] || options[:t]
        # Yesterday
        r = DateRangeMaker.yesterday if options[:y]

        # Current Week
        r = DateRangeMaker.last_n_weeks(0, options[:i]) if options[:c]
        
        # Last N Days
        r = DateRangeMaker.last_n_days(options[:n].to_i, options[:i]) if options[:n]

        # Last N Weeks
        r = DateRangeMaker.last_n_weeks(options[:w].to_i, options[:i]) if options[:w]

        # Custom Range
        if (options[:f] || options[:t])
          _dates = DateRangeMaker.range(options[:f], options[:t], options[:i])

          if _dates.last > Date.today
            long_message = "Ignoring overextended end date and using today's date (#{ Date.today })..."
            CLIMessage::warning(long_message)
            r = (_dates.first..Date.today)
          else
            r = (_dates.first.._dates.last)
          end
        end
      else
        r = DateRangeMaker.today
      end
      
      CLIMessage::debug("Date range: #{ r }")
      r
    end
  end

  #  ----------------------------------------------------
  #  initialize_procedures method
  #
  #  Initializes Sifttter Redux by downloading and
  #  collecting all necessary items and info.
  #  @return Void
  #  ----------------------------------------------------
  def self.init(reinit = false)
    unless reinit
      Configuration::reset
      Configuration::add_section('sifttter_redux')
    end
    Configuration['sifttter_redux'].merge!({
      'config_location' => Configuration::config_path,
      'log_level' => 'WARN',
      'version' => VERSION,
    })

    # Run the wizard to download Dropbox Uploader.
    dbu_install_wizard(reinit = reinit)

    # Collect other misc. preferences.
    CLIMessage::section_block('COLLECTING PREFERENCES...') do
      pref_prompts = [
        {
          prompt: 'Location for downloaded Sifttter files from Dropbox',
          default: SFT_LOCAL_FILEPATH,
          key: 'sifttter_local_filepath',
          section: 'sifttter_redux'
        },
        {
          prompt: 'Location of Sifttter files in Dropbox',
          default: SFT_REMOTE_FILEPATH,
          key: 'sifttter_remote_filepath',
          section: 'sifttter_redux'
        },
        {
          prompt: 'Location for downloaded Day One files from Dropbox',
          default: DO_LOCAL_FILEPATH,
          key: 'dayone_local_filepath',
          section: 'sifttter_redux'
        },
        {
          prompt: 'Location of Day One files in Dropbox',
          default: DO_REMOTE_FILEPATH,
          key: 'dayone_remote_filepath',
          section: 'sifttter_redux'
        }
      ]

      pref_prompts.each do |prompt|
        d = reinit ? Configuration[prompt[:section]][prompt[:key]] : prompt[:default]
        pref = CLIMessage::prompt_for_filepath(prompt[:prompt], d)

        Configuration[prompt[:section]].merge!(prompt[:key] => File.expand_path(pref))
        CLIMessage::debug("Value for #{ prompt[:key] }: #{ pref }")
      end
    end

    CLIMessage::debug("Configuration values: #{ Configuration::dump }")
    Configuration::save
  end
end