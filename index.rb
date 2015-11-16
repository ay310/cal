#!/usr/bin/ruby
# coding: utf-8
require 'sqlite3'
require 'cgi'
require 'kconv'
print "Content-type: text/html\n\n"
d = Time.now

def to_min(time)
  if time == "00:00"
    return 0
  else
    arytime = time.split(':')
    return arytime[0].to_i * 60 + arytime[1].to_i
  end
end

def to_h(min)
  hour = min.to_i / 60
  min = min.to_i % 60
  hour = '0' + hour.to_s if hour < 10
  min = '0' + min.to_s if min < 10
  hour.to_s + ':' + min.to_s
end

def chday(day)
  day = '0' + day.to_s if day.to_s.length == 1
  day
end
today = d.year.to_s + '-' + chday(d.month).to_s + '-' + chday(d.day).to_s

def chint(s_data)
  idata = s_data.split('-')
  idata[0].to_s + idata[1].to_s + idata[2].to_s
end

def count(f_name)
  txt = open(f_name, 'r:utf-8')
  t_count = txt.read.count("\n")
  t_count.to_i
end

def print_t(f_name)
  txt = File.open(f_name, 'r:utf-8').readlines
  for i in 0..count(f_name) - 1
    print txt[i].to_s
  end
end

def nextday(today)
  day = today.split('-')
  if day[0] % 4 == 0 && day[0] % 100 == 0 && day[0] % 400 == 0
    # うるうどし
    month = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  else
    month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  end
  mm = day[1].to_i
  if day[2].to_i < month[mm - 1].to_i
    dd = day[2].to_i + 1
    return day[0].to_s + '-' + chday(day[1]).to_s + '-' + chday(dd).to_s
  else
    mm = day[1].to_i + 1
    return day[0].to_s + '-' + chday(mm).to_s + '-01'
  end
end

class Locate_events
  def initialize(today, inputdays)
    @today = today
    @inputdays = inputdays
  end

  def read_task
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    # データベースから
    # タスクの読み込み
    @t_num = 0
    db.execute('select * from task') do |_row|
      @t_num += 1
    end
    @t_id = Array.new(@t_num)
    @t_title = Array.new(@t_num)
    @te_day = Array.new(@t_num)
    @te_time = Array.new(@t_num)
    @tasktime = Array.new(@t_num)
    @c_tasktime = Array.new(@t_num)
    @t_imp = Array.new(@t_num)
    @t_about = Array.new(@t_num)
    @l_tasktime = Array.new(@t_num)
   @t_category = Array.new(@t_num)
    j = 0
    db.execute('select * from task order by e_day asc, e_time  asc, importance asc') do |row|
      @t_id[j] = row['id'].to_s.toutf8
      @t_title[j] = row['title'].to_s.toutf8
      @te_day[j] = row['e_day'].to_s.toutf8
      @tasktime[j] = row['t_time'].to_s.toutf8
      @te_time[j] = row['e_time'].to_s.toutf8
      @t_about[j] = row['about'].to_s.toutf8
      @t_category[j] = row['category'].to_s.toutf8
      @t_imp[j] = row['importance'].to_s.toutf8
      @c_tasktime[j] = row['time'].to_s.toutf8
      @l_tasktime[j] = row['located'].to_s.toutf8
      j += 1
    end
    db.close
  end

  def check_tasktime(id)
    #残りの作業時刻を計算してくれる
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    db.execute('select * from task where id=?', id) do |row|
      $resttime=to_min(row[4].to_s).to_i-(to_min(row[8].to_s).to_i+to_min(row[9].to_s).to_i).to_i
    end
    db.close
    return $resttime
  end

  def read_schedule
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    # データベースから
    # スケジュールの読み込み
    @num = 0
    db.execute('select * from schedule order by s_day asc, s_time asc') do |_row|
      @num += 1
    end
    @title = Array.new(@num)
    @id = Array.new(@num)
    @s_day = Array.new(@num)
    @e_day = Array.new(@num)
    @s_time = Array.new(@num)
    @e_time = Array.new(@num)
    @st = Array.new(@num)
    @category = Array.new(@num)
    @com = Array.new(@num)
    i = 0
    db.execute('select * from schedule order by s_day asc, s_time asc') do |row|
      @id[i] = row['id'].to_s.toutf8
      @title[i] = row['title'].to_s.toutf8
      @s_day[i] = row['s_day'].to_s.toutf8
      @e_day[i] = row['e_day'].to_s.toutf8
      @s_time[i] = row['s_time'].to_s.toutf8
      @e_time[i] = row['e_time'].to_s.toutf8
      @st[i] = row['st'].to_s.toutf8
      @com[i] = row['completed']
      i += 1
    end
    db.close
  end

  def read_category
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    # データベースから
    # スケジュールの読み込み
    @c_num = 0
    db.execute('select * from category') do |row|
      @c_num += 1
    end
    @c_name = Array.new(@c_num)
    @c_max = Array.new(@c_num)
    @c_min = Array.new(@c_num)
    @c_log = Array.new(@c_num)
    i = 0
    db.execute('select * from category') do |row|
      @c_name[i] = row['name'].to_s.toutf8
      @c_max[i] = row['max'].to_s.toutf8
            @c_min[i] = row['min'].to_s.toutf8
                  @c_log[i] = row['log'].to_s.toutf8
      i += 1
    end
    db.close
  end

  def read_location
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    db.execute('select * from gps order by day desc, time desc limit 1') do |row|
      @location_name=row[1].to_s
    end
    db.close
    return @location_name
 end

  def decide_s_schedule(day)
    #スケジュールを古い順に並び替えて、今日のスケジュールは
    #@num_i番目だよと教えてくれるやつ
    read_schedule
    i = 0
    while i < @num.to_i - 1
      if chint(@s_day[i].to_s).to_i - chint(day.to_s).to_i >= 0
        @num_i = i
        break
      else
        i += 1
      end
    end
    # p @num_i
  end

