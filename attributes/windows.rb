include_attribute 'chef_nginx::default'

default['nginx']['install_method'] = 'windows' if node[:os] == 'windows'

default['nginx']['init_style'] = 'nssm' # Maybe add winsw later?


default['nginx']['windows']['version']     = '1.11.6'
default['nginx']['windows']['url']         = "http://nginx.org/download/nginx-#{node['nginx']['windows']['version']}.zip"
default['nginx']['windows']['checksum']    = '4b80ee51b3d044e49cd5d63a8f237f60a046aaf912ad7002a1b9b419f2c33480'

default['nginx']['windows']['base_dir']    = "C:/nginx"
default['nginx']['windows']['install_dir'] = ::File.join(node['nginx']['windows']['base_dir'], "nginx-#{node['nginx']['windows']['version']}")
default['nginx']['dir']                    = ::File.join(node['nginx']['windows']['install_dir'], 'conf')
default['nginx']['script_dir']             = node['nginx']['windows']['install_dir']
default['nginx']['conf_path']              = ::File.join(node['nginx']['dir'], 'nginx.conf')
default['nginx']['log_dir']                = ::File.join(node['nginx']['windows']['install_dir'], 'logs')
default['nginx']['default_root']           = ::File.join(node['nginx']['windows']['install_dir'], 'html')
default['nginx']['ulimit']                 = '1024'
default['nginx']['pid']                    = ::File.join(Dir.tmpdir, 'nginx.pid')

default['nginx']['windows']['use_existing_user'] = true
default['nginx']['reload_action'] = :restart



