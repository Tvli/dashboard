require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader' if development?

Dir["tiles/*"].each {|file| require_relative file }
require_relative 'helpers/tile_manager'

class Main < Sinatra::Base

  attr_accessor :tiles

  @@env = { pivotal_token:  '911f87a7a91f7465ef00d89d9cb8edc3'}

  def self.env_params
    @@env
  end

  def self.update_env(params)
    @@env = params
  end

  def initialize
    @tiles = []
    @errors = []
    @tile_types = {Vimeo: 'Vimeo', JSONTile: 'Json', IFrame: 'IFrame', TimeTile: 'Time', PivotalTile: 'Pivotal' }
    super
  end

  get '/' do
    redirect to '/dashboard'
  end

  get '/dashboard' do
    @tiles
    erb :dashboard
  end

  get '/new_tile' do
    @tile_types
    erb :new_tile
  end

  get '/new_tile/:type' do |t|
    @tile = TileManager.create_tile(t)
    display_tile_erb(t)
  end

  post '/new_tile/:type' do |t|
    begin
      tile = TileManager.create_tile(t, params)
      tile.update
      add_tile(tile)
      redirect to '/dashboard'
    rescue => e
      @tile = tile
      @errors.push(e.message)
      display_tile_erb(t)
    end
  end

  get '/remove_tile' do
    index = params[:index].to_i
    remove_tile(index)
    redirect to '/dashboard'
  end

  get '/edit_tile/:type' do |t|
    index = params[:index].to_i
    @tile = tiles[index]
    display_tile_erb(t)
  end

  post '/edit_tile/:type' do |t|
    begin
      index = params[:index].to_i
      old_tile = tiles[index].dup
      @tile = tiles[index].edit(params).update
      redirect to '/dashboard'
    rescue => e
      tiles[index] = old_tile
      @errors.push(e.message)
      display_tile_erb(t)
    end
  end

  after do
    @errors.clear
  end

  get '/settings' do
    @env = @@env
    erb :settings
  end

  get '/move_tile_up' do
    handle_move(params, -1)
  end

  get '/move_tile_down' do
    handle_move(params, 1)
  end

  post '/settings' do
  	@@env = params
    redirect to '/dashboard'
  end

  def add_tile(tile)
    if tile != nil
      @tiles.push(tile)
    end
  end

  def remove_tile(index)
    @tiles.delete_at(index)
  end

  def delete_all
    @tiles = []
  end

  def display_tile_erb(type)
    erb "forms/#{type.downcase}".to_sym
  end

  def handle_move(params, direction)
    index = params[:index].to_i
    tiles.insert(index + direction, tiles.delete_at(index))
    redirect to '/dashboard'
  end
end
