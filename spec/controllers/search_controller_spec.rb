describe "Bionomia Search Controller" do

  it "should allow accessing the search" do
    get '/users/search'
    expect(last_response).to be_ok
  end

  it "should allow accessing the parse page via GET" do
    get '/parse'
    expect(last_response).to be_ok
  end

  it "should allow accessing the parse page via POST" do
    post '/parse'
    expect(last_response).to be_ok
  end

end
