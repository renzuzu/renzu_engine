fx_version 'cerulean'
game 'gta5'

lua54 'on'

shared_scripts {
	"config.lua",
  '@ox_lib/init.lua',
  'engines.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',	
	"server.lua"
}
client_scripts {
	"client.lua",
}

files {
  'audioconfig/*.dat151.rel',
  'audioconfig/*.dat54.rel',
  'sfx/**/*.awc',
  'sfx/**/*.awc',
  '*.json'
}

data_file 'AUDIO_GAMEDATA' 'audioconfig/r35sound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/r35sound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_r35sound'

data_file 'AUDIO_GAMEDATA' 'audioconfig/lambov10_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/lambov10_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_lambov10'
data_file 'AUDIO_GAMEDATA' 'audioconfig/musv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/musv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_musv8'
data_file 'AUDIO_GAMEDATA' 'audioconfig/brabus850_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/brabus850_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_brabus850'
data_file 'AUDIO_GAMEDATA' 'audioconfig/shonen_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/shonen_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_shonen'
data_file 'AUDIO_GAMEDATA' 'audioconfig/toysupmk4_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/toysupmk4_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_toysupmk4'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/rb26dett_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/rb26dett_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/rb26dett_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_rb26dett'
data_file 'AUDIO_GAMEDATA' 'audioconfig/rotary7_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/rotary7_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_rotary7'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/m297zonda_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/m297zonda_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/m297zonda_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_avesv'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_diablov12'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_f40v8'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_f50v12'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_ferrarif12'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_murciev12'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_sestov10'
data_file 'AUDIO_GAMEDATA' 'audioconfig/avesv_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/avesv_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/diablov12_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/diablov12_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/f40v8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/f40v8_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/f50v12_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/f50v12_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/ferrarif12_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/ferrarif12_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/murciev12_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/murciev12_sounds.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/sestov10_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/sestov10_sounds.dat'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/m158huayra_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/m158huayra_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/m158huayra_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_m158huayra'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/k20a_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/k20a_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/k20a_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_k20a'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/gt3flat6_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/gt3flat6_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/gt3flat6_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_gt3flat6'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/predatorv8_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/predatorv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/predatorv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_predatorv8'
data_file 'AUDIO_SYNTHDATA' 'audioconfig/p60b40_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audioconfig/p60b40_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/p60b40_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_p60b40'