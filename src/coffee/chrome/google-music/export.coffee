# placeholder for all found songs
found_songs = {}

# When song table is found, get list of songs and start scrolling to force
# the page to display next songs. Repeat until all songs are harvested.
harvestSongsList = ->
  if content_element = document.querySelector '#content'
    # start watching for new rows with songs
    songs_observer.observe content_element, {childList: true, subtree: true}

    # handle song rows that are already in content element
    handleSongRow node for node in content_element.querySelectorAll '.song-row'

    # Now the tricky part. The table with song rows is not complete. It has the
    # correct length, but not all rows are there. They are added when they are
    # scrolled into the viewport. So we're going to scroll the content panel,
    # until we see it all.
    scrollNode content_element

# We should only watch the song table that actualy contains a list. Sometimes
# there's an empty song table (probably used as a helper object). Full song
# table contains `data-count` attribute.
checkForSongTable = (node) ->
  if node.querySelectorAll?('.song-table tbody[data-count]').length > 0
    harvestSongsList()

# Wait until song table is added to the document.
song_table_observer = new MutationObserver (mutations) ->
  for mutation in mutations
    for node in mutation.addedNodes
      checkForSongTable node

song_table_observer.observe document.body, {childList: true, subtree: true}
checkForSongTable document.body

# When scrolling down the content panel, new rows with song details are added.
# This observer catches them.
songs_observer = new MutationObserver (mutations) ->
  for mutation in mutations
    for node in mutation.addedNodes
      handleSongRow node


# Checks a node if it contains song data. If it does, parses the data and
# inserts it to the `found_songs` placeholder.
handleSongRow = (node) ->
  if node.classList?.contains('song-row') and node.dataset
    id = node.dataset.id
    unless id is 'undefined'
      cells = node.querySelectorAll 'td'
      found_songs[id] =
        title: cells[0].querySelector('.content').textContent
        artist: cells[2].querySelector('.content .text').textContent
        album: cells[3].querySelector('.content .text').textContent

# Scroll element by 100px at the time, until we scroll through its height.
scrollNode = (node) ->

  scroll_position = 0

  scrollDown = ->
    if scroll_position > node.scrollHeight
      clearInterval scroll_interval
      generatePlaylist found_songs
    else
      scroll_position += 100
      node.scrollTop = scroll_position

  scroll_interval = setInterval scrollDown, 100


# Now that we have all the data, let's generate a list that we can use with
# Ivy (http://www.ivyishere.org/).
generatePlaylist = (data = {}) ->
  chrome.runtime.sendMessage
    command: 'show_report'
    data: ("#{val.artist}\t#{val.title}" for key, val of data).join "\n"
  alert result
