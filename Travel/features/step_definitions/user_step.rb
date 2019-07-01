Given("no user exists with an email of {string}") do |string|
    User.find_by_email(string).should be_nil
end

Given("An user is signed up and confirmed as {string}, {string}, {string}, {string}, {string}") do |email, password, name, surname, nickname|
    User.create(email: email, password: password, password_confirmation: password, name: name, surname: surname, nickname: nickname)
    click_button "Sign up"
end

Given("A registered user as {string}, {string}") do |email, password|
    User.create(email: email, password: password, password_confirmation: password)
    visit new_user_session_path
    fill_in 'user_email', :with => email
    fill_in 'user_password', :with => password
    click_button 'Log in'
end

When("An user go to the {string} page") do |page|
    visit page
end

When("The user sign in as {string}, {string}") do |email, password|
    fill_in 'user_email', :with => email
    fill_in 'user_password', :with => password
    click_button 'Log in'
end


Then("The user should be to redirect to {string}") do |page|
    expect(current_path).to eql page
end

When("An user click the {string} button") do |button|
    click_button button
end
  
