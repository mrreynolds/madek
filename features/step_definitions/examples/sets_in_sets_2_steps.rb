# coding: UTF-8

Given /^a few sets$/ do
  MediaSet.count.should > 0
end

When /^a set has no parents$/ do
  @top_level_set = MediaSet.all.detect {|x| x.parent_sets.empty? }
end

Then /^it is a top\-level set$/ do
  MediaSet.top_level.include?(@top_level_set)
end

When /^I view a grid of these sets$/ do
  visit media_resources_path()
end

When /^I examine my "([^"]*)" sets more closely$/ do |title|
  wait_for_css_element('.thumb_box')
  @media_set = MediaSet.find_by_title title
  page.execute_script "$(\"dd[title='#{title}']\").closest(\".item_box\").find(\".thumb_box_set\").trigger(\"mouseenter\")"
  wait_for_css_element('.set_popup')
end

Then /^I see relationships for this set$/ do
  @displayed_parent_sets = all(".set_popup .parents .resource")
  @display_child_entries = all(".set_popup .children .resource.media_entry")
  @display_child_sets = all(".set_popup .children .resource.media_set")
end

Then /^I see how many media entries that are viewable for me in this set$/ do
  find(".set_popup .children .text", :text => "#{(@media_set.media_entries.size-@display_child_entries.size)} weitere Medieneinträge")
end

Then /^I see how many sets that are viewable for me in this set$/ do
  find(".set_popup .children .text", :text => "#{(@media_set.child_sets.size-@display_child_sets.size)} weitere Sets")
end

Then /^I see how many sets that are viewable for me are parents of this set$/ do
  find(".set_popup .parents .text", :text => "#{(@media_set.parent_sets.size-@displayed_parent_sets.size)} weitere Sets")
end

Given /^a set called "([^"]*)" that has the context "([^"]*)"$/ do |set_title, context_name|
  step 'the set "%s" has the context "%s"' % [set_title, context_name]
end

Given /^the set called "([^"]*)" is child of "([^"]*)" and "([^"]*)"$/ do |set_title, parent_set_title_1, parent_set_title_2|
  @set = MediaSet.find_by_title(set_title)
  
  @parent_set_1 = MediaSet.find_by_title(parent_set_title_1)
  @parent_set_1.child_sets.include?(@set).should be_true
  
  @parent_set_2 = MediaSet.find_by_title(parent_set_title_2)
  @parent_set_2.child_sets.include?(@set).should be_true
end

Given /^I can edit the set "([^"]*)"$/ do |set_title|
  @set = MediaSet.find_by_title(set_title)
  @current_user.authorized?(:edit, @set).should be_true
end

When /^I view the set "([^"]*)"$/ do |set_title|
  @set = MediaSet.find_by_title(set_title)
  visit media_resource_path(@set)
  step 'I should see "Set enthält"'
  step 'I should see "%s"' % @set.title
end

Then /^I see the available contexts "([^"]*)" and "([^"]*)"$/ do |title1, title2|
  step 'I follow "Kontexte"'
  step 'I should see "Diesem Set sind zusätzliche Kontexte mit Metadaten zugewiesen."'
  step 'I should see "%s"' % title1
  step 'I should see "%s"' % title2
end

Then /^I see some text explaining the consequences of assigning contexts to a set$/ do
  step 'I should see "So können für alle Medieneinträge, die in diesem Set enthalten sind, weitere inhaltliche Angaben gemacht werden. Darüber hinaus können alle Sets, die diesem Set zugewiesen werden, ebenfalls die ausgewählten zusätzlichen Kontexte erhalten."'
end

When /^I assign the context "([^"]*)" to the set "([^"]*)"$/ do |context_name, set_title|
  context_label = MetaContext.send(context_name).to_s
  
  step 'I follow "Kontexte"'
  wait_for_css_element('#contexts_tab input[@type="submit"]')
  find(:xpath, '//strong[contains(., "%s")]' % context_label).click 
  find('#contexts_tab input[@type="submit"]').click
end

Then /^I can choose to see more details about the context "([^"]*)"$/ do |context_name|
  context_label = MetaContext.send(context_name).to_s
  
  step 'I follow "Kontexte"'
  wait_for_css_element('#contexts_tab input[@type="submit"]')
  find(:xpath, "//strong[contains(., '#{context_label}')]/../../a")
end

Then /^the set "([^"]*)" has the context "([^"]*)"$/ do |set_title, context_name|
  @set = MediaSet.find_by_title(set_title)
  @set.title.should == set_title

  context = MetaContext.where(:name => context_name).first
  @set.individual_contexts.include?(context).should be_true 
end

Then /^the set still has the context called "([^"]*)"$/ do |context_name|
  step 'the set "%s" has the context "%s"' % [@set.title, context_name]
end

Then /^I see previews of the resources that are children of this set$/ do
  @display_child_entries.each do |child|
    child.find("img")["src"].should_not == "undefined"
    child.find("img")["src"].should_not be_nil
  end
end

Then /^I see previews of the resources that are parent of this set$/ do
  @displayed_parent_sets.each do |parent|
    parent.find("img")["src"].should_not == "undefined"
    parent.find("img")["src"].should_not be_nil
  end
end

When /^I hover those previews of children I see the title of those resources$/ do
  @display_child_entries.each do |child|
    child["title"].should_not == "undefined"
    child["title"].should_not be_nil
  end
end

When /^I hover those previews of parents I see the title of those resources$/ do
  @displayed_parent_sets.each do |parent|
    parent["title"].should_not == "undefined"
    parent["title"].should_not be_nil
  end
end

Given /^I open a set which has child media entries$/ do
  @set = MediaResource.accessible_by_user(@current_user).detect{|resource| resource.media_entries.accessible_by_user(@current_user).count > 0}
  visit media_set_path(@set)
end

Given /^I switch the list of the childs to the miniature view$/ do
  find("#bar .layout .icon[data-type='miniature']").click
end

Given /^I examine one of the child media entry more closely$/ do
  page.execute_script('$(".thumb_box").trigger("mouseenter")')
end

Then /^I see more informations about that media entry poping up$/ do
  find(".entry_popup")
end