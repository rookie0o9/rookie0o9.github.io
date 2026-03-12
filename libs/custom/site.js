(function () {
  var PRODUCTION_HOST = "blog.fixam.co.uk";
  var VISIT_SESSION_KEY = "fixam-visit-notified";

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

  function initVisitNotifications() {
    if (window.location.hostname !== PRODUCTION_HOST) {
      return;
    }

    if (window.top !== window.self) {
      return;
    }

    try {
      if (window.sessionStorage.getItem(VISIT_SESSION_KEY) === "1") {
        return;
      }
    } catch (error) {
      // Continue without session storage if the browser blocks it.
    }

    if (navigator.webdriver) {
      return;
    }

    var payload = JSON.stringify({
      path: window.location.pathname + window.location.search,
      title: document.title,
      referrer: document.referrer,
      visitedAt: new Date().toISOString()
    });

    function markSent() {
      try {
        window.sessionStorage.setItem(VISIT_SESSION_KEY, "1");
      } catch (error) {
        // Ignore storage failures.
      }
    }

    if (navigator.sendBeacon) {
      try {
        var blob = new Blob([payload], { type: "application/json" });
        if (navigator.sendBeacon("/.netlify/functions/visit-telegram", blob)) {
          markSent();
          return;
        }
      } catch (error) {
        // Fall through to fetch.
      }
    }

    window.fetch("/.netlify/functions/visit-telegram", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: payload,
      keepalive: true,
      credentials: "same-origin"
    }).then(markSent).catch(function () {
      // Ignore network failures; this should never block page use.
    });
  }

  initMenu();
  initLogFilters();
  initAnalytics();
  initVisitNotifications();
})();
