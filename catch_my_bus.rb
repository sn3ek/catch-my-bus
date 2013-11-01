#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'notify'
require 'pp'

@big_sleep = 180
@little_sleep = 2

stations = [
  "Helmholzstrasse",
  "Münchnerplatz",
  #"Malterstraße"
]
class TramStation
  def initialize name
    @name = name
    @destinations= {}
  end

  def show
    puts @name
    puts print
  end

  def print
    string = ""
    @destinations.each{ |n,t| string << "#{n} in #{t}min\n" }
    return string
  end
  def notify
    Notify.notify @name, print()
  end

  def parse_arrival(arrival)
    arrival[2] = 0 if arrival[2] == ""
    arrival[2] = arrival[2].to_i
    @destinations["#{arrival[0]} #{arrival[1]}"] = arrival[2] if @destinations[arrival[1]].nil? or @destinations[arrival[1]] > arrival[2] 
  end

  def update
    @destinations= {}

    uri = URI URI::encode "http://widgets.vvo-online.de/abfahrtsmonitor/Abfahrten.do?ort=Dresden&hst=#{@name}&vz=0"
    JSON.parse(Net::HTTP.get(uri)).each { |a|
      parse_arrival(a)
    }
  end
end


stations.map!{ |station| TramStation.new station}
while true do
stations.each{ |station|
  station.update
  station.notify
  sleep @little_sleep
}
sleep @big_sleep
end


