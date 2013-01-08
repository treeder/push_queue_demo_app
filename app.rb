require 'sinatra'
require 'iron_cache'

IRON_CACHE_CLIENT = IronCache::Client.new
IRON_CACHE = IRON_CACHE_CLIENT.cache("pushq-demo-cache")

post '/ironmq_push_1' do
  p params
  cache_key = "push_1_store"
  add_to_store(cache_key)
  "got it!"
end

post '/ironmq_push_2' do
  p params
  # Add the new post body to IronCache
  cache_key = "push_2_store"
  add_to_store(cache_key)
  "got it!"
end

def add_to_store(key)
  begin
    body = request.body.read
    p body
    #body = JSON.parse(body)
    item = IRON_CACHE.get(key)
    if item
      val = JSON.parse(item.value)
    else
      val = []
    end
    val << body
    IRON_CACHE.put(key, val.to_json, expires_in: 3600)
  rescue Exception => ex
    puts "ERROR adding to cache: #{ex}"
    p ex.backtrace
  end
end

get '/' do
  puts "IN / endpoint"
  ret = "I like getting messages from IronMQ!"
  begin

    ret << "<br/><br/>From ironmq_push_1 endpoint:<br/>"
    item = IRON_CACHE.get("push_1_store")
    if item
      ret << item.value
    else
      ret << "Nothing here yet."
    end

    ret << "<br/><br/>From ironmq_push_2 endpoint:<br/>"
    item = IRON_CACHE.get("push_2_store")
    if item
      ret << item.value
    else
      ret << "Nothing here yet."
    end
  rescue Exception => ex
    puts "ERROR! #{ex}"
    p ex.backtrace
  end
  ret
end
