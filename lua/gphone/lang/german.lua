--// German language translations
-- Letters prefixed with a '%' (ex: %s, %i) are for formatted strings, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By Tomelyr (STEAM_0:0:9136467) for Exho :*

local l = gPhone.createLanguage( "deutsch" )

-- General
l.title = "The Garry Phone"
l.slide_unlock = "Display entsperren"
l.update_check_fail = "Die Verbindung zur gPhone Seite konnte nicht herrgestellt werden. Bitte meldet dies auf der Workshop Seite und überprüft eure Version!"
l.kick = "[gPhone]: Nicht genügend Speicher frei, um Speicher freizugeben. - ERROR: 0x01B4D0%s"
l.feature_deny = "Das gewünschte Feature is zur Zeit noch nicht implementiert."
l.error = "Error"

l.default = "Default"
l.language = "Language"
l.settings = "Einstellungen"
l.general = "Allgemein"
l.wallpaper = "Wallpaper"
l.homescreen = "Startbildschirm"
l.about = "Über uns"
l.color = "Farbe"

-- Homescreen
l.battery_dead = "Die Akkukapazität beträgt 0%. Ihr Telefon muss aufgeladen werden..."
l.battery_okay = "Akku ist voll aufgeladen!"
l.service_provider = "Garry"
l.folder_fallback = "Ordner"
l.invalid_folder_name = "Ungültiger Ordnername"

-- Tutorial
l.tut_welcome = "Welcome to the Garry Phone! This is a brief introduction about the basics of the phone"
l.tut_folders = "Use the homescreen to create folders and move around apps just like a real iPhone"
l.tut_delete = "Hold down the right mouse button to toggle app deletion mode"
l.tut_text = "Text your friends in game using the messages app! Click the right side to delete the conversation"
l.tut_wallpaper = "Change your home and lock screen wallpapers using pictures from your computer"
l.tut_music = "Stream music from the internet or off your computer with the music app!"
l.tut_translate = "Want to help translate? Add me on Steam and you could be in the phone's credits!"
l.tut_coders = "Coders: Check the wiki on Github and the example app included to help you make apps"
l.tut_end = "That only scratches the surface of the phone's features. Have fun!!"

-- App base
l.app_error = "[App Fehler]"
l.app_deny_gm = "Diese App ist nicht für diesen Gamemode geeignet!"
l.app_deny_group = "Dir fehlt die Berechtigung, diese App zu benutzen!"

-- Requests
l.confimation = "Bestätigung"
l.confirm = "Confirm"
l.request = "Anfrage"
l.deny = "Ablehnen"
l.accept = "Akzeptieren"
l.no = "Nein"
l.yes = "Ja"
l.okay = "Okay"
l.response_timeout = "%s did not respond to your request in time"

l.accept_fallback = "%s hat ihre Anfrage akzeptiert %s zu benutzen"
l.phone_accept = "%s hat ihr Gespräch angenommen"
l.gpong_accept = "%s hat ihre gPong Herrausforderung akzeptiert"

l.deny_fallback = "%s has denied your request to use %s"
l.phone_deny = "%s hat ihr Gespräch ignoniert"
l.gpong_deny = "%s hat ihre gPong Herrausforderung abgelehnt"

-- Data transfer
l.transfer_fail_gm = "Du kannst kein Geld versenden, wenn der Gamemode nicht DarkRP ist"
l.transfer_fail_cool = "Du musst %i sekunden warten, bevor du mehr Geld versenden kannst"
l.transfer_fail_ply = "Geldversand gescheitert. Empfänger nicht gefunden"
l.transfer_fail_amount = "Geldversand gescheitert - Gelbetrag ist nil"
l.transfer_fail_generic = "Geldversand gescheitert"
l.transfer_fail_funs = "Ihr Konto verfügt nicht über genug Guthaben, um diese Transaktion zu vollziehen" 

l.received_money = "Du hast %i$ von %s erhalten!"
l.sent_money = "Du hast %i$ an %s versandt!"

l.text_cooldown = "Du kannst erst in %i sekunden eine Nachricht schreiben!"
l.text_flagged = "Du wurdest für %i sekunden gesperrt, um Spam zu verhindern."

l.being_called = "%s ruft dicht an!"

