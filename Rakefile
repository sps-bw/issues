require 'metadown'
require 'erb'
require 'yaml'
require 'json'
require 'awesome_print'

SECTIONS = ['school-life', 'current-affairs', 'culture', 'politics-history', 'columns', 'sport']

# Get the template
@template_path = "#{Dir.pwd}/template/templates/article.erb"

def output_path(issue)
  "#{Dir.pwd}/#{issue}/Output/Unpackaged"
end

task default: %w[directories articles]

task :directories do

  # Get the issue number from the command line
  @issue = ENV['ISSUE']

  # Return if it doesn't exist
  fail("No issue") unless @issue

  # Check to make sure the directory exists
  dir = "#{Dir.pwd}/#{@issue}"

  @output_path = output_path(@issue) + '/articles'

  FileUtils.mkdir_p(@output_path)

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
      renderer = ERB.new(File.read(@template_path))
      html = renderer.result

      # Write it to file
      html_name = "#{@section}-#{@title}.html"
      html_path = output_path(@issue) + '/articles/' + html_name

      File.write(html_path, html)

    end

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
