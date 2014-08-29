(function() {
  var checkForSongTable, found_songs, generatePlaylist, handleSongRow, harvestSongsList, scrollNode, song_table_observer, songs_observer;

  found_songs = {};

  harvestSongsList = function() {
    var content_element, node, _i, _len, _ref;
    if (content_element = document.querySelector('#content')) {
      songs_observer.observe(content_element, {
        childList: true,
        subtree: true
      });
      _ref = content_element.querySelectorAll('.song-row');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        handleSongRow(node);
      }
      return scrollNode(content_element);
    }
  };

  checkForSongTable = function(node) {
    if ((typeof node.querySelectorAll === "function" ? node.querySelectorAll('.song-table tbody[data-count]').length : void 0) > 0) {
      return harvestSongsList();
    }
  };

  song_table_observer = new MutationObserver(function(mutations) {
    var mutation, node, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = mutations.length; _i < _len; _i++) {
      mutation = mutations[_i];
      _results.push((function() {
        var _j, _len1, _ref, _results1;
        _ref = mutation.addedNodes;
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          node = _ref[_j];
          _results1.push(checkForSongTable(node));
        }
        return _results1;
      })());
    }
    return _results;
  });

  song_table_observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  checkForSongTable(document.body);

  songs_observer = new MutationObserver(function(mutations) {
    var mutation, node, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = mutations.length; _i < _len; _i++) {
      mutation = mutations[_i];
      _results.push((function() {
        var _j, _len1, _ref, _results1;
        _ref = mutation.addedNodes;
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          node = _ref[_j];
          _results1.push(handleSongRow(node));
        }
        return _results1;
      })());
    }
    return _results;
  });

  handleSongRow = function(node) {
    var cells, id, _ref;
    if (((_ref = node.classList) != null ? _ref.contains('song-row') : void 0) && node.dataset) {
      id = node.dataset.id;
      if (id !== 'undefined') {
        cells = node.querySelectorAll('td');
        return found_songs[id] = {
          title: cells[0].querySelector('.content').textContent,
          artist: cells[2].querySelector('.content .text').textContent,
          album: cells[3].querySelector('.content .text').textContent
        };
      }
    }
  };

  scrollNode = function(node) {
    var scrollDown, scroll_interval, scroll_position;
    scroll_position = 0;
    scrollDown = function() {
      if (scroll_position > node.scrollHeight) {
        clearInterval(scroll_interval);
        return generatePlaylist(found_songs);
      } else {
        scroll_position += 100;
        return node.scrollTop = scroll_position;
      }
    };
    return scroll_interval = setInterval(scrollDown, 100);
  };

  generatePlaylist = function(data) {
    var key, val;
    if (data == null) {
      data = {};
    }
    chrome.runtime.sendMessage({
      command: 'show_report',
      data: ((function() {
        var _results;
        _results = [];
        for (key in data) {
          val = data[key];
          _results.push("" + val.artist + "\t" + val.title);
        }
        return _results;
      })()).join("\n")
    });
    return alert(result);
  };

}).call(this);
