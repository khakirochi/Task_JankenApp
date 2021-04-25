require 'set'

class Game
  #ゲームモード :jnk(ジャンケン), :aho(あっち向いてホイ)
  attr_accessor :mode
  #勝者 :player(自分), :opponent(相手), :even(引き分け)
  attr_reader   :winner

  HANDSHAPE  = ["グー", "チョキ", "パー"]
  DIRECTION  = ["上", "下", "左", "右"]

  def initialize
    @mode        = :jnk
    @palyer_in   = nil
    @opponent_in = nil
    @winner = nil
  end

  #対戦(ジャンケン/あっち向いてホイ)を1回実行する
  def play
    print_start_message
    set_in

    if @mode.equal?(:jnk) && @palyer_in == 3 then exit end
    
    print_shout
    judge
    print_result
  end

  #自分と相手の入力を設定する．
  def set_in
    palyer_in_raw = gets.chomp
    until palyer_in_raw.match(/^[0-3]$/)
      puts "** 0,1,2,3のいずれかを指定してください **"
      palyer_in_raw = gets.chomp
    end
    
    @palyer_in = palyer_in_raw.to_i

    @opponent_in = 
      case mode 
      when :jnk then rand(0..2)
      when :aho then rand(0..3)
      else nil
      end
  end

  #勝者の判定を行い，@winnerを更新する．
  def judge
    if @mode.equal?(:jnk)
      inputs = {player: @palyer_in, opponent: @opponent_in}
      if inputs.values.uniq.length == 2
        case inputs.values.to_set
        when Set[0,1] then @winner = inputs.key(0)  #0:グー,    1:チョキ
        when Set[1,2] then @winner = inputs.key(1)  #1:チョキ,  2:パー
        when Set[2,0] then @winner = inputs.key(2)  #2:パー,    0:グー
        else @winner = nil
        end
      else
        @winner = :even
      end
    end

    if @mode.equal?(:aho)
      if @palyer_in != @opponent_in
        @winner = nil
      end
    end
  end

  #対戦開始時のメッセージを表示する．
  def print_start_message
    if @mode.equal?(:jnk)
      if @winner.equal?(:even)
        puts "あいこで..."
      else
        puts "じゃんけん..."
      end
      puts "0(#{HANDSHAPE[0]}) 1(#{HANDSHAPE[1]}) 2(#{HANDSHAPE[2]}) 3(戦わない) "
    end

    if @mode.equal?(:aho)
      puts "あっち向いて〜"
      puts "0(#{DIRECTION[0]}) 1(#{DIRECTION[1]}) 2(#{DIRECTION[2]}) 3(#{DIRECTION[3]})"
    end
  end


  #対戦結果を表示する．
  def print_result
    puts "--------------------------------------"
    if @mode.equal?(:jnk)
      puts "あなた  : #{(0..2).include?(@palyer_in) ? HANDSHAPE[@palyer_in] : "?"}を出しました"
      puts "相手　  : #{HANDSHAPE[@opponent_in]}を出しました"
    end
    if @mode.equal?(:aho)
      puts "あなた  : #{(0..3).include?(@palyer_in) ? DIRECTION[@palyer_in] : "?"}"
      puts "相手　  : #{DIRECTION[@opponent_in]}"
    end
    puts "--------------------------------------"
  end

  #対戦実行時の掛け声を表示する．
  def print_shout
    if @winner.equal?(:even)
      puts "ショ！"
    else
      puts "ホイ！"
    end
  end

  #勝者を表示する．
  def print_winner
    case @winner
    when :player   then puts "あなたの勝ちです．"
    when :opponent then puts "相手の勝ちです．"
    else put "(勝者不明です)" 
    end
  end

end

#main
game = Game.new

while game.winner.nil?
  #ジャンケンを1回実行
  game.mode = :jnk
  game.play   #expected winner: player/opponent/even.

  #ジャンケンの勝負がつかない場合，勝負が着くまでジャンケンを実行
  while game.winner.equal?(:even) || game.winner.nil?
    game.play
  end

  #あっち向いてホイを実行
  game.mode = :aho
  game.play  #expected winner:  player/opponent/nil.
end

#最終的な勝者を表示
game.print_winner





