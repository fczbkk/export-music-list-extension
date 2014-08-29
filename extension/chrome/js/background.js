(function() {
  var opened_tab_id;

  opened_tab_id = null;

  chrome.runtime.onMessage.addListener(function(request, sender, callback) {
    if (callback == null) {
      callback = function() {};
    }
    switch (request.command) {
      case 'show_page_action':
        chrome.pageAction.show(sender.tab.id);
        break;
      case 'show_report':
        chrome.storage.local.set({
          'google_music': request.data
        }, function() {
          return chrome.tabs.update(opened_tab_id, {
            url: 'http://google.com'
          });
        });
        break;
      case 'get_report':
        chrome.storage.local.get('google_music', function(result) {
          return callback(result);
        });
    }
    return true;
  });

  chrome.pageAction.onClicked.addListener(function(callback) {
    var url;
    alert("I'm going to export the list of songs in your library now.\n\n I will open a new tab. There will be some strange stuff happening. Content scrolling down and what not. Don't worry and be patient. I'll let you know when it's done.");
    url = 'https://play.google.com/music/listen#/all';
    return chrome.tabs.create({
      url: url
    }, function(tab) {
      var handleTabUpdate;
      opened_tab_id = tab.id;
      handleTabUpdate = function(tab_id, change_info) {
        var file_path;
        if (tab_id === opened_tab_id && change_info.status === 'complete') {
          chrome.tabs.onUpdated.removeListener(handleTabUpdate);
          file_path = 'js/google-music/export.js';
          return chrome.tabs.executeScript(tab.id, {
            file: file_path
          });
        }
      };
      return chrome.tabs.onUpdated.addListener(handleTabUpdate);
    });
  });

}).call(this);