-- Settings
l.wallpapers = "Wallpapers"
l.airplane_mode = "Airplane Mode"
l.vibrate = "Vibrate"
l.stop_on_tab = "Stop music on tab"
l.find_album_covers = "Find album covers"
l.show_unusable_apps = "Zeige nicht benutzbare Apps"
l.reset_app_pos = "Icon positionen zurücksetzen"
l.archive_cleanup = "Archiv aufräumen"
l.file_life = "Datenalter (in Tagen)"
l.wipe_archive = "Archiv entleeren"

l.choose_new_wp = "Wähle deinen neuen Wallpaper"
l.wp_selector = "Wallpaper auswählen"
l.dark_status = "Status Bar verdunkeln"
l.set_lock = "Setze Lockscreen"
l.set_home = "Setze Startbildschirm"
l.reset_homescreen = "Bist du sicher, dass du die Icon Positionen auf dem Startbildschirm zurücksetzen möchtest?"
l.lang_reboot_warn = "The gPhone will reboot when the language is changed and confirmed"

l.no_description = "Keine Beschreibung verfügbar"
l.install_u = "Update installieren"
l.wipe_archive_confirm = "Bist du sicher, dass du alle Datein in dem Archiv löschen möchtest?"
l.archive = "Archiv"
l.update = "Update"
l.set_color = "Set Color"

l.wipe_log_confirm = "Are you sure you want to wipe the log? This cannot be undone"
l.developer = "Developer"
l.wipe_log = "Wipe log"
l.dump_log = "Dump to file"
l.c_print = "Console Printing"

-- Contacts
l.contacts = "Kontakte"
l.search = "Suche"
l.back = "zurück"
l.number = "Nummer"

-- Phone
l.phone = "Phone"
l.mute = "Stumm schalten"
l.unmute = "Stummschaltung aufheben"
l.keypad = "Tastenfeld"
l.speaker = "Lautsprecher"
l.add = "hinzufügen"
l.end_call = "Auflegen"
l.cannot_call = "%s cannot be called at this moment! Sorry"
l.hung_up_on = "Your call has been ended by the person you were calling"
l.invalid_player_phone = "That is not a valid number to call!"

-- Pong
l.gpong = "gPong"
l.playerbot = "gegen Computer"
l.playerplayer = "gegen Mitspieler"
l.playerself = "gegen dich Selbst"
l.easy = "Einfach"
l.medium = "Schwer"
l.hard = "sehr Schwer"

l.challenge_ply = "Spieler herrausfordern!"
l.gpong_self_instructions = " Player 1:\r\n W und S\r\n Player 2:\r\n Pfeiltasten Hoch und Runter" 
l.start = "Start!"
l.resume = "Fortfahren"
l.quit = "Beenden"
l.p1_win = "P1 wins!"
l.p2_win = "P2 wins!"

-- Text/Messages
l.messages = "Nachrichten"
l.delete = "löschen"
l.last_year = "Letzes Jahr"
l.yesterday = "Gestern"
l.years_ago = "Jahre zuvor"
l.days_ago = "Tage zuvor"
l.send = "Senden"
l.new_msg = "Neue Nachricht"
l.to = "An:"
l.invalid_player_warn = "That is not a valid player or number to send a message to"
l.message_len_warn = "That text message is too long to be sent!"

-- Store
l.no_homescreen_space = "Du hast nicht genug Platz auf deinen Startbildschirm frei, um eine neue App hinzuzufügen."
l.app_store = "App Store"
l.no_apps = "Keine apps"
l.no_apps_phrase = "Es sind zur Zeit keine Apps verfügbar, Sorry :("
l.get = "Holen"
l.have = "Haben"

-- Music
l.music = "Music"
l.music_format_warn = "That is not a valid music url! The file extension should be .mp3 or .wav"
l.editor = "Editor"
l.editor_help = "* Only the song URL is required"
l.artist_name = "Artist Name"
l.song_name = "Song Name"
l.song_url = "Song Url"
l.album_url = "Album Url" 

-- Finances
l.finances = "Finances"
l.transfer = "Transfer"
l.current_user = "Current User: %s"
l.balance = "Balance: $%s"
l.salary = "Salary: $%s"
l.wire_money = "Wire Funds"
l.wire_invalid_player = "Invalid target to wire money to!"
l.wire_invalid_amount = "Invalid amount of money to wire!"
l.wire_no_money = "You do not have enough money to send!"
l.receiver = "Receiver"