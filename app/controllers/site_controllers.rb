get '/' do
  erb :'site/home'
end

get '/repo/waka/?' do
  erb :'repo/show'
end

