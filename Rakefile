require 'metadown'
require 'erb'
require 'yaml'
require 'json'
require 'awesome_print'
require 'sass'

require_relative 'lib.rb'

SECTIONS = ['school-life', 'current-affairs', 'culture', 'politics-history', 'columns', 'sport']

# Get the template
@template_path = "#{Dir.pwd}/template/templates/"

def output_path(issue)
  "#{Dir.pwd}/#{issue}/Output/Unpackaged"
end

task default: %w[directories articles covers assets]

task :directories do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Check to make sure the directory exists
  dir = "#{Dir.pwd}/#{@issue}"

  @output_path = output_path(@issue)

  ['articles', 'covers', 'css', 'images'].each do |f|
    FileUtils.mkdir_p(@output_path + '/' + f)
  end

end

task :articles do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Check to make sure the directory exists
  dir = "#{Dir.pwd}/#{@issue}"

  fail("No articles") unless Dir.exists?(dir + "/Articles")

  # Loop over the sections
  SECTIONS.each do |section|

    # The path of the section
    section_path = "#{dir}/Articles/#{section}"

    # Array of all the markdown files
    articles = Dir.glob("#{section_path}/*.md")

    puts "#{section}:"

    # Loop over them
    articles.each do |article|

      # Render the input markdown
      data = Metadown.render(File.read(article))

      # Set up the variables for the view
      @article_text = data.output

      @section = section
      @author = data.metadata['author']
      @title = data.metadata['title']
      @banner_image = data.metadata['banner']

      puts "  #{@title} by #{@author} (Banner: #{@banner_image})"

      # Render the HTML
      renderer = ERB.new(File.read(@template_path + 'article.erb'))
      html = renderer.result

      # Write it to file
      html_name = "#{@section}-#{@title}.html"
      html_path = output_path(@issue) + '/articles/' + html_name

      File.write(html_path, html)

    end

  end

end

task :covers do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Load the descriptions
  descriptions = YAML.load(File.open("#{Dir.pwd}/template/sections.yml"))

  SECTIONS.each do |section|

    cover_template = @template_path + 'cover.erb'

    @section = section
    puts @section_title = descriptions[@section]['title']
    puts @description = descriptions[@section]['description']

    renderer = ERB.new(File.read(cover_template))
    html = renderer.result

    html_path = "#{output_path(@issue)}/covers/#{@section}.html"

    File.write(html_path, html)

  end

end

task :assets do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Do images first
  destination_path = output_path(@issue) + "/images"

    # Copy all the default images
    FileUtils.cp_r("#{Dir.pwd}/template/images/.", destination_path)
    # Copy all the issue images
    FileUtils.cp_r("#{Dir.pwd}/#{@issue}/Images/.", destination_path)

  # Then do GFX
  destination_path = output_path(@issue) + "/gfx"
  FileUtils.cp_r("#{Dir.pwd}/template/gfx/.", destination_path)

  # Then do CSS
  destination_path = output_path(@issue) + "/css"
  original_path = "#{Dir.pwd}/template/css"

  Dir.glob(original_path + "/*.scss").each do |scss|

    puts scss

    output = Sass::Engine.new(File.read(scss), {syntax: :scss}).render

    name = File.basename(scss, ".scss") + '.css'

    File.write(destination_path + '/' + name, output)

  end

end

task :book_json do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Load the issue and default stuff
  issue_info = YAML.load(File.read("#{Dir.pwd}/#{@issue}/info.yml"))
  default_info = JSON.parse(File.read("#{Dir.pwd}/template/book.json"))

  # Merge them
  issue_info.merge!(default_info)

  # Add the date
  issue_info['date'] = Time.now.strftime("%y-%m-%d")

  all_pages = []

  # Add the front cover
  all_pages << "covers/front.html"

  # Load all the articles
  SECTIONS.each do |section|

    # Add the cover
    all_pages << "covers/#{section}.html"

    # Add all the articles
    path = output_path(@issue) + "/articles/"
    articles = Dir.glob(path + "#{section}-*.html")

    articles.each do |article|
      all_pages << "articles/" + File.basename(article)
    end

  end

  # Add the back cover info
  all_pages << "covers/back.html"

  issue_info['contents'] = all_pages

  path = output_path(@issue) + "/book.json"

  # Write it to file
  File.write(path, issue_info.to_json)

  puts "Written book.json to #{path}"

  ap issue_info

end
