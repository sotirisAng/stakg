require 'mini_magick'

namespace :images do
  desc "Resize all images in the public/uploads directory"
  task :resize => :environment do
    Dir.glob("public/uploads/**/*.{jpg,jpeg,png,gif}") do |file|
      image = MiniMagick::Image.open(file)
      image.resize "500x500"
      image.quality "80"
      image.write file
    end
  end
end