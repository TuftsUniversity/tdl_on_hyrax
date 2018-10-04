// Tufts' custom search bar stuff. Overwrites search.js from Hyrax.

Hyrax.Search = (function($) {
  var search_field, $form, $label, $items;

  // Gets all the elements we need to work with.
  var init = function(form_element) {
    $form  = form_element;
    $label = $form.find('[data-search-element="label"]');
    $items = $form.find('.dropdown-item');
    search_field = "keyword";

    attachEvents();
  }

  // Attachs all the events.
  var attachEvents = function() {
    $items.on('click', itemClicked);
    $form.on('submit', formSubmitted);
  }

  // Builds a url using the search_field selection and getQuery().
  var buildUrl = function() {
    var wl = window.location,
      url =  "http://" + wl.host + wl.pathname + "?utf8=\u2713&search_field=advanced&";
    return url + search_field + '=' + getQuery();
  }

  // Gets the query from the text input.
  var getQuery = function() {
    return $form.find('#search-field-header').val();
  }

  // Set search_field and $label when a new $item is selected.
  var itemClicked = function(event) {
    event.preventDefault();
    $label[0].textContent = this.textContent;
    search_field = this.getAttribute('data-search-field');
  };

  // Builds custom url for searching, if user has selected something other than keyword.
  var formSubmitted = function(event) {
    if(search_field !== 'keyword') {
      event.preventDefault();
      window.location = buildUrl();
    }
  };

  return {
    init: init
  }

})(jQuery);


Blacklight.onLoad(function initSearchBarCode() {
  var search_form = $('#search-form-header');
  if(search_form.length > 0) {
    Hyrax.Search.init(search_form);
  }
});
