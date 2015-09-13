--// Spanish language translation
-- By Geferon (STEAM_0:1:33247167)

local l = gPhone.createLanguage( "español" )

-- General
l.title = "El Telefono de Garry"
l.slide_unlock = "desliza para desbloquear"
l.update_check_fail = "La conexion al sitio de gPhone ha fallado, porfavor reporta esto y descarga este addon por workshop"
l.kick = "[gPhone]: PETICION ILEGAL	- ERROR: 0x01B4D0%s"
l.feature_deny = "La funcion seleccionada no ha sido implementada todavia"
l.error = "Error"

l.default = "Predeterminado"
l.language = "Idioma"
l.settings = "Ajustes"
l.general = "General"
l.wallpaper = "Fondo de pantalla"
l.homescreen = "Pantalla principal"
l.about = "Acerca de"
l.color = "Color"

l.phone_confis = "¡Tu telefono ha sido confiscado!"
l.unable_to_open = "No puedes abrir el gPhone en este momento"

-- Homescreen
l.battery_dead = "¡Tu telefono se ha quedado sin bateria y se ha apagado! Recargando..."
l.battery_okay = "¡Recargado!"
l.service_provider = "Garry"
l.folder_fallback = "Carpeta"
l.invalid_folder_name = "Invalido"

-- Tutorial
l.tut_welcome = "¡Bienvenido al telefono de Garry! Esta es una breve itroduccion sobre las basicas del telefono"
l.tut_folders = "Usa la pantalla de inicio para crear carpetas y moverte por aplicaciones como en un iPhone"
l.tut_delete = "Manten el boton derecho del raton para entrar en modo de desinstalacion de aplicaciones"
l.tut_text = "¡Chatea con tus amigos en el juego con la aplicacion de Chat! Dale click al lado derecho para borrar el chat"
l.tut_wallpaper = "Cambia tus fondos de pantalla con fotos de tu ordenador"
l.tut_music = "¡Pon musica de internet o de tu ordenador!"
l.tut_translate = "¿Quieres ayudar a traducir? Añademe en steam y podras estar en los creditos del telefono!"
l.tut_coders = "Coders: Mirar la wiki en Github para ver algun ejemplo y saber como hacer aplicaciones"
l.tut_end = "Esto solo te enseña las basicas de las aplicaciones del telefono. ¡Diviertete!"

-- App base
l.app_error = "[Error de Aplicacion]"
l.app_deny_gm = "¡Esta aplicacion no puede usarse en este gamemode!"
l.app_deny_group = "¡No estas en el grupo correcto para poder utilizar esta aplicaion!"

-- Requests
l.confirmation = "Confirmacion"
l.confirm = "Confirmar"
l.request = "Peticion"
l.deny = "Denegar"
l.accept = "Aceptar"
l.no = "No"
l.yes = "Si"
l.okay = "Ok"
l.response_timeout = "%s no respondio a tu petecion a tiempo"

l.accept_fallback = "%s ha aceptado tu peticion para usar %s"
l.phone_accept = "%s ha aceptado tu llamada"
l.gpong_accept = "%s ha aceptado tu peticion para jugar a gPong"

l.deny_fallback = "%s ha rechazado tu peticion para usar %s"
l.phone_deny = "%s ha rechazado tu llamada"
l.gpong_deny = "%s ha rechazado tu peticion para jugar a gPong"

-- Data transfer
l.transfer_fail_gm = "No puedes transferir dinero en gamemodes que no sean DarkRP"
l.transfer_fail_cool = "Necesitas esperar %i's antes de que puedas transferir mas dinero"
l.transfer_fail_ply = "No se puede completar la transaccion - cantidad invalida"
l.transfer_fail_amount = "No se puede completar la transaccion - cantidad nula"
l.transfer_fail_generic = "No se puede completar la transaccion, lo sentimos"
l.transfer_fail_funs = "No se puede completar la transaccion - falta de dinero" 

l.received_money = "Recivido $%i de %s!"
l.sent_money = "¡Enviado $%i a %s satisfactoriamente!"

l.text_cooldown = "¡No puedes enviar mensajes por %i segundos!"
l.text_flagged = "Para evitar spam, has sido bloqueado de enviar mensajes  por %i segundos"

l.being_called = "¡%s te esta llamando!"

-- Settings
l.wallpapers = "Fondos de pantalla"
l.airplane_mode = "Modo avion"
l.vibrate = "Vibrar"
l.stop_on_tab = "Parar la musica en tab"
l.find_album_covers = "Encontrar portadas de albums"
l.show_unusable_apps = "Enseñar apps inusables"
l.reset_app_pos = "Reiniciar posiciones de iconos"
l.archive_cleanup = "Limpiar archivo"
l.file_life = "Tiempo de archivo (dias)"
l.wipe_archive = "Borrar archivo"

