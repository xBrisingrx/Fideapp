//= require rails-ujs
//= require activestorage
//= require activestorage
//= require unify/jquery.min
//= require unify/jquery-migrate.min
//= require unify/popper.min
//= require unify/bootstrap.min
//= require unify/jquery.cookie 
//= require unify/appear
//= require unify/jquery.mCustomScrollbar.concat.min
//= require unify/chartist.min
//= require unify/chartist-plugin-tooltip
//= require unify/hs.core
//= require unify/hs.side-nav
//= require unify/hs.hamburgers
//= require unify/hs.dropdown
//= require unify/hs.scrollbar
//= require unify/hs.area-chart
//= require unify/hs.donut-chart
//= require unify/hs.bar-chart
//= require unify/hs.toastr
//= require unify/hs.popup
//= require unify/noty.min
//= require plugins/datatables.min
//= require plugins/select2.full.min
//= require custom


//= require urbanizations
//= require sectors
//= require condominia
//= require apples
//= require clients
//= require lands

// require_tree .


$(document).on('ready', function () {
  // initialization of hamburger
  $.HSCore.helpers.HSHamburgers.init('.hamburger');

  // initialization of sidebar navigation component
  $.HSCore.components.HSSideNav.init('.js-side-nav', {
    afterOpen: function() {
      setTimeout(function() {
        $.HSCore.components.HSAreaChart.init('.js-area-chart');
        $.HSCore.components.HSDonutChart.init('.js-donut-chart');
        $.HSCore.components.HSBarChart.init('.js-bar-chart');
      }, 400);
    },
    afterClose: function() {
      setTimeout(function() {
        $.HSCore.components.HSAreaChart.init('.js-area-chart');
        $.HSCore.components.HSDonutChart.init('.js-donut-chart');
        $.HSCore.components.HSBarChart.init('.js-bar-chart');
      }, 400);
    }
  });

  // initialization of HSDropdown component
  $.HSCore.components.HSDropdown.init($('[data-dropdown-target]'), {dropdownHideOnScroll: false})

  // initialization of custom scrollbar
  $.HSCore.components.HSScrollBar.init($('.js-custom-scroll'))
})