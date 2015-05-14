--// Danish language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By DenOndeDirektoer (STEAM_0:0:45362329)

local l = gPhone.createLanguage( "danish" )

-- General
l.title = "Garry Telefonen"
l.slide_unlock = "lås op"
l.update_check_fail = "forbindelse til gphone hjemmesiden slog fejl, vær venlig at rapportere det på værksteds siden!"
l.kick = "[gPhone]: Illegal anmodning - FEJL: 0x01B4D0%s"
l.feature_deny = "Den valgte funktion er ikke blevet tilføjet endnu"
l.error = "Error"

l.default = "Standard"
l.language = "Sprog"
l.settings = "Indstillinger"
l.general = "Generalt"
l.wallpaper = "Baggrund"
l.homescreen = "Forside"
l.about = "Om"
l.color = "Farve"

l.phone_confis = "Din telefon er blevet konfiskeret"
l.unable_to_open = "Du har ikke mulighed for at åbne telefonen lige nu"

-- Homescreen
l.battery_dead = "Din telefon er løbet tør for strøm og lukkede ned! Oplader"
l.battery_okay = "Oplader!"
l.service_provider = "Garry"
l.folder_fallback = "Mappe"
l.invalid_folder_name = "Ugyldig"

-- Tutorial
l.tut_welcome = "Velkommen til garry telefonen! Dette er en kort introduktion til telefonen"
l.tut_folders = "Brug forsiden til at lave mapper og flytte aps rundt ligesom den rigtige iphone"
l.tut_delete = "Hold nede højre klik for at skifte imellem sletning af apps"
l.tut_text = "Skriv til dine venner ved at bruge sms appen! Klik på højre side for at slette samtalen"
l.tut_wallpaper = "Ændre din låse skærm og forside, med billeder fra din computer"
l.tut_music = "Hør musik fra internettet eller din computer!"
l.tut_translate = "Vil du hjælpe med at oversætte? Tilføj mig på steam og du kan være med i telefonens credits"
l.tut_coders = "Kodere: Tjek wiki på github og eksempel appen for at se hvordan man laver apps"
l.tut_end = "Det rør kun toppen af telefonens muligheder"

-- App base
l.app_error = "[App fejl]"
l.app_deny_gm = "Denne app kan ikke blive brugt i dette gamemode!"
l.app_deny_group = "Du er ikke i den rigtige gruppe for at bruge det!"

-- Requests
l.confirmation = "Bekræftelse"
l.confirm = "Accepter"
l.request = "Anmod"
l.deny = "Afvis"
l.accept = "Accepter"
l.no = "Nej"
l.yes = "Ja"
l.okay = "Okay"
l.response_timeout = "%s svarede ikke på din anmodning i tide"

l.accept_fallback = "%s har acceptered din anmodning for at bruge %s"
l.phone_accept = "%s har accepteret dit opkald"
l.gpong_accept = "%s har accepteret din anmodning for at spille gPong"

l.deny_fallback = "%s har afvist din anmoding for at spille %s"
l.phone_deny = "%s har afvist din anmodning"
l.gpong_deny = "%s Har afvist din anmodning for at spille gPong"

-- Data transfer
l.transfer_fail_gm = "Du kan ikke wire penge i en anden gamemode end DarkRP"
l.transfer_fail_cool = "Du er nød til at vente %i før du kan overføre penge igen"
l.transfer_fail_ply = "Det er ikke muligt at fuldføre transaktionen - Ugyldig modtager"
l.transfer_fail_amount = "Det er ikke muligt at fuldføre transaktionen - Intet beløb"
l.transfer_fail_generic = "Det er ikke muligt at fuldføre transaktionen, vi er kede af det"
l.transfer_fail_funs = "Det er ikke muligt at fuldføre transaktionen - ingen penge" 

l.received_money = "Fik $%i fra %s!"
l.sent_money = "Wired $%i til %s uden problemer!"

l.text_cooldown = "Du kan ikke skrive for %i sekunder!"
l.text_flagged = "For at undgå spam, er du blevet blokeret fra at skrive i %i sekunder!"

l.being_called = "%s ringer til dig!"

-- Settings
l.wallpapers = "Baggrund"
l.airplane_mode = "Flytilstand"
l.vibrate = "Vibrere"
l.stop_on_tab = "Stop musik ved berørelse"
l.find_album_covers = "Find album covers"
l.show_unusable_apps = "Vis ikke brugbare apps"
l.reset_app_pos = "fabriksindstil apps ikon position"
l.archive_cleanup = "Arkiv rensning"
l.file_life = "Fils levetid (dage)"
l.wipe_archive = "Rens arkiv"

