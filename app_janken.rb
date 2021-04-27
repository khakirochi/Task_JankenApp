
module HandType
  ROCK     = 0  # グー
  SCISSORS = 1  # チョキ
  PAPER    = 2  # パー
end

module Direction
  UP    = 0  # 上
  DOWN  = 1  # 下
  LEFT  = 2  # 左
  RIGHT = 3  # 右
end

HANDTYPE_NAMES  = {ROCK:"グー", SCISSORS:"チョキ", PAPER:"パー"}
DIRECTION_NAMES = {UP:"上", DOWN:"下", LEFT:"左", RIGHT:"右"}

# ジャンケンのプレイヤーを現すクラス．
class JankenGamePlayer 
  include Comparable

  # ジャンケンのプレイヤー名のシンボル
  attr_reader   :name
  # 勝者フラグ (true:勝，false:負)
  attr_accessor :is_winner
  # プレイヤーの出し手を表す正の整数
  attr_accessor :input

  def initialize(name)
    @name = name
    @is_winner = false
    @input = nil
  end

  # inputを初期化(nil)するメソッド
  def reset_input
    @input = nil
  end

  include HandType
  # ジャンケンの勝負けに対応して比較(勝>負)可能とするための演算子定義
  def <=>(other)
    players = [self, other]
    inputs = players.map(&:input)
    if inputs.any?(&:nil?)
      nil
    else
      if inputs.uniq.length==2
        case inputs.sort
        when [HandType::ROCK,     HandType::SCISSORS].sort then other.input - self.input   #0:グー   <=>  1:チョキ -> 1以上の整数を返す.
        when [HandType::SCISSORS, HandType::PAPER].sort    then other.input - self.input   #1:チョキ <=>  2:パー   -> 1以上の整数を返す.
        when [HandType::PAPER,    HandType::ROCK].sort     then self.input - other.input   #2:パー   <=>  0:グー   -> 1以上の整数を返す.
        else
          nil
        end
      else
        0 #あいこ
      end
    end
  end
end

# 各ゲームのスーパークラス
class Game
  # ゲームのプレイヤー(JankenGamePlayerのインスタンス)の配列
  attr_accessor  :players

  def initialize(players, choices)
    @players = players
    @choices = choices  # ["グー", "チョキ", "パー", "戦わない"], ["上","下","左","右"]
  end

  # ゲームを実行するメソッド
  def play
    # 実行前の処理
    preprocess
    # 掛け声
    shout
    # 結果処理
    postprocess
  end

  # 各プレイヤーが洗濯した出し手を出力するメソッド
  def print_players_choices
    puts "-----"*10
    puts @players.inject(""){|r, p| r + "#{p.name}\t : #{@choices[p.input]}\n"}
    puts "-----"*10
  end

  # 0-3の入力を要求し，入力結果の整数を返すメソッド
  def ask_input_0_3
    input_raw = gets.chomp
    until input_raw.match(/^[0-3]$/)
      puts "** 0,1,2,3のいずれかを指定してください **"
      input_raw = gets.chomp
    end
    input_raw.to_i
  end

  # プレイヤーの入力を整数形式で生成するメソッド
  def generate_input(random=false)
    raise NotImplementedError
  end

  # ゲーム開始時のメッセージを出力するメソッド
  def print_start_message
    raise NotImplementedError
  end

  # ゲーム実行前の処理を実行するメソッド
  def preprocess
    raise NotImplementedError
  end

  # ゲーム実行時の掛け声を表示するメソッド
  def shout
    raise NotImplementedError
  end

  # ゲームの結果処理を行うメソッド，ゲームのプレイヤーの勝者フラグの更新を行う
  def postprocess
    raise NotImplementedError
  end

end

# ジャンケンゲームのクラス
class JankenGame < Game
  # ジャンケンゲームの入力を生成するメソッド
  def generate_input(random=false)
    if random
      rand(0..2) # ランダムな整数入力は0-2の範囲で生成
    else
      ask_input_0_3 # それ以外の場合には0-3の範囲の入力を受け取る
    end
  end

  # ジャンケンゲーム開始時のメッセージを出力するメソッド．合わせて対応する掛け声も指定．
  def print_start_message
    if @players.map(&:input).any?(&:nil?)
      puts "じゃんけん..."      # ゲームのプレイヤーの入力が未入力(nil)の時は，ジャンケン開始時と判断
      @SHOUT_MESSAGE = "ホイ"
    else
      puts "あいこで..."    #　それ以外はあいこの状態を判断 
      @SHOUT_MESSAGE = "ショ"
    end

    # プレイヤーが指定できる出し手の選択肢を表示
    puts (@choices).each.with_index.inject(""){|r, (val, idx)| r + "#{idx}(#{val}) "}
  end

  # ジャンケンゲーム実行前の処理．
  def preprocess
    # プレイヤーから"戦わない(3)"が指定されたら終了する
    if players.map(&:input).include?(3) then exit end
  end

  # ジャンケンゲームの掛け声
  def shout
    puts @SHOUT_MESSAGE
  end

  # ジャンケンゲームの勝者フラグを更新するメソッド
  def postprocess
    # 勝者が存在する場合，どちらか一方のみの勝者フラグ(is_winner)がtrueになる
    @players[0].is_winner = (@players[0] > @players[1])
    @players[1].is_winner = (@players[0] < @players[1])
  end

