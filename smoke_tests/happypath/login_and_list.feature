Feature: Downloader Login and List Happy Path
  Background:
    Given I show my environment
    When I visit "/abc123"
    Then I should see "You need to Login"
    Given I click the "Login" link
    Then I should see "You need to sign in"
    And I fill in my login details
    And I click the "Sign in" button

  @happy_path
  Scenario: List
    Then I should see "Appeal or application documents"
    And I should see "Documents"

  @happy_path
  Scenario: Logout
    Given I click the "Logout" link
    Then I should see "Please log in from the specific case page."
