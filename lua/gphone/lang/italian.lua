--// Italian language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By le otaku (STEAM_0:1:59430965)

local l = gPhone.createLanguage( "italiano" )

-- General

l.title = "The Garry Phone"

l.slide_unlock = "trascina per sbloccare"

l.update_check_fail = "la connessione al sito del gphone è fallita, per favore segnalalo sulla pagina del workshop e verifica la tua versione!"

l.kick = "[gPhone]: ILLEGAL REQUEST - ERROR: 0x01B4D0%s"

l.feature_deny = "la funzione selezionata non è ancora stata implementata"

l.error = "errore"



l.default = "predefinito"

l.language = "lingua"

l.settings = "opzioni"

l.general = "generali"

l.wallpaper = "sfondi"

l.homescreen = "schermata principale"

l.about = "informazioni"

l.color = "colore"



-- Homescreen

l.battery_dead = "il tuo telefono si è scaricato e spento! caricamento..."

l.battery_okay = "ricaricato!"

l.service_provider = "Garry"

l.folder_fallback = "cartella"

l.invalid_folder_name = "non valido"



-- Tutorial

l.tut_welcome = "benvenuto al Garry Phone! questa è una breve introduzione riguardante le basi del telefono"

l.tut_folders = "Usa la schermata principale per creare cartelle e spostare app come sul vero iphone"

l.tut_delete = "tieni premuto il pulsante destro del mouse per attivare la modalità cancellatrice"

l.tut_text = "messaggia i tuoi amici in gioco usando l'app messaggi! clicca sulla parte destra per cancellare la conversazione"

l.tut_wallpaper = "cambia gli sfondi della tua schermata principale e di blocco usando immaggini dal tuo computer"

l.tut_music = "trasmetti musica da internet o dal tuo computer con l'app musica!"

l.tut_translate = "vuoi aiutare a tradurre? aggiungimi su steam e potrai essere nei crediti del telefono!"

l.tut_coders = "codificatori: controllate la wiki su Github e l'app campione inclusa per aiutarti a fare apps"

l.tut_end = "queste sono solo poche delle funzioni del telefono. buon divertimento!!"



-- App base

l.app_error = "[errore app]"

l.app_deny_gm = "questa app non può essere utilizzata in questa modalità!"

l.app_deny_group = "non sei nel gruppo giusto per usare quest'app!"



-- Requests

l.confirmation = "conferma"

l.confirm = "conferma"

l.request = "richiesta"

l.deny = "rifiuta"

l.accept = "accetta"

l.no = "No"

l.yes = "si"

l.okay = "Okay"

l.response_timeout = "%s non ha risposto alla tua richiesta in tempo"



l.accept_fallback = "%s ha accettato la tua richiesta per usare %s"

l.phone_accept = "%s ha accettato la tua chiamata"

l.gpong_accept = "%s ha accettato la tua richiesta di giocare a gpong"



l.deny_fallback = "%s ha rifiutato la tua richiesta di usare %s"

l.phone_deny = "%s ha rifiutato la tua chiamata"

l.gpong_deny = "%s ha rifiutato la tua richiesta di giocare a gpong"



-- Data transfer

l.transfer_fail_gm = "non è possibile collegare i soldi in modalità che non sono DarkRP wire money in gamemodes that are not DarkRP"

l.transfer_fail_cool = "devi aspettare %i's prima di poter trasferire altri soldi"

l.transfer_fail_ply = "incapace di completare la transizione - destinatario non valido"

l.transfer_fail_amount = "incapace di completare la transizione - importo nullo"

l.transfer_fail_generic = "incapace di completare la transizione, spiacente"

l.transfer_fail_funs = "incapace di competare la transizione - fondi insufficienti" 



l.received_money = "ricevuti $%i da %s!"

l.sent_money = "collegati $%i a %s con successo!"



l.text_cooldown = "non puoi messaggiare per %i secondi!"

l.text_flagged = "per prevenire spam, sei stato bloccato a messaggiare per %i secondi!"



l.being_called = "%s ti stà chiamando!"



-- Settings

l.wallpapers = "sfondi"

l.airplane_mode = "modalità aereo"

l.vibrate = "vibrazione"

l.stop_on_tab = "arresta musica"

