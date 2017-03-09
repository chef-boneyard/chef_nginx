#
# Cookbook:: nginx
# Recipe:: default
#
# Copyright:: 2013-2017, Chef Software, Inc.
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

luajit_src_filename = ::File.basename(node['nginx']['luajit']['url'])
luajit_src_filepath = ::File.join(Chef::Config['file_cache_path'], "#{luajit_src_filename}")
luajit_extract_path = ::File.join(Chef::Config['file_cache_path'], "luajit-#{node['nginx']['luajit']['version']}")

remote_file luajit_src_filepath do
  source   node['nginx']['luajit']['url']
  checksum node['nginx']['luajit']['checksum']
end

bash 'extract_luajit' do
  cwd  ::File.dirname(luajit_src_filepath)
  code <<-EOH
    mkdir -p #{luajit_extract_path}
    tar xzf #{luajit_src_filename} -C #{luajit_extract_path}
    cd luajit-#{node['nginx']['luajit']['version']}/LuaJIT-#{node['nginx']['luajit']['version']}
    make && make install
    ldconfig
  EOH
  not_if { ::File.exist?(luajit_extract_path) }
end

node.run_state['nginx_source_env'].merge!(
  'LUAJIT_INC' => '/usr/local/include/luajit-2.0',
  'LUAJIT_LIB' => '/usr/local/lib/lua'
)
