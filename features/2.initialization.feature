Feature: Initialization
  As a user, when I initialize Sifttter Redux,
  I should be guided through the process as
  necessary.

  Scenario: Basic Initialization
    Given no file located at "/tmp/srd/.sifttter_redux"
      And an empty file located at "/tmp/srd/.dropbox_uploader"
    When I run `srd init` interactively
      And I type "/tmp"
      And I type "/tmp/srd/sifttter_download"
      And I type "/Apps/Sifttter"
      And I type "/tmp/srd/sifttter_known"
      And I type "http://known.example.com"
      And I type "example"
      And I type "apikey"
      And I type ""
    Then the exit status should be 0
      And the file "/tmp/srd/.sifttter_redux" should contain:
    """
    ---
    sifttter_redux:
      config_location: "/tmp/srd/.sifttter_redux"
      log_level: WARN
      version: '1.0'
    """
      And the file "/tmp/srd/.sifttter_redux" should contain:
      """
        sifttter_local_filepath: "/tmp/srd/sifttter_download"
        sifttter_remote_filepath: "/Apps/Sifttter"
        local_filepath: "/tmp/srd/sifttter_known"
      db_uploader:
        base_filepath: "/tmp"
        dbu_filepath: "/tmp/Dropbox-Uploader"
        exe_filepath: "/tmp/Dropbox-Uploader/dropbox_uploader.sh"
      """
      And the file "/tmp/srd/.sifttter_redux" should contain:
      """
      known:
        site_url: http://known.example.com
        username: example
        api_key: apikey
        visibility: member
      """

  Scenario: Reinitialization (refuse)
    Given a file located at "/tmp/srd/.sifttter_redux" with the contents:
    """
    ---
    sifttter_redux:
      config_location: "/tmp/srd/.sifttter_redux"
      log_level: WARN
      version: '1.0'
      sifttter_local_filepath: "/tmp/srd/sifttter_download"
      sifttter_remote_filepath: "/Apps/Sifttter"
    db_uploader:
      base_filepath: "/tmp"
      dbu_filepath: "/tmp/Dropbox-Uploader"
      exe_filepath: "/tmp/Dropbox-Uploader/dropbox_uploader.sh"
    """
      And an empty file located at "/tmp/srd/.dropbox_uploader"
    When I run `srd init` interactively
      And I type ""
    Then the exit status should be 0

  Scenario: Reinitialization (accept)
    Given a file located at "/tmp/srd/.sifttter_redux" with the contents:
    """
    ---
    sifttter_redux:
      config_location: "/tmp/srd/.sifttter_redux"
      log_level: WARN
      version: '1.0'
      sifttter_local_filepath: "/tmp/srd/sifttter_download"
      sifttter_remote_filepath: "/Apps/Sifttter"
      local_filepath: "/tmp/srd/sifttter_known"
    db_uploader:
      base_filepath: "/tmp"
      dbu_filepath: "/tmp/Dropbox-Uploader"
      exe_filepath: "/tmp/Dropbox-Uploader/dropbox_uploader.sh"
    known:
      site_url: http://known.example.com
      username: example
      api_key: apikey
      visibility: member
    """
      And an empty file located at "/tmp/srd/.dropbox_uploader"
    When I run `srd init` interactively
      And I type "y"
      And I type "/tmp/srd"
      And I type "/tmp/srd/sifttter_download"
      And I type "/Apps/Sifttter"
      And I type "/tmp/srd/sifttter_known"
      And I type "http://known.example.com"
      And I type "example"
      And I type "apikey"
      And I type "member"
    Then the exit status should be 0
      And the file "/tmp/srd/.sifttter_redux" should contain:
    """
    ---
    sifttter_redux:
      config_location: "/tmp/srd/.sifttter_redux"
      log_level: WARN
      version: '1.0'
    """
      And the file "/tmp/srd/.sifttter_redux" should contain:
      """
        sifttter_local_filepath: "/tmp/srd/sifttter_download"
        sifttter_remote_filepath: "/Apps/Sifttter"
        local_filepath: "/tmp/srd/sifttter_known"
      db_uploader:
        base_filepath: "/tmp"
        dbu_filepath: "/tmp/Dropbox-Uploader"
        exe_filepath: "/tmp/Dropbox-Uploader/dropbox_uploader.sh"
      """
     And the file "/tmp/srd/.sifttter_redux" should contain:
      """
      known:
        site_url: http://known.example.com
        username: example
        api_key: apikey
        visibility: member
      """

  Scenario: Reinitialization (from scratch)
    Given no file located at "/tmp/srd/.sifttter_redux"
      And an empty file located at "/tmp/srd/.dropbox_uploader"
    When I run `srd init -s` interactively
      And I type ""
      And I type "/tmp/srd/sifttter_download"
      And I type "/Apps/ifttt/Sifttter"
      And I type "/tmp/srd/day_one_download"
      And I type "/Apps/Day\ One/Journal.dayone/entries"
    Then the exit status should be 0
      And the file "/tmp/srd/.sifttter_redux" should contain:
    """
    ---
    sifttter_redux:
      config_location: "/tmp/srd/.sifttter_redux"
      log_level: WARN
    """
      And the file "/tmp/srd/.sifttter_redux" should contain:
      """
        sifttter_local_filepath: "/tmp/srd/sifttter_download"
        sifttter_remote_filepath: "/Apps/ifttt/Sifttter"
        dayone_local_filepath: "/tmp/srd/day_one_download"
        dayone_remote_filepath: "/Apps/Day\\ One/Journal.dayone/entries"
      db_uploader:
        base_filepath: "/usr/local/opt"
        dbu_filepath: "/usr/local/opt/Dropbox-Uploader"
        exe_filepath: "/usr/local/opt/Dropbox-Uploader/dropbox_uploader.sh"
      """
