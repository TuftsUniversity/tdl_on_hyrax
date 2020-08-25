namespace :tufts do
  desc "Deletes the many caches of a single image around the server"
  task :clear_image_cache, [:image_id] => :environment do |_t, args|
    if args[:image_id].nil?
      puts 'You must specify an Image ID.'
      next
    end

    puts "Deleting #{args[:image_id]}'s caches. You will probably need to clear browser cache as well."
    Image.find(args[:image_id]).file_sets.each do |fsid|
      Tufts::ImageCacheClearer.delete_image_cache(fsid)
    end
  end
end
