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

-- App base
l.app_error = "[Appfel]"
l.app_deny_gm = "Den här appen kan inte användas i denna speltyp!"
l.app_deny_group = "Du är inte i korrekt grupp för att använda denna app!"

-- Requests
l.confim = "Bekräftan"
l.request = "Förfrågan"
l.deny = "Neka"
l.accept = "Godkänn"
l.no = "Nej"
l.yes = "Ja"
l.okay = "Okej"

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

l.no_description = "Ingen beskrivning"
l.install_u = "Installera uppdatering"
l.wipe_archive_confirm = "Är du säker på att du vill rensa alla filer från ditt arkiv? (kan ej bli ogjort)"
l.archive = "Arkiv"
l.update = "Uppdatering"

-- Contacts
l.contacts = "Kontakter"
l.search = "Sök"
l.back = "Tillbaka"
l.number = "Nummer"

-- Phone
l.mute = "Tyst"
l.unmute = "Otyst"
l.keypad = "Knappsats"
l.speaker = "Högtalare"
l.add = "Lägg till"
l.end_call = "Lägg på"

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

-- Store
l.no_homescreen_space = "Inte tillräckligt med plats på skärmen för att lägga till en ny app!"
l.app_store = "App Affär"
l.no_apps = "Inga appar"
l.no_apps_phrase = "Tyvärr inga appar tillgängliga"
l.get = "Hämta"
l.have = "Har"