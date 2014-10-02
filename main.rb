require 'rubygems'
require 'sinatra'
require 'pry'
set :sessions, true

## commented this out after failure
#set :bind, '0.0.0.0'

# use Rack::Session::Cookie, :key => 'rack.session',
#                            :path => '/',
#                            :secret => 'zhW^$#LEYrmvgabos(H_c{8Fk*V3?K9}27C0=,nD'

helpers do
  def run_dealer
    d_val = eval_hand(session['dealer_cards'])
    p_val = eval_hand(session['player_cards'])
    if p_val > 22
      redirect '/announce'
    elsif d_val >= p_val
      redirect '/announce'
    else
      erb :game
    end
  end

  def get_img_url(card)
    "<img src='/images/cards/#{card}.jpg' class='card_image' width=100px/>"
  end

  def blackjack?(cards)
    cards.length == 2 &&
      cards.sort.first[0] == 'A' &&
      cards.sort.last[0] =~ /K|Q|J|T/
  end

  def eval_hand(cards)
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
    while num_of_aces > 0 && total > 21
      total -= 10
      num_of_aces -= 1
    end
    total
  end

  def winner?
    p_score = eval_hand(session['player_cards'])
    d_score = eval_hand(session['dealer_cards'])
    p_bj = blackjack?(session['player_cards'])
    b_bj = blackjack?(session['dealer_cards'])
    if p_bj && d_score < 22 && (not b_bj) ||
      p_score < 22 && d_score > 21 ||
        p_score > d_score && p_score < 22
      session['player_name']
    elsif p_score == d_score
      "Tie"
    else
      "Dealer"
    end
  end

  def player_live?
    if eval_hand(session['player_hand']) < 22
      true
    end
  end

  def blackjack_beats_dealer?
    cards = session['dealer_cards'].map{|c| c[0]}
    if cards.include?('A') && cards.include?('K') ||
        cards.include?('A') && cards.include?('Q') ||
        cards.include?('A') && cards.include?('J') ||
        cards.include?('A') && cards.include?('T')
      false
    end
  end
end

get '/' do
  if session['player_name']
    redirect '/game'
  else
    erb :signup
  end
end

post '/signup' do
  session['player_name'] = params['username']
  session['player_chips'] = 500
  redirect '/bet'
end

before do
  @show_player_buttons = false
  @dealer_show_one = true
end

post '/replenish' do
  session['player_chips'] = 500
  redirect '/bet'
end

get '/bet' do
  @show_none = true
  erb :game
end

post '/bet' do
  @show_none = true
  session['bet'] = params['bet'].to_i
  if session['bet'] > session['player_chips'] || session['bet'] < 1
    redirect '/bet'
  end
  session['player_chips'] -= params['bet'].to_i
  redirect '/game'
end

get '/game' do
  @show_player_buttons = true
  session['player_cards'] = []
  session['dealer_cards'] = []
  session['deck'] =
    "AJQKT98765432".chars.product("csdh".chars).map { |c| c.join }.shuffle

  2.times do
    session['player_cards'] << session['deck'].pop
    session['dealer_cards'] << session['deck'].pop
  end

  if blackjack?(session['player_cards'])
    @show_player_buttons = false
    if blackjack_beats_dealer?
      @success = "Player has Blackjack, but the dealer may still tie!"
    else
      @success = "Player has Blackjack and has won the hand!"
      @play_again_button = true
    end
  end
  erb :game
end

post '/hit' do
  @show_player_buttons = true
  session['player_cards'] << session['deck'].pop
  if eval_hand(session['player_cards']) > 21
    @play_again_button = true
    @show_player_buttons = false
    @dealer_show_one = false
    @error = "#{session['player_name']} is busted! You have #{session['player_chips']} remaining."
  end
  erb :game, layout: false
end

post '/stay' do
  @show_dealer_button = true
  @dealer_show_one = false
  run_dealer
end

post '/dealer_hit' do
  @dealer_show_one = false
  @show_dealer_button = true
  session['dealer_cards'] << session['deck'].pop
  run_dealer
end

get '/announce' do
  @play_again_button = true
  @dealer_show_one = false
  winner = winner?
  if winner == 'Tie'
    session['player_chips'] += session['bet']
    session['bet'] = 0
    @announce = "The hand is a tie."
  else
    if winner == session['player_name']
      session['player_chips'] += session['bet'] * 2
      session['bet'] = 0
    else
      session['bet'] = 0
    end
    @announce = "The winner is #{winner}! You have #{session['player_chips']} chips remaining."
  end
  # if session['player_chips'] < 1
  #   redirect '/sayoonara'
  # else
  erb :game
  #end
end

post '/sayoonara' do
  erb :sayoonara
end
