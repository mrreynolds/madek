Given /^personas are loaded$/ do
  puts "We'll just have to trust that the personas are loaded..."
  # MediaResource.count.zero?.should be_true

  # Persona.create("Adam") # Admin should be created first, he setting up the application
  # Persona.create("Normin")
  # Persona.create("Petra")
  # Persona.create("Beat")
  # Persona.create("Liselotte")
  # Persona.create("Norbert")

  # MediaResource.count.zero?.should be_false
end

Given /^I am "(\w+)"$/ do |persona_name|
  step 'I log in as "%s" with password "password"' % persona_name.downcase
  step 'I am logged in as "%s"' % persona_name.downcase
end
