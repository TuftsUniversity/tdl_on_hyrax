TDL
===========================

Code for the Tufts Digital Library

At the moment if you've set up https://github.com/TuftsUniversity/epigaea appending
run `bundle exec rake hydra:server` from that project, this app will share the
same Solr and Fedora instance.   

## Loading Fixtures
### Notes:
* fixture binaries are located in spec/fixtures
* fixture metadata is located in lib/tufts/populate_fixtures
### Rake Tasks
* rake tufts:fixtures:load_fixtures
* rake tufts:fixtures:delete_fixtures
* rake tufts:fixtures:refresh
