namespace :tufts do
  desc "Deletes the many caches of a single image around the server"
  task :clear_image_cache, [:image_id] => :environment do |_t, args|
    if args[:image_id].nil?
      puts 'You must specify an Image ID.'
      next
    end

    puts "Deleting #{args[:image_id]}'s caches. You will probably need to clear browser cache as well."
    Tufts::ImageCacheClearer.delete_image_cache(args[:image_id])
  end
end
