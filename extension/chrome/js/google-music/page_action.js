(function() {
  chrome.runtime.sendMessage({
    command: 'show_page_action'
  });

}).call(this);
