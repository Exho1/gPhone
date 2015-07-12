--// Swedish language translations
-- Letters prefixed with a '%' (ex: %s, %i) are for formatted strings, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By Donkie (https://github.com/Donkie)

local l = gPhone.createLanguage( "svensk" ) --should be svenska, but causes errors

-- General
l.title = "Garry Telefonen"
l.slide_unlock = "dra för att låsa upp"
l.update_check_fail = "Kopplingen till gPhone-sidan har tappats, vänligen rapportera detta på Workshop sidan och kontrollera din version!"
l.kick = "[gPhone]: OTILLÅTEN FÖRFRÅGAN - FELKOD: 0x01B4D0%s"
l.feature_deny = "Den valda tjänsten har inte lags till än"
l.error = "Fel"

l.default = "Standard"
l.language = "Språk"
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
l.tut_welcome = "Välkommen till Garry Telefonen! Det här är en kort introduktion om hur man använder telefonen"
l.tut_folders = "Använd hemskärmen för att skapa mappar och flytta runt appar som på en riktig iPhone"
l.tut_delete = "Håll ner den högra musknappen för att starta eller stänga av app-raderar-läget" --needs sentence rebuilding
l.tut_text = "SMSa dina vänner i spelet med Messages appen! Klicka på den högra sidan för att radera konversationen"
l.tut_wallpaper = "Ändra din hem- och lockskärms bakgrundsbild med bilder från din dator"
l.tut_music = "Strömma musik från internet eller från din dator med Musik appen!"
l.tut_translate = "Vill du hjälpa till att översätta? Lägg till mig på Steam så kan du få vara med i listan över medverkande!"
l.tut_coders = "Programmerare: Kolla wiki-sidan på Github samt den inkluderade exempel appen för att skapa egna appar"
l.tut_end = "Det skrapar bara på ytan utav telefonens funktioner. Ha kul!!"

-- App base
l.app_error = "[Appfel]"
l.app_deny_gm = "Den här appen kan inte användas i detta gamemode!"
l.app_deny_group = "Du är inte i korrekt grupp för att använda denna app!"

-- Requests
l.confimation = "Bekräftan"
l.confirm = "Bekräfta"
l.request = "Förfrågan"
l.deny = "Neka"
l.accept = "Godkänn"
l.no = "Nej"
l.yes = "Ja"
l.okay = "Okej"
l.response_timeout = "%s svarade inte på din förfrågan i tid"

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
l.text_flagged = "Du är blockerad från att skicka SMS i %i sekunder på grund av spam!"

l.being_called = "%s ringer dig!"

-- Settings
l.wallpapers = "Bakgrundsbilder"
l.airplane_mode = "Flygplansläge"
l.vibrate = "Vibrera"
l.stop_on_tab = "Stäng av musiken på tab"
l.find_album_covers = "Hitta skivomslag"
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
l.lang_reboot_warn = "gPhone startar om när språket är ändrat och bekräftat"

l.no_description = "Ingen beskrivning"
l.install_u = "Installera uppdatering"
l.wipe_archive_confirm = "Är du säker på att du vill rensa alla filer från ditt arkiv? (kan ej ångras)"
l.archive = "Arkiv"
l.update = "Uppdatering"
l.set_color = "Sätt Färg"

l.wipe_log_confirm = "Är det säkert att du vill rensa loggen? Detta kan inte ångras"
l.developer = "Utvecklare"
l.wipe_log = "Rensa logg"
l.dump_log = "Dumpa till fil"
l.c_print = "Konsoll-utskrivning"

-- Contacts
l.contacts = "Kontakter"
l.search = "Sök"
l.back = "Tillbaka"
l.number = "Nummer"

-- Phone
l.phone = "Phone"
l.mute = "Tyst"
l.unmute = "Ljud på"
l.keypad = "Knappsats"
l.speaker = "Högtalare"
l.add = "Lägg till"
l.end_call = "Lägg på"
l.cannot_call = "%s kan inte nås för tillfället! Ursäkta"
l.hung_up_on = "Ditt samtal har blivit avbrutet av personen du pratade med"
l.invalid_player_phone = "Det är inte ett giltigt nummer att ringa!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Spelare mot dator"
l.playerplayer = "Spelare mot spelare"
l.playerself = "Spela ensam"
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
l.invalid_player_warn = "Det är inte ett giltigt nummer att skicka meddelande till"
l.message_len_warn = "Textmeddelandet är för långt för att skickas!"

-- Store
l.no_homescreen_space = "Inte tillräckligt med plats på skärmen för att lägga till en ny app!"
l.app_store = "App Affär"
l.no_apps = "Inga appar"
l.no_apps_phrase = "Tyvärr inga appar tillgängliga"
l.get = "Hämta"
l.have = "Har"

-- Music
l.music = "Musik"
l.music_format_warn = "Det är inte en giltig musik länk! Filen måste sluta på .mp3 eller .wav"
l.editor = "Editor" --Editor/Ändrare/Redaktör ingen översättning verkar rätt
l.editor_help = "* Bara musiklänken krävs"
l.artist_name = "Artist Namn"
l.song_name = "Låt Namn"
l.song_url = "Låt Länk"
l.album_url = "Album Länk"

-- Finances
l.finances = "Finans"
l.transfer = "Överföring"
l.current_user = "Nuvarande Användare: %s"
l.balance = "Saldo: $%s"
l.salary = "Lön: $%s"
l.wire_money = "Elektronisk Överföring"
l.wire_invalid_player = "Ogiltig spelare att överföra pengar till!"
l.wire_invalid_amount = "Ogiltig summa pengar att överföra!"
l.wire_no_money = "Du har inte tillräckligt med pengar för att skicka!"
l.receiver = "Mottagare" 
