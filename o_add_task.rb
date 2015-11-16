#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"

# 新規作成・編集で受け取る変数
t_id = data['t_id'].to_s
title = data['title'].to_s.toutf8
about = data['about'].to_s.toutf8
e_time = data['e_time'].to_s.toutf8
e_day = data['e_day'].to_s.toutf8
e_time = '24:00' if e_time == ''
t_time = data['t_time'].to_s.toutf8
category = data['category'].to_s.toutf8
star = data['importance'].to_s
# 削除選択時に受け取る変数
delid = data['del'].to_s
# カレンダーからの進捗管理で受け取る変数
calt_id = data['calt_id'].to_s
cals_id = data['s_id'].to_s.toutf8
cal_title = data['title'].to_s.toutf8
cal_st = data['cals_time'].to_s.toutf8
# 実際の開始時刻
cal_et = data['cale_time'].to_s.toutf8
cal_std = data['s_timed'].to_s.toutf8
# 予定上の開始時刻
cal_etd = data['e_timed'].to_s.toutf8
# 予定上の終了時刻
cal_memo = data['memo'].to_s.toutf8

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

def to_min(time)
  if time == '00:00'
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
if calt_id != ''
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  # カレンダーから来た場合
  db.execute('select * from task where id=?', calt_id) do |row|
    $c_time = row[8]
    $located = row[9]
  end
  tasktime = to_h(to_min($c_time).to_i + to_min(cal_et).to_i - to_min(cal_st).to_i)
  db.execute('update task set time =?  where id=?', tasktime, calt_id)
  plan_t = to_h(to_min($located).to_i - (to_min(cal_etd).to_i - to_min(cal_std).to_i))
  db.execute('update task set located =?  where id=?', plan_t, calt_id)
  db.execute('update schedule set completed =?  where id=?', '1', cals_id)
  db.execute('update schedule set s_time =?  where id=?', cal_st, cals_id)
  db.execute('update schedule set e_time =?  where id=?', cal_et, cals_id)
  db.close
  print '<html>\n'
  print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
else
  if delid != ''
    # 削除ボタンが押された時
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    db.execute('delete from task where id=?', delid)
    db.execute('delete from schedule where st=?', delid)
    db.close
    print '<html>\n'
    print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
  else
    # delが空
    if t_id != '' && category != 'no_name'
      # 既存タスクの編集の時
      db = SQLite3::Database.new('scheduler.db')
      db.results_as_hash = true
      db.execute('update task set title =?  where id=?', title, t_id)
      db.execute('update task set e_time =?  where id=?', e_time, t_id)
      db.execute('update task set e_day =?  where id=?', e_day, t_id)
      db.execute('update task set t_time =?  where id=?', t_time, t_id)
      db.execute('update task set about =?  where id=?', about, t_id)
      db.execute('update task set category =?  where id=?', category, t_id)
      db.execute('update task set importance =?  where id=?', star, t_id)
      db.close
    else
      if category == 'no_name'
        # カテゴリが新規作成の時
        db = SQLite3::Database.new('scheduler.db')
        db.results_as_hash = true
        print_t('in_task1.txt')
        print " <div align=\"center\"><p>タスク入力</p></div> \n"
        print "<br><br><div id = \"main\" style=\"float:left;\"> \n"
        print "<form action=\"/cgi-bin/cal/add_task.rb\" method=\"post\">\n "
        print "<input type=\"hidden\" name=\"t_id\" value=\""
        print t_id
        print "\">"
        print '  <label>件名：</label> '
        print "  <input type=\"text\" name=\"title\" size=\"20\" value=\""
        print title
        print "\">"
        print '  <br><label>締切：</label> '
        print "  <input id=\"e_day\" type=\"text\" name=\"e_day\" value=\""
        print e_day
        print "\">"
        print "  <input id=\"e_time\" type=\"text\" name=\"e_time\" value=\""
        print e_time
        print "\"><br>"
        print '    <label>時間：</label>'
        print "  <input id=\"t_time\" type=\"text\" name=\"t_time\" value=\""
        print t_time
        print "\"><p>\n"
        print '<label>カテゴリ：</label>'
        print "  <input type=\"text\" name=\"category\" size=\"20\" value=\"新規カテゴリ名\"><br>\n "
        print "<div class=\"hoge\">"
        print '<ul>'
        print "<li><input type=\"radio\" name=\"importance\" value=\"1\""
        print " checked=\"checked\"" if star == '1'
        print '><br>1</li>'
        print "<li><input type=\"radio\" name=\"importance\" value=\"2\""
        print " checked=\"checked\"" if star == '2'
        print '><br>2</li>'
        print "<li><input type=\"radio\" name=\"importance\" value=\"3\""
        print " checked=\"checked\"" if star == '3'
        print '><br>3</li>'
        print '</ul></div>'
        print '  <label>内容：</label>'
        print "  <input type=\"text\" name=\"about\" size=\"20\" value=\"about\"><br>\n"
        print "    <input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\">\n"
        print '</p></form></div>'
        print_t('in_task3.txt')
        print "  $('#t_time').datetimepicker({	datepicker:false,	format:'H:i',	value:'"
        print t_time
        print "', step:15});"
        print "$('#e_time').datetimepicker({	datepicker:false,	format:'H:i',	value:'"
        print e_time
        print "', step:5});"
        print "\$(\'#e_day\').datetimepicker({	lang:\'jp\',\n"
        print	"timepicker:false,	value: '"
        print e_day
        print "',	format:'Y-m-d',	formatDate:'Y/m/d',});\n"
        print_t('in_task4.txt')
        db.close
        print '<html>\n'
        print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
      else
        db = SQLite3::Database.new('scheduler.db')
        db.results_as_hash = true
        # 新規カテゴリを選択肢なかった場合 or 新規カテゴリを入力した場合
        found = 0
        # カテゴリが新規に作成されたものなら０、違うなら１
        db.execute('select * from category where name=?', category) do |row|
          $c_schedule = row[1]
          $c_task = row[2]
          found = 1
        end
        db.close
        if found == 0
          # カテゴリが新規（フラグが立たなかった）時
          db = SQLite3::Database.new('scheduler.db')
          db.results_as_hash = true
            db.execute('insert into category  (name, s, t) values(?, ?, ?)', category, '0', '1')
          db.close
        else
          # カテゴリがあったが、スケジュールで作成されたタスクだった場合
          db = SQLite3::Database.new('scheduler.db')
          db.results_as_hash = true
          db.execute('update category set t =?  where name=?', '1', category)
          db.close
        end
        db = SQLite3::Database.new('scheduler.db')
        db.results_as_hash = true
          db.execute('insert into task  (title, e_time, e_day, t_time, about, category, importance, time, located) values(?, ?, ?, ?, ?, ?, ?, ?, ?)', title, e_time, e_day, t_time, about, category, star, '00:00', '00:00')
          db.close
          print '<html>\n'
          print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
        end
      end
   end
  end
