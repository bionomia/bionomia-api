describe "Bionomia Reconcile Controller" do

  it "should allow accessing the reconcile via GET" do
    get '/reconcile'
    expect(last_response).to be_ok
  end

  it "should allow accessing the reconcile via POST" do
    post '/reconcile'
    expect(last_response).to be_ok
  end

  it "should allow accessing the property suggest" do
    get '/reconcile/suggest/property'
    expect(last_response).to be_ok
  end

  it "should allow accessing the families_collected flyout property" do
    get '/reconcile/flyout/property/families_collected'
    expect(last_response).to be_ok
  end

  it "should allow accessing the families_identified flyout property" do
    get '/reconcile/flyout/property/families_identified'
    expect(last_response).to be_ok
  end

  it "should allow accessing the date flyout property" do
    get '/reconcile/flyout/property/date'
    expect(last_response).to be_ok
  end

end