end

# あっち向いてホイのクラス
class AhoiGame < Game
  # あっち向いてホイの入力を生成するメソッド
  def generate_input(random=false)
      if random
        rand(0..3)  # ランダムな整数入力は0-3の範囲で生成
      else
        ask_input_0_3 # それ以外の場合には0-3の範囲の入力を受け取る
      end
    end
  
  # あっち向いてホイ開始時のメッセージを出力するメソッド．合わせて対応する掛け声も指定．
  def print_start_message
      if @players.find{|p|p.is_winner}.name == :あなた
        your_mode = "指の向きを指定してください"
      else
        your_mode = "顔の向きを指定してください"
      end
      puts "あっち向いて〜\t(#{your_mode})"
      @SHOUT_MESSAGE = "ホイ"

    # プレイヤーが指定できる出し手の選択肢を表示
    puts @choices.each.with_index.inject(""){|res, (val, idx)| res + "#{idx}(#{val}) "}
    end
  
   # あっち向いてホイ実行前の処理．あっち向いてホイの場合には特に何も行わない
   def preprocess
      #nop
    end
  
    # あっち向いてホイの掛け声
    def shout
      puts @SHOUT_MESSAGE
    end

    # あっち向いてホイの勝者フラグを更新するメソッド 
    def postprocess
      # プレイヤーの入力が異なる場合，全プレイヤーの勝者フラグをfalseに更新する.
      inputs = @players.map(&:input)
      if inputs.uniq.length != 1
        @players.map{|p|p.is_winner = false}
      end
    end

end



# main

# ゲームのプレイヤーを生成
players = [:あなた, :相手].map{|name|JankenGamePlayer.new(name)}

# 各ゲームの出し手の選択肢
jg_choices = HandType.constants.map{|ky| HANDTYPE_NAMES[ky]} << "戦わない"  # ["グー","チョキ","パー","戦わない"]
ah_choices = Direction.constants.map{|ky| DIRECTION_NAMES[ky]}            # ["上","下","左","右"]

# 各ゲームのインスタンスを生成
jg = JankenGame.new(players, jg_choices)
ag = AhoiGame.new(players, ah_choices)


# ゲームの実行を開始.勝者となるプレイヤーが発生するまで以下のループを実行する
until players.map(&:is_winner).any?
  # 1. ジャンケン
  # 各プレイヤーが保持している入力情報を初期化
  players.map(&:reset_input)  

  # 勝者が確定するまでジャンケンを繰り返す
  until players.map(&:is_winner).any?  
    jg.print_start_message # 開始時メッセージを表示

    players.each do |p| # 各プレイヤーの入力を生成
      if p.name == :あなた
        p.input = jg.generate_input(random=false)
      else
        p.input = jg.generate_input(random=true)   # あなた以外の入力はランダムに生成 
      end
    end

    # ジャンケン実行
    jg.play
    
    # ジャンケン実行時の各プレイヤーの出力を表示
    jg.print_players_choices
  end

  # 2. あっち向いてホイ
  # 各プレイヤーが保持している入力情報を初期化
  players.map(&:reset_input)  

  # ジャンケンの勝者と敗者を取得
  jk_winner, jk_loser = players.find{|p|p.is_winner}, players.find{|p|!p.is_winner} 
  
  # 開始時メッセージを表示
  ag.print_start_message 

  # 勝者は指の向き，敗者は顔の向きを指定する
  if jk_winner.name == :あなた
    finger_direction = ag.generate_input(random=false)
    face_direction   = ag.generate_input(random=true)
  else
    finger_direction = ag.generate_input(random=true)
    face_direction   = ag.generate_input(random=false)
  end

  jk_winner.input = finger_direction
  jk_loser.input  = face_direction

  # あっち向いてホイ実行
  ag.play

  # ジャンケン実行時の各プレイヤーの出力を表示
  ag.print_players_choices

end

puts players.select{|p|p.is_winner}.inject("勝者: "){|r,p|r + p.name.to_s + ","}.chomp(",")

