#!/usr/bin/env ruby
require 'sinatra'
require 'pg'
require 'json'

set :bind, '0.0.0.0'
set :port, 80

set :db, PG.connect(host: 'localhost', user: 'postgres', dbname: 'log4micro', password: 'log4micro')
configure do
  mime_type :json, 'application/json'
end

get '/home' do
  'hello'
end

get '/projects' do
  content_type :json
  projects = []
  settings.db.exec('select * from projects;') do |res|
    res.each do |row|
      projects << row
    end
  end
  JSON.generate(projects)
end

get '/projects/:id/logs' do
  halt 400, "invalid project id" if (params['id']=~ /\A\d+\z/).nil?
  content_type :json
  logs = []
  settings.db.exec_params('select * from logs where project_id=$1::int;', [params['id'].to_i]) do |res|
    res.each do |row|
      logs << row
    end
  end
  JSON.generate(logs)
end
