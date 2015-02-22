require 'rest_client'
require 'date'

SCHEDULER.every "30s" do
  headers = {
    "X-Access-Token" => ENV["WUNDERLIST_CLIENT_TOKEN"],
    "X-Client-ID" => ENV["WUNDERLIST_CLIENT_ID"]
  }
  lists_response = RestClient.get "https://a.wunderlist.com/api/v1/lists", headers
  lists_hash = JSON.parse(lists_response.to_str)
  list_ids = lists_hash.map do |list|
    list["id"]
  end
  total = 0
  list_ids.each do |list_id|
    tasks_response = RestClient.get "https://a.wunderlist.com/api/v1/tasks?list_id=#{list_id}", headers
    tasks = JSON.parse(tasks_response.to_str)
    due_tasks = tasks.select do |task|
      Date.parse(task["due_date"]) <= Date.today
    end
    total += due_tasks.count
  end
  send_event('wunderlist', { current: total })
end