l.choose_new_wp = "Escoge un nuevo fondo de pantalla"
l.wp_selector = "Selector de fondo de pantalla"
l.dark_status = "Barra de estatus negriza"
l.set_lock = "Poner pantalla de bloqueo"
l.set_home = "Poner pantalla de inicio"
l.reset_homescreen = "¿Estas seguro de que quieres reiniciar las posiciones de iconos de la pantalla de inicio?"
l.lang_reboot_warn = "El gPhone se reiniciara cuando el idioma se cambie y se confirme"

l.no_description = "Descripcion no disponible"
l.install_u = "Instalar Actualizacion"
l.wipe_archive_confirm = "¿Estas seguro que quieres borrar todos los archivos en esta carpeta? (esto no se puede deshacer)"
l.archive = "Archivo"
l.update = "Actualizar"
l.noupdate = "Tu telefono esta actualizado"
l.set_color = "Poner Color"

l.wipe_log_confirm = "¿Estas seguro de que quieres borrar el log? Esto no se puede deshacer"
l.developer = "Desarrollador"
l.wipe_log = "Limpiar log"
l.dump_log = "Mover a archivo"
l.c_print = "Imprimir en Consola"

l.binds = "Binds"
l.open_key = "Pular tecla"
l.key_hold = "Tiempo para mantener tecla"

-- Contacts
l.contacts = "Contactos"
l.search = "Buscar"
l.back = "Atras"
l.number = "Numero"

-- Phone
l.phone = "Telefono"
l.mute = "Silenciar"
l.unmute = "Des-silenciar"
l.keypad = "Teclado"
l.speaker = "Altavoz"
l.add = "Añadir"
l.end_call = "Finalizar llamada"
l.cannot_call = "¡%s no puede ser llamado en este momento! Lo siento"
l.hung_up_on = "Tu llamada ha sido finalizada por la otra persona que estabas llamando"
l.invalid_player_phone = "¡Ese no es un numero valido al que llamar!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Jugador vs Bot"
l.playerplayer = "Jugador vs Jugador"
l.playerself = "Jugador vs Self"
l.easy = "Facil"
l.medium = "Medio"
l.hard = "Dificil"

l.challenge_ply = "¡Desafiar jugador!"
l.gpong_self_instructions = " Jugador 1:\r\n W y S\r\n Jugador 2:\r\n teclas de Arriva y Abajo" 
l.start = "¡Empezar!"
l.resume = "Continuar"
l.quit = "Salir"
l.p1_win = "J1 gana!"
l.p2_win = "J2 gana!"

-- Text/Messages
l.messages = "Mensajes"
l.delete = "Borrar"
l.last_year = "Ultimo año"
l.yesterday = "Ayer"
l.years_ago = "años"
l.days_ago = "dias"
l.send = "Enviar"
l.new_msg = "Nuevo mensaje"
l.to = "Para:"
l.invalid_player_warn = "Ese no es un jugador o numero valido al cual enviar un mensaje"
l.message_len_warn = "¡El mensaje es demasiado largo para ser enviado!"

-- Store
l.no_homescreen_space = "¡No hay suficiente espacio en la pantalla principal para añadir una aplicacion!"
l.app_store = "App Store"
l.no_apps = "No hay aplicaciones"
l.no_apps_phrase = "No hay aplicaciones disponibles, lo siento :("
l.get = "Obtener"
l.have = "Tienes"

-- Music
l.music = "Musica"
l.music_format_warn = "¡Esa no es una URL valida! La extension deberia de ser .mp3 o .wav"
l.editor = "Editor"
l.editor_help = "* Solo la URL de la cancion es requerida"
l.artist_name = "Nombre de Artista"
l.song_name = "Cancion"
l.song_url = "Url de la cancion"
l.album_url = "Url de album" 

-- Finances
l.finances = "Finanzas"
l.transfer = "Transferir"
l.current_user = "Usuario actual: %s"
l.balance = "Dinero: $%s"
l.salary = "Salario: $%s"
l.wire_money = "Hacer una transferencia"
l.wire_invalid_player = "¡Jugador invalido para enviar dinero!"
l.wire_invalid_amount = "¡Cantidad de dinero invalida!"
l.wire_no_money = "¡No tienes suficiente dinero para enviar!"
l.receiver = "Receptor"

-- Flappy Garry
l.enter_play = "¡Pulsa 'enter' para jugar!"

-- Browser
l.connecting = "Conectando"