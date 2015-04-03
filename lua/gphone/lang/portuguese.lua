--// Portuguese language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By Mr Matthews (STEAM_0:1:52334051)

local l = gPhone.createLanguage( "portuguese-BR" )

-- General
l.title = "The Garry Phone"
l.slide_unlock = "Deslize par abrir"
l.update_check_fail = "Conexão ao site gPhone falhou, report isso no Workshop e verifique sua versao!"
l.kick = "[gPhone]: PEDIDO ILEGAL - ERRO: 0x01B4D0%s"
l.feature_deny = "A opcao selecionada ainda nao esta disponivel"
l.error = "Erro"

l.default = "Padrao"
l.language = "Lingua"
l.settings = "Ferramentas"
l.general = "Geral"
l.wallpaper = "Papel de Parede"
l.homescreen = "Tela Inicial"
l.about = "Sobre"
l.color = "Cor"

-- Homescreen
l.battery_dead = "Acabou a bateria de seu telefone! Recarregando..."
l.battery_okay = "Recarregado!"
l.service_provider = "Garry"
l.folder_fallback = "Pasta"
l.invalid_folder_name = "Invalido"

-- Tutorial
l.tut_welcome = "Bem-vindo ao Garry Phone! Esta e uma rapida introducao aos basicos deste telefone"
l.tut_folders = "Use a tela inicial para criar pastas e mover Apps come em um iPhone"
l.tut_delete = "Segure o botao direito do mouse para poder deletar apps"
l.tut_text = "Converse com seus amigos via o App de Mensagens! Click the right side to delete the conversation"
l.tut_wallpaper = "Troque o papel de parede da Tela Inicial e de Bloqueio com fotos de seu computador!"
l.tut_music = "Transmita musicas da internet ou de seu computador usando o App de Musicas!"
l.tut_translate = "Quer ajudar a traduzir? Adicione-me no Steam e voce pode estar nos creditos do gPhone!"
l.tut_coders = "Aos Coders: Chequem a wiki do Github e o App-examplo incluido para te ajudar a fazer apps!"
l.tut_end = "E isto nem chega aos pes da capacidade do gPhone. Divirta-se!!"

-- App base
l.app_error = "[Erro no App]"
l.app_deny_gm = "Este App nao esta disponivel neste modo de jogo!"
l.app_deny_group = "Voce nao esta no grupo correto para usar este App!"

-- Requests
l.confirmation = "Aviso"
l.confirm = "Confirme"
l.request = "Pedido"
l.deny = "Negar"
l.accept = "Aceitar"
l.no = "Nao"
l.yes = "Sim"
l.okay = "Okay"
l.response_timeout = "%s nao respondeu a tempo"

l.accept_fallback = "%s aceitou seu pedido para usar %s"
l.phone_accept = "%s aceitou sua chamada"
l.gpong_accept = "%s aceitou seu pedido para o gPong"

l.deny_fallback = "%s negou seu pedido para usar %s"
l.phone_deny = "%s negou sua chamada"
l.gpong_deny = "%s negou o pedido para jogar gPong"

-- Data transfer
l.transfer_fail_gm = "Nao e possivel ligar dinheiro fora do DarkRP"
l.transfer_fail_cool = "Voce deve esperar %i's para transferir mais dinheiro"
l.transfer_fail_ply = "Transacao nao concluida - Recipiente Invalido"
l.transfer_fail_amount = "Transacao nao concluida - Valor Nulo"
l.transfer_fail_generic = "Desculpe, Transacao nao concluida "
l.transfer_fail_funs = "Transacao nao concluida - Falta de Fundos" 

l.received_money = "Recebeu $%i de %s!"
l.sent_money = "Ligou $%i com %s com sucesso!"

l.text_cooldown = "Voce nao pode conversar por mais %i segundos!"
l.text_flagged = "Para previnir SPAM, voce foi bloqueado de mandar mensagens por %i segundos!"

l.being_called = "%s esta te chamando!"

