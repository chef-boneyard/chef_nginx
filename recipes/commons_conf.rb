#
# Cookbook:: nginx
# Recipe:: common/conf
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright:: 2008-2016, Chef Software, Inc.
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
#

template 'nginx.conf' do
  path   "#{node['nginx']['dir']}/nginx.conf"
  source node['nginx']['conf_template']
  cookbook node['nginx']['conf_cookbook']
  notifies node['nginx']['reload_action'], 'service[nginx]', :delayed
end

template "#{node['nginx']['dir']}/sites-available/default" do
  source 'default-site.erb'
  notifies node['nginx']['reload_action'], 'service[nginx]', :delayed
end

nginx_site 'default' do
  action node['nginx']['default_site_enabled'] ? :enable : :disable
end
