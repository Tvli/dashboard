
require_relative '../main.rb'
require_relative 'test_helper'

set :environment, :test

describe Main do
  let(:app) { Main.new }
  let(:json_data) { File.read(File.expand_path("test/fixtures/get_data.json"))} 


  describe 'the user clicks add new tile' do
    it 'should display the new tile form' do
      get '/new_tile'
      assert last_response.ok?
    end
  end 

  describe 'the user clicks vimeo link' do
    it 'should display the new vimeo form' do
      get '/new_tile/vimeo'
      assert last_response.ok?
    end
   end

  describe 'adding a new vimeo tile' do
    it 'should add a new vimeo tile to the array' do
      size =  app.helpers.tiles.count
      post '/new_tile/vimeo', params = {:video_id => '12345'}
      assert_equal (size + 1) , app.helpers.tiles.count
    end
  end


  describe 'adding a new json tile' do
    it 'should add a new json tile to the array' do
      size = app.helpers.tiles.count  
      response = FakeResponse.new(json_data, 200) 
      Net::HTTP.stub :get_response, response do
        post '/new_tile/jsontile', params = {:json_url => 'www.test.com'}
        assert_equal (size + 1) , app.helpers.tiles.count
      end
    end
  end

  describe 'adding a new iframe tile' do
    it 'should add a new iframe tile to the array' do
      size =  app.helpers.tiles.count
      post '/new_tile/iframe', params = {:embed_url => 'www.test.com', :embed_height => 500, :embed_width => 300}
      assert_equal (size + 1) , app.helpers.tiles.count
    end      
  end 

  describe 'clicking a remove link' do
    it 'should remove the vimeo element from the tile array' do
      params = {:video_id => '123456'}
      app.helpers.tiles = [Vimeo.new(params)]
      get '/remove_tile?index=0'
      assert_equal 0, app.helpers.tiles.count
    end
  end

  describe 'editing a vimeo tile' do
    it 'should update the values of the associated tile' do
      params = {:video_id => '123456'}
      app.helpers.tiles = [Vimeo.new(params)]
      post '/edit_tile/vimeo', params = {:video_id => '09876', :index => 0}
      assert_equal '//player.vimeo.com/video/09876', app.helpers.tiles[0].url
    end
  end

end


