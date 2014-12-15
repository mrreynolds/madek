# app/helpers/application_helper.rb

module ApplicationHelper
  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def semver
    # TODO: fix
    MadekSemver.semver
  end

  def zhdk_login?
    Settings.zhdk_integration
  end

  # layout render shortcut
  def partial(name, config = nil, &block)
    if block_given?
      render layout: name, locals: config, &block
    else
      render layout: name, locals: config
    end
  end

end
