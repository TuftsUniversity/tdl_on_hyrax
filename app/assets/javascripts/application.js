// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require 'blacklight_advanced_search'
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require jquery_ujs
//= require turbolinks
//
// Required by Blacklight
//= require blacklight/blacklight

// Need hyrax app before our code
//= require 'hyrax/app.js'
//= require_tree .
//= stub bookreader.js
//= stub ./BookReader/BookReader.js
//= stub ./BookReader/dragscrollable.js
//= stub ./BookReader/jquery.bt.min.js
//= stub ./BookReader/jquery.colorbox-min.js
//= stub ./BookReader/jquery-ui-1.8.5.custom.min.js
//= stub ./BookReader/jquery.ui.ipad.js
//= stub ./pdfviewer/BookReaderPDFViewer.js
//= require hyrax
//= require 'mustache/mustache.js'
//= require 'bookbag/bookbag.js'
//= require 'bookbag/datepicker.js'
//= require 'read_more_or_less'


// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'