def decide_sday
  day=nextday(@today)
  return day
end

  def decide_eday
    day = @today
    for i in 0.. @inputdays.to_i-1
      day=nextday(day)
    end
    return day
  end

  def search_same(name, sd, st, ed, et)
    decide_s_schedule(@today)
    overlap = 0
    for i in@num_i.to_i..@num.to_i - 1
      if @title[i] == name && @s_day[i] == sd && @s_time[i] == st && @e_day[i] == ed && @e_time[i] == et
        overlap = 1
        break
      end
    end
    overlap
  end

  def overlap_event(sd, ed, st, et)
    #予定が重複していたら1, 重複してなかったら０
    read_schedule
    decide_s_schedule(sd)
    overlap = 0
    min = Array.new(1339, '0')
    if sd == ed
      for i in to_min(st).to_i..to_min(et).to_i
        min[i] = '1'
      end
    end
    for i in @num_i..@num - 1
      if @s_day[i] == sd
        for i in to_min(@s_time[i]).to_i..to_min(@e_time[i]).to_i
          overlap = 1 if min[i] == '1'
          end
      end
    end
    return overlap
  end

  def sleep_t(st, et)
    day = @today
    db = SQLite3::Database.new('scheduler.db')
    for i in 0..@inputdays.to_i - 1
      s_day = day
      e_day = nextday(day)
      if search_same('sleep', s_day, st, e_day, et) == 0
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', 'sleep', s_day, st, e_day, et, 's', '0')
      end
      day = nextday(day)
    end
    db.close
  end

  def eating_t(st, et)
    day = @today
    db = SQLite3::Database.new('scheduler.db')
    for i in 0..@inputdays.to_i - 1
      if overlap_event(day, day, st, et)==0
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', 'ごはん', day, st, day, et, 's', '0')
      else
        #ご飯イベントはないけど、スケジュールがかぶっているとき
     end
      day = nextday(day)
    end
    db.close
  end

  def add_db_task(i, s, st, et)
    #p "call add_db_task"
  	db = SQLite3::Database.new('scheduler.db')
  	db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', @t_title[i], @s_day[s], st, @s_day[s], et, @t_id[i], '0')
    if @l_tasktime[i]=="00:00"
      @l_tasktime[i]=to_h(to_min(et).to_i+to_min(st).to_i)
    else
      @l_tasktime[i]=to_h(to_min(@l_tasktime[i]).to_i + (to_min(et).to_i-to_min(st).to_i))
    end
  	db.execute('update task set located = ? where id=?', @l_tasktime[i], @t_id[i])
  	db.close
  	check_tasktime(@t_id[i])
  end

  def put_task
    #タスクのeventの追加処理
    decide_s_schedule(@today)
    #スケジュールを日付順に並べ替え、@num_i番目が今日＋１日目のスケジュール
    s=@num_i.to_i
    #@s_day[s]が今日＋１日めのスケジュール
    endday=decide_eday
    day=decide_sday
    #s_day[@num_i]~enddayまでの間にスケジュールを追加する
    read_task
    read_category
    i=0
    for j in 0.. @c_num.to_i-1
      #カテゴリテーブルのカテゴリj
      if @t_category[i]==@c_name[j]
        #現在のタスクiのカテゴリ名がカテゴリとヒットした時
        c=j
        break;
      end
    end
    #タスクiのカテゴリは@c_name[c]である
    check_tasktime(@t_id[i])
    #タスクの残り作業時刻の計測
    #$resttimeが変数
    printf("day:%s\n",day)
    printf("endday:%s\n",endday)
    until day = endday
      #startday〜enddayまでの間を探す
      if day >= chint(@s_day[@num.to_i-1]).to_i
      printf("@s_day@[%d]:%d\n", @num.to_i-1,@s_day[@num.to_i-1].to_i)
        #スケジュールがendday前に終了した場合
        #その後の日程の処理
      else
        if day > chint(@s_day[s]).to_i
          #指定日dayが、参照スケジュールsより先の日の場合
          #参照スケジュールを次のものにする
          s=s+1
        elsif day==chint(@s_day[s]).to_i
          printf("day:%s\n",day)
         printf("@s_day[%d]:%s\n",s, @s_day[s])
         #aaaa
          #i(日)にスケジュール(s)が存在する場合
          if @e_day[s]==@s_day[s+1]
            #次にも別の予定が入っている場合
            bettime=to_min(@e_time[s]).to_i-to_min(@s_time[s+1]).to_i
            #bettime=sとs+1の間の時間（分）
            if @c_max[c].to_i<=$resttime.to_i && bettime >=@c_max[c].to_i+20
              #カテゴリ最大時刻＜残作業時刻
              #スケジュール間の空き時刻>カテゴリ最大時刻+20
              st=to_h(to_min(@e_time[s]).to_i+10)
              et=to_h(to_min(st).to_i+@c_max[c].to_i)
              add_db_task(i, s, st, et)
              i=i+1
              s=s+1
            elsif @c_min[c].to_i+20<=bettime && bettime<$resttime
              p "check1-2 OK"
              #スケジュール間の時刻がタスク可能最小時刻+20より大きく
              #スケジュール間の時刻が、残タスク作業時刻より大きい場合
              st=to_h(to_min(@e_time[s]).to_i+10)
              et=to_h(to_min(@s_time[s+1]).to_i-10)
              add_db_task(i, s, st, et)
              i=i+1
              s=s+1
            elsif @c_min[c].to_i+20<=bettime && bettime>$resttime+20
              #スケジュール間の時刻がタスク最小時刻+20より大きい
              #スケジュール間の時刻が残りタスク時刻より大きい
              p "check1-3 OK"
              st=to_h(to_min(@e_time[s]).to_i+10)
              et=to_h(to_min(st).to_i+$resttime)
              add_db_task(i, s, st, et)
            elsif @c_min[c].to_i+20<=bettime
              st=to_h(to_min(@e_time[s]).to_i+10)
              et=to_h(to_min(st).to_i+bettime.to_i+10)
              add_db_task(i, s, st, et)
              i=i+1
              s=s+1
            else
              day=nextday(day)
            end
          else
            #その日に１つしか予定が入っていない場合
            #予定後にスケジュールをカテゴリMAX追加
            #多分ここはありえない
          end
        else
          #i（日）にスケジュール(s)が存在しなかった場合
          #スケジュールを追加
          #ここも多分ありえない
        end
      end
    end
  end

  def view_event
    read_schedule
    for i in 0..@num - 1
      if i != 0
        print ','
        print "\n"
      end
      print "{\n"
      print "title: '" + @title[i].to_s + "',\n"
      print "id: '" + @id[i].to_s + "',\n"
      if @s_time[i] == '00:00' && @e_time[i] == '24:00'
        print " start: '" + @s_day[i].to_s + "'"
        print ",\n"
        print " end: \'" + @e_day[i].to_s + "\'\n"
        print '}'
      else
        print " start: '" + @s_day[i].to_s + 'T' + @s_time[i].to_s + ":00'"
        print ",\n"
        print " end: '" + @e_day[i].to_s + 'T' + @e_time[i].to_s + ":00'"

        if @st[i].to_s == 's' && @com[i].to_s == ''
          print "\n"
        elsif @st[i].to_s == 's' && @com[i].to_s == '0'
          print ",\n"
          print "color: 'grey'\n"
        elsif @st[i].to_s != 's' && @com[i].to_s == '1'
          print ",\n"
          print "color: 'grey'\n"
        else @st[i].to_s != 's' && @com[i].to_s == ''
          print ",\n"
          print "color: '#cd5c5c'\n"
        end
        print '}'
     end
      i += 1
    end
  end

  def view_taskmenu
    read_task
    print_t('body1.txt')
    print "<p>現在地は"
    print read_location.to_s
    print "です</p>\n"
    print "　→<p><a href=\"add_location.rb\" alt=\"タスクの入力\">現在地の入力</a></p>\n"
    print " <p><a href=\"new_schedule.rb\">スケジュールの新規作成</a></p>\n"
    print "<p><a href=\"in_task.rb\" alt=\"タスクの入力\">タスクの新規作成</a></p>\n"
    print "<p><a href=\"edit_category.rb\">カテゴリの編集</a></p>\n"
    print "<p><a href=\"personal.rb\" alt=\"個人情報の編集\">個人情報の編集</a></p>\n"
    print "</div><br>\n"
    print "<b>||| Task</b><div class='box-lid-menulist'>\n"
    print "<FORM name=\"form1\" action=\"edit_task.rb\" onSubmit=\"return false\">\n"
    print "<INPUT type=\"hidden\" name=\"taskid\" value=\""
    print "\">"
    for i in 0..@t_num - 1.to_i
      print "<INPUT type=\"radio\" onClick=\"mySubmit('"
      print @t_id[i]
      print "')\"> "
      print '<b>' if @t_imp[i] == '3'
      print @t_title[i]
      print '</b>' if @t_imp[i] == '3'
      print ' ('
      print to_h(to_min(@tasktime[i]).to_i - to_min(@c_tasktime[i]).to_i)
      print ')'
      print "</br>\n"
      print '<div class=\'box-lid-menu-postscript\'>〆 '
      print @te_day[i]
      print ', '
      print @te_time[i]
      print '<br>'
      print @t_about[i]
      print "</div>\n"
    end
    print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\"></div>\n"
    print ' </form></div> '
    print_t('body2.txt')
  end
end

print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
print '<html xmlns="http://www.w3.org/1999/xhtml" lang="ja">'
print '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
print '<head><title>Scheduler</title>'
print_t('js1.txt')
#
# 以下、イベント追加の記述
# ユーザ設定に必要な変数
sleep_st = '22:30'
sleep_et = '08:00'
inputdays = '14'
eat_st = ['08:00', '12:00', '19:30']
eat_et = ['08:30', '13:00', '20:10']

# 翌日から２週間をタスク配置範囲とする
endday = today
today = nextday(today)
for n in 0..365
  # 14日間
  endday = nextday(endday)
end

event = Locate_events.new(today, inputdays)
event.sleep_t(sleep_st, sleep_et)
for i in 0..2
#  event.eating_t(eat_st[i], eat_et[i])
end
event.decide_s_schedule(today)
# event.overlap_event("2015-11-04", "2015-11-04", "15:00", "17:00")
event.put_task
#event.view_event
print_t('js2.txt')
print '</head>'
print '<body onLoad="sendgps()">'
event.view_taskmenu
print '</body></html>'
