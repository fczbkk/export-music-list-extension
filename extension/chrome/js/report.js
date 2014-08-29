(function() {
  chrome.runtime.sendMessage({
    command: 'get_report'
  }, function(response) {
    var target_element;
    target_element = document.querySelector('#google_music');
    return target_element.innerHTML = response.google_music;
  });

}).call(this);
