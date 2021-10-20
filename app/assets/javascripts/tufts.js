/* The grid of featured collections has height issues. The flipping cards use absolute positioning, which doesn't
   lend any height to their parent elements. Since the bootstrap grid system relies on the height of the parent,
   this causes the cards to visually overlap.

   This script manually sets the height of the element to the height of the image + collection title.
   And it does so on window resize as well, so the height is always correct.
 */
(function tuftsScope() {
  "use strict";
  let set_fc_heights, is_homepage;

  // Sets the height of all the featured collection boxes on the homepage to the height of the image + collection title.
  set_fc_heights = function setFcHeights() {
    let fc = document.querySelectorAll('.featured_collection > .flipper'),
      fc_height, height_str;

    if(fc.length === 0) { return }

    fc_height = fc[0].querySelector('img').offsetHeight +
      fc[0].querySelector('.collection_title').offsetHeight;
    height_str = fc_height.toString() + 'px';

    fc.forEach(function(el) { el.style.height = height_str; });
  }

  // Looks for the homepage class on the body tag.
  is_homepage = function isHomepage() {
    return document.querySelector('body').classList.contains('homepage')
  }

  window.addEventListener('DOMContentLoaded', function() {
    if(!is_homepage()) { return }
    setTimeout(set_fc_heights, 250); // For some reason, this still can fire too early, even after DomContentLoaded.
    window.addEventListener('resize', set_fc_heights);
  });
})();