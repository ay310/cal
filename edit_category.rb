#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
c_name = data['c_name'].to_s.toutf8
edit_taskid = data['taskid'].to_s.toutf8

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
print_t('edit_category1.txt')
db = SQLite3::Database.new('scheduler.db')
num = 0
db.execute('select * from category') do |_row|
  num += 1
end

name = Array.new(num)
s = Array.new(num)
t = Array.new(num)
location = Array.new(num)
another = Array.new(num)
pc = Array.new(num)
min = Array.new(num)
max = Array.new(num)
i = 0
print "<div id=\"layout\">"
db.execute('select * from category') do |row|
  name[i] = row[0]
  s[i] = row[1]
  t[i] = row[2]
  location[i] = row[3]
  another[i] = row[4]
  pc[i] = row[5]
  max[i] = row[7]
  min[i] = row[8]
  i += 1
end
if edit_taskid.to_s==""
  if c_name==""
    #表示画面
    print "<FORM name=\"form1\" action=\"edit_category.rb\" onSubmit=\"return false\">\n"
    print"<p><input type=\"hidden\" name=\"taskid\" value=\"\">\n"
    for i in 1..num-1
      print "<input type=\"radio\" onClick=\"mySubmit('"
      print  i
      print "')\">"
      print name[i]
      print"</p>\n"
    end
    print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\"></div></form></div>"
  else
    #編集画面
    print "</body>"
  end
else
  #もしedit_tasknameが空白じゃなかったら、編集画面を出力する
  id=edit_taskid.to_i
  print "<form action=\"/cgi-bin/cal/edit_category.rb\" method=\"post\">"
  printf("<label>カテゴリ名：")
  print name[id.to_i]
  printf("</label><br>")
  printf("作業可能最小時刻\n")
  print "  <input id=\"min_time\" type=\"text\" name=\"min_time\" value=\""
  print to_h(min[id.to_i])
  print "\"><br>"
  printf("作業可能最大時刻\n")
  print "  <input id=\"max_time\" type=\"text\" name=\"max_time\" value=\""
  print to_h(max[id.to_i])
  print "\"><br>\n"
  printf("ロケーション指定\n")
  print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
  print '</form>'

  print_t("edit_category3.txt")

  print "  $('#min_time').datetimepicker({\n"
  print "datepicker:false,\n"
  print"	format:'H:i',\n"
  print"	value:'"
  print to_h(min[id])
  print "',\n step:5\n});\n"
  print "$('#max_time').datetimepicker({\n"
  print " datepicker:false,\n"
  print " format:'H:i',\n"
  print "value:'"
  print to_h(max[id])
  print "',\n step:5\n});\n"
  print "</script>\n"
    end
print_t('edit_category5.txt')
db.close
