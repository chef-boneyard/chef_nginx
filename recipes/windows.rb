#
# Cookbook Name:: nginx
# Recipe:: windows
#
# Author:: Akos Vandra (<akos@vandra.hu>)
#
# Copyright 2009-2016, Chef Software, Inc.
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
raise "#{node['platform']} is not a supported platform in the nginx::windows recipe" unless platform_family?('windows')

include_recipe 'windows'

node.normal['nginx']['binary'] = File.join(node['nginx']['windows']['install_dir'], 'nginx.exe')
node.normal['nginx']['daemon_disable'] = true

include_recipe 'chef_nginx::ohai_plugin'

directory node['nginx']['windows']['base_dir']

windows_zipfile node['nginx']['windows']['base_dir'] do
  source   node['nginx']['windows']['url']
  checksum node['nginx']['windows']['checksum']
  overwrite true

  action :unzip
  not_if { ::File.exist?(node['nginx']['windows']['install_dir']) }

  notifies node['nginx']['reload_action'], 'service[nginx]', :delayed
  notifies :reload, 'ohai[reload_nginx]', :immediately
end

include_recipe 'chef_nginx::commons_dir'
include_recipe 'chef_nginx::commons_conf'

cookbook_file "#{node['nginx']['dir']}/mime.types" do
  source 'mime.types'
  notifies node['nginx']['reload_action'], 'service[nginx]', :delayed
end


case node['nginx']['init_style']
when 'winsw'
  #include_recipe 'winsw'

  winsw 'nginx' do
    service_name 'nginx'
    basedir node['nginx']['windows']['install_dir']
    executable node['nginx']['binary']
  end

  service 'nginx' do
    supports status: true, restart: true
    action   :enable
  end
when 'nssm'
  include_recipe 'nssm'

  service 'nginx' do
    supports status: true, restart: true
    action   :nothing
  end

  nssm 'nginx' do
    program node['nginx']['binary'].gsub('/','\\')
    action :install

    params({
      'AppStdout' => ::File.join(node[:nginx][:log_dir], "nginx.out.log").gsub('/', '\\'),
      'AppStderr' => ::File.join(node[:nginx][:log_dir], "nginx.log").gsub('/', '\\'),
      'AppDirectory' => node['nginx']['windows']['install_dir'].gsub('/', '\\')
    })

    notifies :enable, "service[nginx]"
    notifies :start, "service[nginx]"
  end

else
  raise "Unsupported init style: #{node['nginx']['init_style']}"
end
