Feature: UI
  As a user, when I ask for help, I should be presented
  with instructions on how to run the app.

  Scenario: Display general help instructions
    When I get help for "srd"
    Then the exit status should be 0

  Scenario: Display help instructions for srd exec
  When I get help for "srd exec"
  Then the exit status should be 0