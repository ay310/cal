#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
s_day = data['s_day'].to_s.toutf8
s_time = data['s_time'].to_s.toutf8
e_day = data['e_day'].to_s.toutf8
e_time = data['e_time'].to_s.toutf8
title = data['content'].to_s.toutf8
category = data['category'].to_s.toutf8
id = data['id'].to_s.toutf8
del = data['del'].to_s.toutf8
ts_time = '00:00' if ts_time == ''
te_time = '24:00' if te_time == ''
search_title = data['s_title'].to_s.toutf8

db = SQLite3::Database.new('scheduler.db')
db.results_as_hash = true
def count(f_name)
  txt = open(f_name, 'r:utf-8')
  t_count = txt.read.count("\n")
  t_count.to_i - 1
end

def print_t(f_name)
  txt = File.open(f_name, 'r:utf-8').readlines
  for i in 0..count(f_name)
    print txt[i].to_s
  end
end

if del != ''
  # 編集時、削除ボタンが押された場合
  db.execute('delete from schedule where id=?', del)
  print '<html>'
  print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
else
  if category == 'no_name'
    # カテゴリ新規作成が選択された場合、
    # もう一度変数を引き継いで、入力画面の表示
    print_t('new_schedule1.txt')
       print "<form action=\"/cgi-bin/cal/add_schedule.rb\" method=\"post\">"
       print "<input type=\"hidden\" name=\"id\" value=\""
       print id
       print "\">"
         print "<label>件名：</label>"
         print "<input type=\"text\" name=\"content\" size=\"20\" value=\""
         print title
         print "\">"
         print "<br>"
    print_t('new_schedule3.txt')
    print '<p><label>カテゴリ：</label>'
   print "<input type=\"text\" name=\"category\" size=\"20\" value=\"新規カテゴリ名\"><br>"
    print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
    print '</form></div></div></div></body>'
    print_t('new_schedule4.txt')
    print "$('#s_time').datetimepicker({" + "\n"
    print '	datepicker:false,' + "\n"
    print "	format:'H:i'," + "\n"
    print "	value:'"
    print s_time
        print "',"
    print '	step:5' + "\n"
    print '});' + "\n"
    print "$('#s_day').datetimepicker({" + "\n"
    print "	lang:'jp'," + "\n"
    print '	timepicker:false,' + "\n"
    print "	value:'"
    print s_day.to_s.chomp
    print "',"
    print "	format:'Y-m-d'," + "\n"
    print "	formatDate:'Y/m/d'," + "\n"
    print '});' + "\n"
    print "$('#e_time').datetimepicker({" + "\n"
    print '	datepicker:false,' + "\n"
    print "	format:'H:i'," + "\n"
    print "	value:'"
    print e_time
    print "',"
    print '	step:5' + "\n"
    print '});' + "\n"
    print "$('#e_day').datetimepicker({" + "\n"
    print "	lang:'jp'," + "\n"
    print '	timepicker:false,' + "\n"
    print "	value:'"
    print s_day.to_s.chomp
    print "',"
    print "	format:'Y-m-d'," + "\n"
    print "	formatDate:'Y/m/d'," + "\n"
    print '});' + "\n"
    print_t('new_schedule5.txt')
  else
    # カテゴリ＝no_nameではない場合
    # カテゴリがすでに重複しているか確認
    found = 0
    # カテゴリが新規に作成されたものなら０、違うなら１
    db.execute('select * from category where name=?', category) do |row|
      found = 1
    end
    if found == 0
      # カテゴリが新規（フラグが立たなかった）時
      db.transaction do
        db.execute('insert into category  (name, s, t) values(?, ?, ?)', category, "1", "0")
      end
    else
      #カテゴリがあったが、スケジュールで作成されたタスクだった場合
          db.execute('update category set s =?  where name=?', "1", category)
    end
    if id != ''
      # 編集時
      db.execute('update schedule set title =?  where id=?', title, id)
      db.execute('update schedule set s_day =?  where id=?', s_day, id)
      db.execute('update schedule set s_time =?  where id=?', s_time, id)
      db.execute('update schedule set e_day =?  where id=?', e_day, id)
      db.execute('update schedule set e_time =?  where id=?', e_time, id)
      db.execute('update schedule set category =?  where id=?', category, id)
      print '<html>'
      print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
    else
      db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, category) values(?, ?, ?, ?, ?, ?, ?)', title, s_day, s_time, e_day, e_time, 's', category)
      print '<html>'
      print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
    end
end
end
db.close
