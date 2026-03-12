(function () {
  function initMenu() {
    var button = document.querySelector(".menu-toggle");
    var nav = document.getElementById("site-nav");

    if (!button || !nav) {
      return;
    }

    button.addEventListener("click", function () {
      var expanded = button.getAttribute("aria-expanded") === "true";
      button.setAttribute("aria-expanded", String(!expanded));
      nav.classList.toggle("open");
    });
  }

  function initLogFilters() {
    var filters = document.querySelectorAll("#log-filters .filter-btn");
    var items = document.querySelectorAll("#log-list .log-item");

    if (!filters.length || !items.length) {
      return;
    }

    function applyFilter(value) {
      for (var i = 0; i < items.length; i += 1) {
        var item = items[i];
        if (value === "all" || item.getAttribute("data-category") === value) {
          item.classList.remove("is-hidden");
        } else {
          item.classList.add("is-hidden");
        }
      }
    }

    for (var i = 0; i < filters.length; i += 1) {
      filters[i].addEventListener("click", function (event) {
        for (var j = 0; j < filters.length; j += 1) {
          filters[j].classList.remove("active");
        }

        var button = event.currentTarget;
        button.classList.add("active");
        applyFilter(button.getAttribute("data-filter"));
      });
    }
  }

  function initAnalytics() {
    var trackingId = document.body.getAttribute("data-ga-tracking-id");

    if (!trackingId) {
      return;
    }

    var script = document.createElement("script");
    script.async = true;
    script.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(trackingId);
    document.head.appendChild(script);

    window.dataLayer = window.dataLayer || [];
    window.gtag = function () {
      window.dataLayer.push(arguments);
    };
    window.gtag("js", new Date());
    window.gtag("config", trackingId);
  }

  initMenu();
  initLogFilters();
  initAnalytics();
})();
