#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'date'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
location = data['gps']
add_location = data['addlocation']
d = Time.now
def chday(day)
  day = '0' + day.to_s if day.to_s.length == 1
  day
end

def to_min(time)
  if time == '00:00'
    return 0
  else
    arytime = time.split(':')
    return arytime[0].to_i * 60 + arytime[1].to_i
  end
end

def define_gps(gps)
  return nil if gps==""
  location = gps.split(',')
  lat=location[0]
  lng=location[1]
  lat = lat.split("")
  lng=lng.split("")
  gps = lat[0].to_s+lat[1].to_s+lat[2].to_s+lat[3].to_s+lat[4].to_s+lat[5].to_s+","+lng[0].to_s+lng[1].to_s+lng[2].to_s+lng[3].to_s+lng[4].to_s+lng[5].to_s
  return gps
end
def same_location(gps)
  return nil if gps==""
  location = gps.split(',')
  lat=location[0]
  lng=location[1]
  lat = lat.split("")
  lng=lng.split("")
  db = SQLite3::Database.new('/Library/WebServer/CGI-Executables/cal/scheduler.db')
  $num=0
  db.execute('select * from location') do |row|
    $num += 1
  end
  $name = Array.new($num)
  $db_gps = Array.new($num)
  i = 0
  db.execute('select * from location') do |row|
    $name[i] = row[1].to_s.toutf8
    $db_gps[i] = row[2].to_s.toutf8
    i += 1
  end
    db.close

    for i in 0.. $num.to_i-1
      db_location=$db_gps[i].split(",")
      db_lat=db_location[0]
      db_lng=db_location[1]
      db_lat = db_lat.split("")
      db_lng=db_lng.split("")
      same=0
      for j in 0.. 5
        if lat[j]==db_lat[j] && lng[j]==db_lng[j]
          same =same+1
        end
      end
      if same>=5
        return $name[i].to_s
      end
    end
    return nil
  end
def search_schedule(today, t, location_name)
  db = SQLite3::Database.new('scheduler.db')
    min = Array.new(1339, '0')
    num=0
    db.execute('select * from schedule where s_day=?', today) do |row|
      st=to_min(row[3]).to_i
      et=to_min(row[5]).to_i
      id=row[0].to_i
      for i in st.to_i ..et.to_i
        min[i]=id
      end
    end
    if min[to_min(t).to_i]!=0
        db.execute('update schedule set location = ? where id=?', location_name, min[to_min(t).to_i])
    end
  db.close
end
today = d.year.to_s + '-' + chday(d.month).to_s + '-' + chday(d.day).to_s
get_time = chday(d.hour).to_s+":"+chday(d.min).to_s

db = SQLite3::Database.new('scheduler.db')
  db.execute('select * from gps order by day desc, time desc limit 1') do |row|
    $gps=row[2].to_s
    $lastday=row[3].to_s
    $lasttime=row[4].to_s
  end
db.close
location_name=same_location(location)
search_schedule(today, get_time, location_name)

p add_location,location

if location!=""
  if $lastday.to_s==today.to_s && (to_min(get_time).to_i-to_min($lasttime).to_i) <5
    #３分
    #p "same"
  else
    #p "not_same"
    db = SQLite3::Database.new('scheduler.db')
    db.execute('insert into gps  (name, position, day, time) values(?, ?, ?, ?)', location_name, location, today, get_time)
    db.close
  end
elsif add_location!=""
  db = SQLite3::Database.new('scheduler.db')
  db.execute('insert into gps  (name, position, day, time) values(?, ?, ?, ?)', add_location, $gps, today, get_time)
  new_gps=define_gps($gps)
  db.execute('insert into location  (name, gps) values(?, ?)', add_location, new_gps)
  db.close
end
print '<html>\n'
print '<head><META http-equiv="refresh"; content="0; URL=/cgi-bin/cal/index.rb"></head><body></body></html>'
