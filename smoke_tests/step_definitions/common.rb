# See `dropzone_helpers.rb` for the step relating to checkboxes and a comment
# explaining why that step is there.

Given(/^I show my environment$/) do
  puts "Running against: #{ENV.fetch('DOWNLOADER_URI')}"
end

When(/^I visit "(.*?)"$/) do |path|
  visit path
end

Then(/^I should be on "([^"]*)"$/) do |page_name|
  expect("#{Capybara.app_host}#{URI.parse(current_url).path}").to eql("#{Capybara.app_host}#{page_name}")
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page).to have_text(text)
end

Then(/^I should not see "(.*?)"$/) do |text|
  expect(page).not_to have_text(text)
end

When(/^I click the "(.*?)" link$/) do |text|
  click_link(text)
end

When(/^I click the "(.*?)" button$/) do |text|
  find("input[value='#{text}']").click
rescue Capybara::Poltergeist::MouseEventFailed
  find("input[value='#{text}']").trigger('click')
end

Given(/^I fill in my login details$/) do
  fill_in('Email', with: ENV.fetch('SMOKETEST_USER'))
  fill_in('Password', with: ENV.fetch('SMOKETEST_PASSWORD'))
end

When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in(field, with: value)
end
