require 'spec_helper'

describe Import do
  let(:user) {User.make!} 

  describe "for subscription deleted events" do
    it "should create a new import" do
      director = user.import_directors.where(_type:"SDEImportDirector").first
      director.imports << SDEImport.create(status:'processing')
      director.imports.last.should be_valid
    end
    it "should create a new import from type" do
      director = user.import_directors.where(_type:"SDEImportDirector").first
      import = director.imports.create(_type:"SDEImport",status:'processing')
      import.should be_valid
    end
  end  

  describe "for customer deleted events" do
    it "should create a new import" do
      director = user.import_directors.where(_type:"CDEImportDirector").first
      director.imports << CDEImport.create(status:'processing')
      director.imports.last.should be_valid
    end
    it "should create a new import from type" do
      director = user.import_directors.where(_type:"CDEImportDirector").first
      import = director.imports.create(_type:"CDEImport",status:'processing')
      import.should be_valid
    end
  end  
end
