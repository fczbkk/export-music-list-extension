# send signal to background page to show page action icon
chrome.runtime.sendMessage {command: 'show_page_action'}
