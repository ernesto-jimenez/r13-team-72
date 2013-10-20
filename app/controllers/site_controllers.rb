get '/' do
  @repos = Repository.all.to_a
  erb :'site/home'
end

get '/repo/waka/?' do
  erb :'repo/sample_show'
end

get '/error' do
  erb :'site/error'
end

get '/waiting' do
  erb :'site/waiting'
end
