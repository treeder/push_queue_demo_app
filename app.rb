require 'sinatra'
require 'iron_cache'

IRON_CACHE = IronCache::Client.new

post '/ironmq_push_1' do
  p params
  cache_key = "push_1_store"
  add_to_store(cache_key)
end

post '/ironmq_push_2' do
  p params
  # Add the new post body to IronCache
  cache_key = "push_2_store"
  add_to_store(cache_key)
end

def add_to_store(key)
  p request.body
  body = JSON.parse(request.body)
  item = IRON_CACHE.get(key)
  if item
    val = JSON.parse(item.value)
  else
    val = []
  end
  val << body
  IRON_CACHE.put(key, val)
end

get '/' do
  puts "IN / endpoint"
  ret = "These are the IronMQ messages I received:"
  begin

    ret << "<br/><br/>From ironmq_push_1 endpoint:<br/>"
    item = IRON_CACHE.get("push_1_store")
    if item
      ret << item.value
    end
    ret << "<br/><br/>From ironmq_push_2 endpoint:<br/>"

    item = IRON_CACHE.get("push_2_store")
    if item
      ret << item.value
    end
  rescue Exception => ex
    p ex
  end
  ret
end
