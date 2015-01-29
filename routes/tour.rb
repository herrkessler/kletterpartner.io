class KletterPartner < Sinatra::Base

  # Blog
  # -----------------------------------------------------------

  get '/tour' do
    slim :"tour/index"
  end
  
end