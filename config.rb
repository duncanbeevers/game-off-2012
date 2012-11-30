###
# Compass
###

# Susy grids in Compass
# First: gem install susy --pre
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# configure :development do
#   set :debug_assets, true
# end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :cache_buster

  # Use relative URLs
  activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  require "middleman-smusher"
  activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end

helpers do
  # Generate the manifest of files for the preloader to load
  def assets_manifest_json
    assets = nil
    Dir.chdir("source") do
      assets = (
        Dir.glob("images/**/*") +
        Dir.glob("sounds/**/*") +
        Dir.glob("levels/**/*")
      ).select { |f| !File.directory?(f) }
    end

    manifest_entries = assets.map do |f|
      {
        id: File.basename(f),
        src: f
      }
    end

    manifest_entries.to_json
  end

  # Maze generator specific dropdown
  # Move this out of generate config helpers
  def substrate_images
    Dir.chdir("source") do
      allnames = Dir.glob("images/substrates/**/*")
      filenames = allnames.select { |f| !File.directory?(f) }

      filenames.map do |f|
        basename = File.basename(f, File.extname(f))
        extra = nil
        # if identify_dimensions
        if false
          identify = `identify #{f}`
          dimensions = /\d+x\d+/.match(identify)[0]
          extra = dimensions
        else
          extra = ""
        end

        [ f, "#{basename} #{extra}" ]
      end
    end
  end

  def favicon_link_tag(src)
    tag(:link, rel: 'icon', type: 'image/png', href: image_path(File.join('favicon', src)))
  end

end
