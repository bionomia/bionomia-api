describe "Bionomia Search Controller" do

  it "should allow accessing the search" do
    get '/users/search'
    expect(last_response).to be_ok
  end

end
