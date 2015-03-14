--// Swedish language translations
-- Letters prefixed with a '%' (ex: %s, %i) are for formatted strings, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By Donkie (https://github.com/Donkie)

local l = gPhone.createLanguage( "svensk" )

-- General
l.title = "The Garry Phone"
l.slide_unlock = "drag för att låsa upp"
l.update_check_fail = "Kopplingen till gPhone-sidan har tappats, vänligen rapportera detta på Workshop sidan och kontrollera din version!"
l.kick = "[gPhone]: OTILLÅTEN FÖRFRÅGAN - FELKOD: 0x01B4D0%s"
l.feature_deny = "Den valda tjänsten har inte lags till än"
l.error = "Fel"

l.default = "Default"
l.language = "Language"
l.settings = "Inställningar"
l.general = "Allmänt"
l.wallpaper = "Bakgrund"
l.homescreen = "Hemskärm"
l.about = "Om"
l.color = "Färger"

-- Homescreen
l.battery_dead = "Din mobils batteri har tagit slut! Laddar..."
l.battery_okay = "Fulladdad!"
l.service_provider = "Garry"
l.folder_fallback = "Mapp"
l.invalid_folder_name = "Otillåtet Mappnamn"

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
l.app_error = "[Appfel]"
l.app_deny_gm = "Den här appen kan inte användas i denna speltyp!"
l.app_deny_group = "Du är inte i korrekt grupp för att använda denna app!"

-- Requests
l.confimation = "Bekräftan"
l.confirm = "Confirm"
l.request = "Förfrågan"
l.deny = "Neka"
l.accept = "Godkänn"
l.no = "Nej"
l.yes = "Ja"
l.okay = "Okej"
l.response_timeout = "%s did not respond to your request in time"

l.accept_fallback = "%s har accepterat din förfrågan att använda %s"
l.phone_accept = "%s har svarat på ditt samtal"
l.gpong_accept = "%s har godkänt din förfrågan att spela gPong"

l.deny_fallback = "%s har nekat din förfrågan att använda %s"
l.phone_deny = "%s har nekat ditt samtal"
l.gpong_deny = "%s har nekat din förfrågan att spela gPong"

-- Data transfer
l.transfer_fail_gm = "Du kan endast skicka pengar om speltypen är DarkRP"
l.transfer_fail_cool = "Du måste vänta %i sekunder innan du kan skicka mer pengar"
l.transfer_fail_ply = "Transaktionsfel - Ogiltig mottagare"
l.transfer_fail_amount = "Transaktionsfel - Ogiltigt belopp"
l.transfer_fail_generic = "Kunde tyvärr inte slutföra transaktionen"
l.transfer_fail_funs = "Transaktionsfel - Inte tillräckligt med pengar" 

l.received_money = "Mottagit $%i från %s!"
l.sent_money = "Skickade $%i till %s!"

l.text_cooldown = "Du måste vänta %i sekunder innan du kan skicka SMS igen!"
l.text_flagged = "Du blockerad från att skicka SMS i %i sekunder på grund av spam!"

l.being_called = "%s ringer dig!"

-- Settings
l.wallpapers = "Wallpapers"
l.airplane_mode = "Airplane Mode"
l.vibrate = "Vibrate"
l.stop_on_tab = "Stop music on tab"
l.find_album_covers = "Find album covers"
l.show_unusable_apps = "Visa oanvändbara appar"
l.reset_app_pos = "Nollställ ikonpositioner"
l.archive_cleanup = "Arkivstädning"
l.file_life = "Fillivstid (dagar)"
l.wipe_archive = "Arkivrensning"

l.choose_new_wp = "Välj ny bakgrund"
l.wp_selector = "Bakgrundsväljare"
l.dark_status = "Tona ned statusfältet"
l.set_lock = "Välj låsskärm"
l.set_home = "Välj hemskärm"
l.reset_homescreen = "Är du säker att du vill nollställa hemskärmens ikonpositioner?"
l.lang_reboot_warn = "The gPhone will reboot when the language is changed and confirmed"

l.no_description = "Ingen beskrivning"
l.install_u = "Installera uppdatering"
l.wipe_archive_confirm = "Är du säker på att du vill rensa alla filer från ditt arkiv? (kan ej bli ogjort)"
l.archive = "Arkiv"
l.update = "Uppdatering"
l.set_color = "Set Color"

l.wipe_log_confirm = "Are you sure you want to wipe the log? This cannot be undone"
l.developer = "Developer"
l.wipe_log = "Wipe log"
l.dump_log = "Dump to file"
l.c_print = "Console Printing"

-- Contacts
l.contacts = "Kontakter"
l.search = "Sök"
l.back = "Tillbaka"
l.number = "Nummer"

-- Phone
l.phone = "Phone"
l.mute = "Tyst"
l.unmute = "Otyst"
l.keypad = "Knappsats"
l.speaker = "Högtalare"
l.add = "Lägg till"
l.end_call = "Lägg på"
l.cannot_call = "%s cannot be called at this moment! Sorry"
l.hung_up_on = "Your call has been ended by the person you were calling"
l.invalid_player_phone = "That is not a valid number to call!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Spelare mot Dator"
l.playerplayer = "Spelare mot Spelare"
l.playerself = "Spelare mot Själv"
l.easy = "Lätt"
l.medium = "Medel"
l.hard = "Svårt"

l.challenge_ply = "Utmana Spelare!"
l.gpong_self_instructions = " Spelare 1:\r\n W och S\r\n Spelare 2:\r\n Up och Ned piltangenter" 
l.start = "Starta!"
l.resume = "Fortsätt"
l.quit = "Avsluta"
l.p1_win = "S1 vinner!"
l.p2_win = "S2 vinner!"

-- Text/Messages
l.messages = "Meddelanden"
l.delete = "Ta bort"
l.last_year = "Förra året"
l.yesterday = "Igår"
l.years_ago = "år sedan"
l.days_ago = "dagar sedan"
l.send = "Skicka"
l.new_msg = "Nytt meddelande"
l.to = "Till:"
l.invalid_player_warn = "That is not a valid player or number to send a message to"
l.message_len_warn = "That text message is too long to be sent!"

-- Store
l.no_homescreen_space = "Inte tillräckligt med plats på skärmen för att lägga till en ny app!"
l.app_store = "App Affär"
l.no_apps = "Inga appar"
l.no_apps_phrase = "Tyvärr inga appar tillgängliga"
l.get = "Hämta"
l.have = "Har"

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