get '/' do
  if params[:screenshot]
    erb :'site/screenshot', layout: false
  else
    @repos = Repository.where(featured: true).all
    erb :'site/home'
  end
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