l.choose_new_wp = "Vælg en ny baggrund"
l.wp_selector = "Baggrunds vælger"
l.dark_status = "Formørk status bar"
l.set_lock = "Vælg låse skærm"
l.set_home = "vælg forside"
l.reset_homescreen = "Er du sikker på at du vil fabriksindstille forsidens ikoner?"
l.lang_reboot_warn = "Telefonen vil genstarte når sproget er valgt og accepteret"

l.no_description = "Ingen beskrivelse valgt"
l.install_u = "Installer opdatering"
l.wipe_archive_confirm = "Er du sikker på at du vil fjerne alle filer i arkiverne? (Filerne fjernes permanent)"
l.archive = "Arkiv"
l.update = "Opdatering"
l.set_color = "Vælg farve"

l.wipe_log_confirm = "Er du sikker på at du vil fjerne loggen? Loggen fjernes permanent"
l.developer = "Udvikler"
l.wipe_log = "Fjern log"
l.dump_log = "Flyt til fil"
l.c_print = "Konsol Printer"

l.binds = "Binds"
l.open_key = "Tryk på knap"
l.key_hold = "Knaps holde tid"

-- Contacts
l.contacts = "Kontakter"
l.search = "Søg"
l.back = "Tilbage"
l.number = "Nummer"

-- Phone
l.phone = "Telefon"
l.mute = "Mute"
l.unmute = "Unmute"
l.keypad = "Tastatur"
l.speaker = "Højtaler"
l.add = "Tilføj"
l.end_call = "Afslut opkald"
l.cannot_call = "Du kan ikke ringe til %s på dette tidspunkt! Desværre"
l.hung_up_on = "Dit opkald er blevet afsluttet af den du ringede til"
l.invalid_player_phone = "Dette telefon nummer eksistere ikke!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Spiller vs Bot"
l.playerplayer = "Spiller vs Spiller"
l.playerself = "Spiller vs sig selv"
l.easy = "Let"
l.medium = "Normal"
l.hard = "Svær"

l.challenge_ply = "Udfordre spiller!"
l.gpong_self_instructions = " Spiller 1:\r\n W og S\r\n Player 2:\r\n op og ned pile taster" 
l.start = "Start!"
l.resume = "Gentag"
l.quit = "Forlad"
l.p1_win = "S1 vinder!"
l.p2_win = "S2 vinder!"

-- Text/Messages
l.messages = "Beskeder"
l.delete = "Fjern"
l.last_year = "Sidste år"
l.yesterday = "Igår"
l.years_ago = "År siden"
l.days_ago = "Dage siden"
l.send = "Send"
l.new_msg = "Ny besked"
l.to = "Til:"
l.invalid_player_warn = "Spilleren eller telefon nummeret eksistere ikke"
l.message_len_warn = "Denne besked er for lang til at blive sendt!"

-- Store
l.no_homescreen_space = "Du har ikke nok forside plads til denne app!"
l.app_store = "App Butik"
l.no_apps = "Ingen apps"
l.no_apps_phrase = "Der er ingen apps tilgængelige, desværre :("
l.get = "Få"
l.have = "Har"

-- Music
l.music = "Musik"
l.music_format_warn = "Dette er ikke en rigtig musik url! Formattet skal være .mp3 eller .waw"
l.editor = "Editor"
l.editor_help = "* Kun sangens url er nødvendigt"
l.artist_name = "Kunsterens navn"
l.song_name = "Sangens navn"
l.song_url = "Sangens url"
l.album_url = "Albummets url" 

-- Finances
l.finances = "Finanser"
l.transfer = "Overfør"
l.current_user = "Nuværende bruger: %s"
l.balance = "Penge: $%s"
l.salary = "Løn: $%s"
l.wire_money = "Overfør penge"
l.wire_invalid_player = "Spilleren eksistere ikke!"
l.wire_invalid_amount = "Ingen penge til at overføre, er angivet!"
l.wire_no_money = "Du har ikke nok penge at sende!"
l.receiver = "Modtager"

-- Flappy Garry
l.enter_play = "Tryk på 'enter' for at spille!"

-- Browser
l.connecting = "Forbinder"