-- Settings
l.wallpapers = "Papeis de Parede"
l.airplane_mode = "Modo Aviao"
l.vibrate = "Vibrar"
l.stop_on_tab = "Parar musica com tab"
l.find_album_covers = "Achar capa de album"
l.show_unusable_apps = "Mostrar apps inuteis"
l.reset_app_pos = "Resetar posicao dos icones"
l.archive_cleanup = "Limpar Arquivo"
l.file_life = "Validade (Dias)"
l.wipe_archive = "Deletar Arquivo"

l.choose_new_wp = "Escolher novo Papel de Parede"
l.wp_selector = "Seletor de Papel de Parede"
l.dark_status = "Escurecer barra de status"
l.set_lock = "Como Tela de Bloqueio"
l.set_home = "Como Tela Inicial"
l.reset_homescreen = "Quer mesmo resetar a posicao dos icones?"
l.lang_reboot_warn = "O gPhone ira reiniciar quando a lingua for trocada e confirmada"

l.no_description = "Sem Descricao"
l.install_u = "Instalar Atualizacao"
l.wipe_archive_confirm = "Quer mesmo deletar tudo no arquivo? (Nao pode ser desfeito)"
l.archive = "Arquivo"
l.update = "Atualizar"
l.set_color = "Definir Cor"

l.wipe_log_confirm = "Quer mesmo limpar o registro? Nao pode ser desfeito"
l.developer = "Desenvolvedor"
l.wipe_log = "Limpar registro"
l.dump_log = "Dump to file"
l.c_print = "Console Printing"

-- Contacts
l.contacts = "Contatos"
l.search = "Procurar"
l.back = "Voltar"
l.number = "Numero"

-- Phone
l.phone = "Telefone"
l.mute = "Sem Som"
l.unmute = "Com Som"
l.keypad = "Keypad"
l.speaker = "Speaker"
l.add = "Adicionar"
l.end_call = "Finalizar chamada"
l.cannot_call = "%s nao pode ser chamado neste momento"
l.hung_up_on = "A outra pessoa desligou a chamada"
l.invalid_player_phone = "Este nao e um numero valido!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Jogador x I.A."
l.playerplayer = "Jogador x Jogador (servidor)"
l.playerself = "Jogador x Jogador (local)"
l.easy = "Facil"
l.medium = "Medio"
l.hard = "Dificil"

l.challenge_ply = "Desafiar Jogador!"
l.gpong_self_instructions = " Jogador 1:\r\n Teclas W and S\r\n Jogador 2:\r\n Setas Cima e Baixo" 
l.start = "Inicio!"
l.resume = "Continuar"
l.quit = "Sair"
l.p1_win = "J1 venceu!"
l.p2_win = "J2 venceu!"

-- Text/Messages
l.messages = "Mensagens"
l.delete = "Deletar"
l.last_year = "Ultimo Ano"
l.yesterday = "Ontem"
l.years_ago = "Anos Atras"
l.days_ago = "Dias Atras"
l.send = "Enviar"
l.new_msg = "Nova Mensagem"
l.to = "Para:"
l.invalid_player_warn = "Este nao e um Jogador ou Numero valido"
l.message_len_warn = "Mensagem muito longa para mandar!"

-- Store
l.no_homescreen_space = "Nao ha espaco na Tela Inicial para um novo App!"
l.app_store = "App Store"
l.no_apps = "Sem Apps"
l.no_apps_phrase = "Nao ha apps disponiveis :("
l.get = "Pegar"
l.have = "Ter"

-- Music
l.music = "Musica"
l.music_format_warn = "nao e um url de musica valido! A extensao deve ser .mp3 ou .wav"
l.editor = "Editor"
l.editor_help = "* apenas o URL do som e requerido"
l.artist_name = "Artista"
l.song_name = "Musica"
l.song_url = "URL-Musica"
l.album_url = "URL-Album" 

-- Finances
l.finances = "Financas"
l.transfer = "Transferir"
l.current_user = "Usuario Atual: %s"
l.balance = "Balanco: $%s"
l.salary = "Salario: $%s"
l.wire_money = "Fundos Wire"
l.wire_invalid_player = "Alvo invalido para ligar o dinheiro!"
l.wire_invalid_amount = "Quantia Invalida para ligar o dinheiro!"
l.wire_no_money = "Nao ha dinheiro o suficiente para mandar!"
l.receiver = "Receptor"