fx_version 'cerulean'
game 'gta5'

author 'stijnjw & pietjepeksf'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'nui/index.html'

files {
    "nui/*"
}

lua54 'yes'
escrow_ignore {
    '*'
}
