require 'sinatra'

post '/ironmq_push' do
  p params

end

get '/' do
  "I can receive IronMQ messages!"
end
