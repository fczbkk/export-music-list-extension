chrome.runtime.sendMessage {command: 'get_report'}, (response) ->
  target_element = document.querySelector '#google_music'
  target_element.innerHTML = response.google_music
