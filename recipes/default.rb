#
# Author:: Denis Barishev (<denis.barishev@gmail.com>)
# Cookbook Name:: shorewall
# Recipe:: default
#
# Copyright 2011-2013, Twiket LTD
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "shorewall::config"

# Start up the shorewall service
service "shorewall" do
  supports  [:status, :restart]
  action    case node['shorewall']['enabled'].to_s
            when 'true'
              [:start, :enable]
            else
              [:disable]
            end
end

add_shorewall_rules "match api and web servers" do
  match_nodes(
    ['search:roles:api', {:name => 'api server', :interface => 'eth0', :zone => 'lan', :public => true}],
  )
  rules({
    :description => proc {|data| "Allow #{data[:name]} access API" },
    :action => :ACCEPT,
    :source => proc {|data| "#{data[:zone]}:#{data[:matched_hosts]}"},
    :dest => :fw,
    :proto => :tcp,
    :dest_port => 8080
  })
end
