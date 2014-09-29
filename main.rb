require 'rubygems'
require 'sinatra'

# set :sessions, true
set :bind, '0.0.0.0'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'zhW^$#LEYrmvgabos(H_c{8Fk*V3?K9}27C0=,nD'