l.find_album_covers = "trova copertine album"

l.show_unusable_apps = "mostra app inutilizzabili"

l.reset_app_pos = "resetta icone"

l.archive_cleanup = "pulizia archivio"

l.file_life = "vita archivio (giorni)"

l.wipe_archive = "pulisci archivio"



l.choose_new_wp = "scegli nuovo sfondo"

l.wp_selector = "selettore sfondi"

l.dark_status = "scurisci barra dello stato"

l.set_lock = "stabilisci schermata di blocco"

l.set_home = "stabilisci schermata principale"

l.reset_homescreen = "sei sicuro di voler resettare le posizioni delle icone nella schermata principale?"

l.lang_reboot_warn = "il gphone siriavvierà quando la lingua è cambiata e confermata"



l.no_description = "nessuna descrizione fornita"

l.install_u = "installa update"

l.wipe_archive_confirm = "sei sicuro di voler cancellare tutti i file nell'archivio? (non può essere disfatto)"

l.archive = "archivio"

l.update = "Update"

l.set_color = "stabilisci colore"



l.wipe_log_confirm = "sei sicuro di voler cancellare il registro? non può essere disfatto"

l.developer = "sviluppatore"

l.wipe_log = "cancella registro"

l.dump_log = "sposta su file"

l.c_print = "stampa console"



-- Contacts

l.contacts = "contatti"

l.search = "cerca"

l.back = "indietro"

l.number = "numero"



-- Phone

l.phone = "telefono"

l.mute = "muta"

l.unmute = "unmuta"

l.keypad = "tastiera"

l.speaker = "altoparlante"

l.add = "aggiungi"

l.end_call = "termina chiamata"

l.cannot_call = "%s non può essere chiamato in questo momento! spiacente"

l.hung_up_on = "la tua chiamata è stata terminata dalla persona che stavi chiamando"

l.invalid_player_phone = "quello non è un valido numero da chiamare!"



-- Pong

l.gpong = "gpong"

l.playerbot = "giocatore contro Bot"

l.playerplayer = "giocatore contro giocatore"

l.playerself = "giocatore contro se stesso"

l.easy = "facile"

l.medium = "medio"

l.hard = "difficile"



l.challenge_ply = "sfida giocatore!"

l.gpong_self_instructions = " Player 1:\r\n W e S\r\n Player 2:\r\n Up e Down arrow keys" 

l.start = "inizio!"

l.resume = "riprendere"

l.quit = "esci"

l.p1_win = "P1 vince!"

l.p2_win = "P2 vince!"



-- Text/Messages

l.messages = "messaggi"

l.delete = "cancella"

l.last_year = "l'anno scorso"

l.yesterday = "ieri"

l.years_ago = "anni fa"

l.days_ago = "giorni fa"

l.send = "invia"

l.new_msg = "nuovo messaggio"

l.to = "a:"

l.invalid_player_warn = "quello non è un giocatore valido o un numero a cui inviare un messaggio"

l.message_len_warn = "quel messaggio è troppo lungo per essere inviato!"



-- Store

l.no_homescreen_space = "non hai abbastanza spazio nella schermata principale per aggiungere una nuova app!"

l.app_store = "App Store"

l.no_apps = "nessuna app"

l.no_apps_phrase = "non ci sono app disponibili, scusa :("

l.get = "prendere"

l.have = "possedere"



-- Music

l.music = "musica"

l.music_format_warn = "quell url non è valido! l'estenzione del file dovrebbe essere .mp3 o .wav"

l.editor = "editore"

l.editor_help = "* solo l url della canzone è richiesto"

l.artist_name = "nome artista"

l.song_name = "nome del brano"

l.song_url = "url brano"

l.album_url = "url album" 



-- Finances

l.finances = "finanza"

l.transfer = "trasferimento"

l.current_user = "utente corrente: %s"

l.balance = "saldo: $%s"

l.salary = "salario: $%s"

l.wire_money = "fondi collegati"

l.wire_invalid_player = "obbiettivo a cui collegare soldi non valido!"

l.wire_invalid_amount = "importo di soldi da collegare non valido!"

l.wire_no_money = "non hai abbastanza soldi da inviare!"

l.receiver = "ricevente"