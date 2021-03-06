require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

def create_j2ee_petstore_schema
  execute_sql_script(File.expand_path(File.dirname(__FILE__) + '/../../examples/delete_j2ee_petstore.sql') ) unless ENV['ADAPTER'] == 'sqlite3' rescue nil
  execute_sql_script(File.expand_path(File.dirname(__FILE__) + '/../../examples/create_j2ee_petstore.sql') )
end

describe ModelsFromTablesGenerator, "Generating models from j2ee petstore #{ENV['ADAPTER']} database", :type=>:generator do

  before :all do
    @adapter = ENV['ADAPTER']
    @example = :j2ee_petstore

    connection_info = connection_info_for(@example, @adapter) 
    pending("The #{@example} spec does not run for #{@adapter}") if connection_info.nil?
    initialize_connection connection_info
    create_j2ee_petstore_schema

    self.destination_root = File.expand_path("#{File.dirname(__FILE__)}/../../output/functional/#{@example}_#{@adapter}")
    FileUtils.mkdir_p(destination_root + '/app/models')
    FileUtils.mkdir_p(destination_root + '/spec')
  
    LegacyData::Schema.stub!(:log)    

    @expected_directory = File.expand_path("#{File.dirname(__FILE__)}/../../examples/generated/#{@example}_#{@adapter}") 
    
  end
  
  before :each do
    LegacyData::TableClassNameMapper.stub!(:wait_for_user_confirmation)
    Rails.stub!(:root).and_return(destination_root)
    LegacyData::TableClassNameMapper.dictionary['files'] = 'UploadedFiles'  #to avoid collision with Ruby File class
    LegacyData::TableClassNameMapper.dictionary['cache'] = 'Cache'          #don't strip the e to make it cach

    FileUtils.rm(destination_root + '/spec/factories.rb', :force => true)
    run_generator
  end

  models =  %w( address   category     id_gen       item           
                product   tag          ziplocation       )
  
  if ENV['ADAPTER'] == 'oracle'              
    models + %w( sellercontactinfo   ) 
  else
    models + %w( seller_contact_info tag_info) 
  end
                
  models.each do |model|
    it "should generate the expected #{model} model" do
      File.read(destination_root + "/app/models/#{model}.rb").should == File.read("#{@expected_directory}/#{model}.rb")
    end
  end
  
  it "should  generated the expected factories" do
    File.read(destination_root + '/spec/factories.rb').should == File.read("#{@expected_directory}/factories.rb")
  end
end
