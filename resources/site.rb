#
# Cookbook:: nginx
# Resource:: site
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
# Author:: Tim Smith <tsmith@chef.io>
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

provides :nginx_site

property :name, String, name_property: true
property :variables, Hash, default: {}
property :cookbook, String
property :template, String
property :enable, [String, true, false]
property :link, [true, false], default: true

action :enable do
  # this is pretty evil, but gives us backwards compat with the old
  # definition where there was an enable property vs a true action
  if new_resource.enable
    Chef::Log.warn('The "enable" property in nginx_site is deprecated. Use "action :enable" instead.')
  elsif new_resource.enable == false || new_resource.enable == 'false'
    Chef::Log.warn('The "enable" property in nginx_site is deprecated. Use "action :disable" instead.')
    action_disable
    return # don't perform the actual enable action afterwards
  end

  #Work around for https://trac.nginx.org/nginx/ticket/1144#no4
  dot_conf_if_needed = node.platform_family?('windows') ? '.conf' : ''

  # use declare_resource so we can have a property also named template
  declare_resource(:template, "#{node['nginx']['dir']}/sites-available/#{new_resource.name}#{dot_conf_if_needed}") do
    source new_resource.template
    cookbook new_resource.cookbook
    variables(new_resource.variables)
    notifies node['nginx']['reload_action'], 'service[nginx]'
    not_if { new_resource.template.nil? }
  end

  target = new_resource.name == 'default' ? "000-default#{dot_conf_if_needed}" : "#{new_resource.name}#{dot_conf_if_needed}"

  if new_resource.link
    # use declare_resource so we can have a property also named link
    declare_resource(:link, "#{node['nginx']['dir']}/sites-enabled/#{target}") do
      to "#{node['nginx']['dir']}/sites-available/#{new_resource.name}#{dot_conf_if_needed}"
      notifies node['nginx']['reload_action'], 'service[nginx]'
    end
  else
    remote_file "#{node['nginx']['dir']}/sites-enabled/#{target}" do
      source "file://#{node['nginx']['dir']}/sites-available/#{new_resource.name}#{dot_conf_if_needed}"
      notifies node['nginx']['reload_action'], 'service[nginx]'
    end
  end
end

action :disable do
  #Work around for https://trac.nginx.org/nginx/ticket/1144#no4
  dot_conf_if_needed = node.platform_family?('windows') ? '.conf' : ''
  target = new_resource.name == 'default' ? "000-default.conf" : "#{new_resource.name}#{dot_conf_if_needed}"

  file "#{node['nginx']['dir']}/sites-enabled/#{target}" do
    action :delete
    notifies node['nginx']['reload_action'], 'service[nginx]'
  end
end
