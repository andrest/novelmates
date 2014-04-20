# TODO: Future Work
Novelmates::App.controllers :discover do

  layout :application
  get :index, with: :city do
    page = '<div>' + params[:city] + '</div>'
    erb page
  end

  get :show do

  end
end
