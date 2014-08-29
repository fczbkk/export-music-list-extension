# Reference to a tab opened by page action click.
opened_tab_id = null

# This takes care of communication between content script and background page.
chrome.runtime.onMessage.addListener (request, sender, callback = ->) ->

  switch request.command

    when 'show_page_action'
      chrome.pageAction.show sender.tab.id

    when 'show_report'
      chrome.storage.local.set {'google_music': request.data}, ->
        # chrome.storage.local.get 'google_music', (result) ->
        chrome.tabs.update opened_tab_id, {url: 'http://google.com'}

    when 'get_report'
      chrome.storage.local.get 'google_music', (result) ->
        callback result

  # Message listener must return `true` to keep the connection open,
  # otherwise it will not execute the callback. See this for more details:
  # https://developer.chrome.com/extensions/runtime#event-onMessage
  true


# When user clicks on page action, open URL that contains his library and start
# harvesting songs list.
chrome.pageAction.onClicked.addListener (callback) ->

  # DEBUG
  chrome.tabs.create {url: 'html/report.html'}
  return

  # Warn the user that some strange shit is going to happen.
  alert "
    I'm going to export the list of songs in your library now.\n\n
    I will open a new tab. There will be some strange stuff happening. Content
    scrolling down and what not. Don't worry and be patient. I'll let you know
    when it's done.
  "

  # This page contains list of all songs in user's library.
  url = 'https://play.google.com/music/listen#/all'

  chrome.tabs.create {url: url}, (tab) ->

    opened_tab_id = tab.id

    # Checks until the tab is loaded, then injects export script to the tab.
    handleTabUpdate = (tab_id, change_info) ->
      if tab_id is opened_tab_id and change_info.status is 'complete'

        # Remove the listener, we don't need it anymore.
        chrome.tabs.onUpdated.removeListener handleTabUpdate

        file_path = 'js/google-music/export.js'
        chrome.tabs.executeScript tab.id, {file: file_path}

    # Tab is opened, but it is still loading. We need to insert a script to it
    # when it loads.
    chrome.tabs.onUpdated.addListener handleTabUpdate
