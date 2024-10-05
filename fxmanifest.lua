fx_version 'cerulean'

game 'gta5'

lua54 "yes"

version '1.0.0'

description "NUI Postal map"

ui_page 'web/index.html'

files {
	'web/css/*.css',
	'web/js/*.js',
	'web/index.html'
}

client_scripts {
    'config.lua',
    'client/postal.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/postal.lua'
}

file('data/new-postals.json')
postal_file('data/new-postals.json')