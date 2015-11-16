#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
c_name = data['c_name'].to_s.toutf8

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
i = 0
print "<div id=\"layout\">"
db.execute('select * from category') do |row|
  name[i] = row[0]
  s[i] = row[1]
  t[i] = row[2]
  location[i] = row[3]
  another[i] = row[4]
  pc[i] = row[5]
  i += 1
end
if c_name==""
  #表示画面
print "<FORM name=\"form1\" action=\"edit_category.rb\" onSubmit=\"return false\">\n"
for i in 1..num-1
    print"<p>"
  print name[i]
  print"</p>"
end
else
  #編集画面
end
print_t('edit_category5.txt')
db.close
