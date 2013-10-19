get '/' do
  @repos = Repository.all.to_a
  erb :'site/home'
end

get '/repo/waka/?' do
  erb :'repo/show'
end

