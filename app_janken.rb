require 'set'

module HandType
  ROCK     = 0
  PAPER    = 1
  SCISSORS = 2
end

module Direction
  UP    = 0
  DOWN  = 1
  LEFT  = 2 
  RIGHT = 3
end

class JankenGamePlayer 
  include Comparable
  include HandType

  attr_accessor :is_winner
  attr_accessor :input

  def initialize
    @is_winner = false
    @input = nil
  end

  def <=>(other)
    players = [self, other]
    inputs = players.map(&:input)

    if inputs.any?(&:nil?)
      nil
    else
      if inputs.uniq.length==2
        case inputs.to_set
        when Set[HandType::ROCK,     HandType::SCISSORS] then self.input  - other.input  #0:グー,    1:チョキ
        when Set[HandType::SCISSORS, HandType::PAPER]    then other.input - self.input   #1:チョキ,  2:パー
        when Set[HandType::PAPER,    HandType::ROCK]     then other.input - self.input   #2:パー,    0:グー
        else nil
        end
      else
        0 #あいこ
      end
    end
  end
end

class Game
  attr_accessor  :players

  def play
    preprocess
    shout
    postprocess
  end

  def reset_inputs
    @players.map{|p|p.input = nil}
  end
  
  def ask_input_0_3
    input_raw = gets.chomp
    until input_raw.match(/^[0-3]$/)
      puts "** 0,1,2,3のいずれかを指定してください **"
      input_raw = gets.chomp
    end
    input_raw.to_i
  end

  def generate_input(auto=false)
    raise NotImplementedError
  end

  def print_start_message
    raise NotImplementedError
  end

  def preprocess
    raise NotImplementedError
  end

  def print_shout
    raise NotImplementedError
  end

  def postprocess
    raise NotImplementedError
  end

  def print_result
    raise NotImplementedError
  end

end

class JankenGame < Game
  include HandType
  HANDTYPE_NAMES = {ROCK:"グー", PAPER:"チョキ", SCISSORS:"パー"}

  attr_reader :SHOUT_MESSAGE

  def generate_input(auto=false)
    if auto
      rand(0..2)
    else
      ask_input_0_3
    end
  end

  def print_start_message
    if @players.map(&:input).any?(&:nil?)
      puts "じゃんけん..."
      @SHOUT_MESSAGE = "ホイ"
    else
      puts "あいこで..."
      @SHOUT_MESSAGE = "ショ"
    end

    choises = HandType.constants.map{|key|HANDTYPE_NAMES[key]} << "戦わない"
    puts choises.each.with_index.inject(""){|res, (val, idx)| res + "#{idx}(#{val}) "}
  end

  def preprocess
    if players[0].input == 3 then exit end
  end

  def shout
    puts @SHOUT_MESSAGE
  end

  def postprocess
    @players[0].is_winner = (@players[0] > @players[1])
    @players[1].is_winner = (@players[0] < @players[1])
  end

  def print_result
    puts "--------------------------------------"
    puts "あなた  : #{HANDTYPE_NAMES[HandType.constants[players[0].input]]}を出しました"
    puts "相手　  : #{HANDTYPE_NAMES[HandType.constants[players[1].input]]}を出しました"
  puts "--------------------------------------"
  end
end

class AhoiGame < Game
    include Direction
    
    attr_reader :SHOUT_MESSAGE
    DIRECTION_NAMES = {UP:"上", DOWN:"下", LEFT:"左", RIGHT:"右"}
    
    def generate_input(auto=false)
      if auto
        rand(0..3)
      else
        ask_input_0_3
      end
    end
  
    def print_start_message
      puts "あっち向いて〜"
      @SHOUT_MESSAGE = "ホイ"

      choises = Direction.constants.map{|key|DIRECTION_NAMES[key]}
      puts choises.each.with_index.inject(""){|res, (val, idx)| res + "#{idx}(#{val}) "}
    end
  
    def preprocess
      #nop
    end
  
    def shout
      puts @SHOUT_MESSAGE
    end
  
    def postprocess
      inputs = @players.map(&:input)
      if inputs.uniq.length != 1
        @players.map{|p|p.is_winner = false}
      end
    end
  
    def print_result
      puts "--------------------------------------"
      puts "あなた  : #{DIRECTION_NAMES[Direction.constants[players[0].input]]}"
      puts "相手　  : #{DIRECTION_NAMES[Direction.constants[players[1].input]]}"
    puts "--------------------------------------"
    end
end



#main

#games
jg = JankenGame.new
ag = AhoiGame.new

#players
p0 = JankenGamePlayer.new  # your player
p1 = JankenGamePlayer.new  # opponent player

#set game players
players = [p0, p1]
jg.players = ag.players = players

#do 
until players.map(&:is_winner).any?
  #reset players' inputs
  p0.input, p1.input = nil, nil

  until players.map(&:is_winner).any?
    jg.print_start_message

    p0.input = jg.generate_input(auto=false)
    p1.input = jg.generate_input(auto=true)

    puts "p0.input = #{p0.input}"
    puts "p1.input = #{p1.input}"
    puts "p0<=>p1 = #{p0<=>p1}"
    
    jg.play
    
    jg.print_result
  end

  puts "p0.is_winner = #{p0.is_winner}"
  puts "p1.is_winner = #{p1.is_winner}"

  ag.print_start_message

  finger_direction, face_direction = nil, nil
  if p0 > p1
    finger_direction = ag.generate_input(auto=false)
    face_direction   = ag.generate_input(auto=true)

    p0.input = finger_direction
    p1.input = face_direction
  elsif p0 < p1
    finger_direction = ag.generate_input(auto=true)
    face_direction   = ag.generate_input(auto=false)

    p0.input = face_direction
    p1.input = finger_direction
  end

  ag.play
  ag.print_result

end

if p0.is_winner && !p1.is_winner
  puts "あなたの勝ちです"
elsif !p0.is_winner && p1.is_winner
  puts "相手の勝ちです"
else
  puts "(勝者不明です)"
end

