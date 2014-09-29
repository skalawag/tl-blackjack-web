require 'rubygems'
require 'sinatra'
require 'pry'
# set :sessions, true
set :bind, '0.0.0.0'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'zhW^$#LEYrmvgabos(H_c{8Fk*V3?K9}27C0=,nD'

helpers do
  def blackjack?(cards)
    cards.length == 2 && cards.sort.first[0] == 'A'
  end

  def eval_hand(cards)
    if blackjack?(cards)
      return 'Blackjack!'
    end
    # otherwise, total card values
    total = 0
    ranks = cards.map {|c| c[0]}
    ranks.each do |c|
      if c == 'A'
        total += 11
      elsif c.to_i == 0
        total += 10
      else
        total += c.to_i
      end
    end
    # take account of aces
    num_of_aces = ranks.count('A')
    while num_of_aces > 0 && total > 22
      total -= 10
      num_of_aces -= 1
    end
    if total > 21
      'Bust!'
    else
      total
    end
  end
end

get '/' do
#  redirect :signup
  if not session[:username]
    redirect :signup
  else
    erb :blackjack
  end
end

get '/signup' do
  erb :signup
end

post '/signup' do
  session[:username] = params[:username]
  redirect :blackjack
end

# hands begin here
get '/blackjack' do
  session['player_result'] = ""
  session['dealer_result'] = ""
  session['deck'] =
    "AJQKT98765432".chars.product("csdh".chars).map { |c| c.join }.shuffle
  session[:player_cards] = []
  session[:dealer_cards] = []
  session['player_cards'] << session['deck'].pop
  session['player_cards'] << session['deck'].pop
  session['dealer_cards'] << session['deck'].pop
  session['dealer_cards'] << session['deck'].pop
  session['player_result'] = eval_hand(session['player_cards'])
  session['dealer_result'] = eval_hand(session['dealer_cards'])
  erb :blackjack
end

post '/take_bet' do
  session['player_bet'] = params['player_bet']
  redirect :deal
end

get '/deal' do
  @cards = session['player_cards']
  erb :deal
end

post '/hit' do
  session['player_cards'] << session['deck'].pop
  session['player_result'] = eval_hand(session['player_cards'])
  if session['player_result'] == 'Bust!' ||
      session['player_result'] == 'Blackjack!'
    redirect :dealer_play
  else
    redirect :deal
  end
end

post '/stay' do
  session['player_result'] = eval_hand(session['player_cards'])
  redirect :dealer_play
end

# FIXME: return only numbers from eval_hand. you can adjust them for
# display later. that will avoid all these erroneous comparisons.
get '/dealer_play' do
  if session['player_result'] != 'Bust!' &&
      session['player_result'] != 'Blackjack!'
    while session['dealer_result'] != 'Bust!' &&
        session['dealer_result'] != 'Blackjack!' &&
        eval_hand(session['dealer_cards']) < 17
      session['dealer_cards'] << session['deck'].pop
      session['dealer_result'] = eval_hand(session['dealer_cards'])
      p session['dealer_cards']
      p session['dealer_result']
    end
  end
  binding.pry
  @player = session['username']
  @player_cards = session['player_cards']
  @p = session['player_result']
  @dealer_cards = session['dealer_cards']
  @d = session['dealer_result']
  erb :dealer_play
end

post '/query' do
  # announce result and then...
  if params['quit']
    redirect :sayoonara
  else
    redirect :blackjack
  end
end

get '/sayoonara' do
  erb :sayoonara
end
