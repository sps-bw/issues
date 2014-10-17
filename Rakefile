require 'rubygems'

require 'metadown'
require 'erb'
require 'yaml'
require 'json'
require 'awesome_print'
require 'sass'
require 'zip'
require 'colorize'

require_relative 'lib.rb'

SECTIONS = ['editorial', 'school-life', 'current-affairs', 'politics-history', 'culture', 'sport', 'columns']

# Get the template
@template_path = "#{Dir.pwd}/template/templates/"

def output_path(issue)
  "#{Dir.pwd}/#{issue}/Output/Unpackaged"
end

task default: %w[delete directories articles covers index assets book_json zip]

task :delete do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  FileUtils.rm_rf("#{Dir.pwd}/#{@issue}/Output")

end

task :directories do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  puts "Processing Issue #{@issue}...".blue

  puts "  Creating Directories...".green

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

  puts "  Rendering Articles:".green

  index = {}

  # Loop over the sections
  SECTIONS.each do |section|

    # The path of the section
    section_path = "#{dir}/Articles/#{section}"

    # Array of all the markdown files
    articles = Dir.glob("#{section_path}/*.md").sort!

    puts "    #{section}:".red

    article_index = []

    # Loop over them
    articles.each do |article|

      # Render the input markdown
      data = Metadown.render(File.read(article))
      save_name = File.basename(article, ".md").gsub(/[^0-9a-z ]/i, '') + '.html'

      # Set up the variables for the view
      @article_text = data.output

      @section = section
      @author = data.metadata['author']
      @title = data.metadata['title']
      @banner_image = data.metadata['banner']
      @light = data.metadata['light']

      # Render the HTML
      renderer = ERB.new(File.read(@template_path + 'article.erb'))
      html = renderer.result

      # Write it to file
      html_name = "#{@section}-" + save_name
      html_path = output_path(@issue) + '/articles/' + html_name

      puts "      #{html_path}".yellow

      File.write(html_path, html)

      html_path.slice!(Dir.pwd)
      html_path.slice!("/#{@issue}/Output/Unpackaged/")

      article_index.push({title: @title, banner: @banner_image, path: html_path})

    end

    index[section] = article_index

  end

  File.write(output_path(@issue) + "/index.json", index.to_json)

end

task :covers do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  puts "  Rendering covers...".green

  # Load the descriptions
  descriptions = YAML.load(File.open("#{Dir.pwd}/template/sections.yml"))

  SECTIONS.each do |section|

    cover_template = @template_path + 'cover.erb'

    @section = section
    @section_title = descriptions[@section]['title']
    @description = descriptions[@section]['description']

    renderer = ERB.new(File.read(cover_template))
    html = renderer.result

    html_path = "#{output_path(@issue)}/covers/#{@section}.html"

    puts "    #{html_path}".yellow

    File.write(html_path, html)

  end

  endparts_path = "#{Dir.pwd}/template/covers/"
  front_path = endparts_path + "front.html"
  back_path = endparts_path + "back.html"

  destination_path = output_path(@issue) + "/covers/"

  puts "    #{destination_path}front.html".yellow
  puts "    #{destination_path}back.html".yellow

  # Front and back covers
  FileUtils.cp(front_path, destination_path + "front.html")
  FileUtils.cp(back_path, destination_path + "back.html")

end

task :assets do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  puts "  Creating assets...".green

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

    puts "    #{scss}".yellow

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

  puts "  Generating book.json".green

  # Load the issue and default stuff
  issue_info = YAML.load(File.read("#{Dir.pwd}/#{@issue}/info.yml"))
  default_info = JSON.parse(File.read("#{Dir.pwd}/template/book.json"))

  # Merge them
  issue_info.merge!(default_info)

  # Add the date
  issue_info['date'] = Time.now.strftime("%Y-%m-%d")

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
  issue_info['url'] = "book://bw.alfo.im/issues/#{@issue}"

  path = output_path(@issue) + "/book.json"

  # Write it to file
  File.write(path, issue_info.to_json)

end

task :index do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  puts "  Generating the index".green

  index_template = @template_path + 'index.erb'

  # Load the descriptions
  @descriptions = YAML.load(File.open("#{Dir.pwd}/template/sections.yml"))
  @articles = JSON.parse(File.read(output_path(@issue) + "/index.json"))

  renderer = ERB.new(File.read(index_template))
  html = renderer.result

  path = output_path(@issue) + "/index.html"

  puts "    #{path}".yellow

  File.write(path, html)

end

task :zip do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  puts "  Packaging...".green

  dir = "#{Dir.pwd}/#{@issue}/Output"

  `cd #{Shellwords.escape(dir + "/Unpackaged")} && zip -r issue.zip *`

  FileUtils.mv(dir + "/Unpackaged/issue.zip", dir + "/issue-#{@issue}.hpub")

end
