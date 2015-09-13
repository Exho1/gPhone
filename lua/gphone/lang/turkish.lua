--// English language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

local l = gPhone.createLanguage( "Turkish" )

-- General
l.title = "gPhone"
l.slide_unlock = "Kaydýr"
l.update_check_fail = "Update Yapýlamadý Workshoptan Yeni Surumu Indirin"
l.kick = "[gPhone]: ILLEGAL Istek - ERROR: 0x01B4D0%s"
l.feature_deny = "Secilen ozellik henuz uygulamaya konmamýstýr"
l.error = "Error"

l.default = "Varsayýlan"
l.language = "Dil"
l.settings = "Ayarlar"
l.general = "General"
l.wallpaper = "Arka Plan"
l.homescreen = "Anaekran"
l.about = "Bilgi"
l.color = "Renk"

l.phone_confis = "Telefonunuza El Koyuldu"
l.unable_to_open = "su anda gPhone acamýyor"

-- Homescreen
l.battery_dead = "Pili Bitti , Tekrar Dolduruluyor"
l.battery_okay = "Sarj Edildi"
l.service_provider = "Turkcell"
l.folder_fallback = "Dosya"
l.invalid_folder_name = "Gecersiz"

-- Tutorial
l.tut_welcome = "Garry Phone hos geldiniz ! Bu telefonun temelleri hakkýnda kýsa bir giristir"
l.tut_folders = "Klasorler olusturmak ve hareket Ana ekraný kullanýn gercek bir iPhone gibi apps"
l.tut_delete = "Uygulamaya silme moduna gecis yapmak icin sag fare dugmesini basýlý tutun"
l.tut_text = "Mesajlar uygulamasýný kullanarak oyununda arkadaslarýnýzý Metin ! Konusma silmek icin sag tarafýný týklayýn"
l.tut_wallpaper = "Evinizi degistirmek ve bilgisayarýnýzdan resimleri kullanarak ekran duvar kagýtlarý kilitlemek"
l.tut_music = "Muzik uygulamasý ile internetten ya da bilgisayarýnýzý kapatýp muzik akýsý !"
l.tut_translate = "cevirmek yardým etmek ister ? Steam beni ekleyin ve telefonun kredisi olabilir!"
l.tut_coders = "Coders : Github uzerinde Wiki kontrol ve ornek uygulamasý, uygulamalar yapmak yardýmcý dahildir"
l.tut_end = "Bu sadece telefonun ozelliklerinden yuzeyini cizikler . Eglen!!"

-- App base
l.app_error = "Uygulama Hatasý"
l.app_deny_gm = "Bu Uygulama Bu Oyunmoduna uygun deil !"
l.app_deny_group = "Bu Uygulamayi Kullanmak Icin Yanlis Gurubdasin !"

-- Requests
l.confirmation = "Onay"
l.confirm = "Onayla"
l.request = "Istek"
l.deny = "Deny"
l.accept = "Kabul"
l.no = "Hayýr"
l.yes = "Evet"
l.okay = "Tamam"
l.response_timeout = "%s zaman icinde isteginize yanýt vermedi"

l.accept_fallback = "%s kullanmak isteginizi kabul etti %s"
l.phone_accept = "%s cagrý kabul etti"
l.gpong_accept = "%s gPong oynamak icin isteginizi kabul etti"

l.deny_fallback = "%s has denied your request to use %s"
l.phone_deny = "%s kullanmak icin istegini reddetti"
l.gpong_deny = "%s gPong oynamak icin istegini reddetti"

-- Data transfer
l.transfer_fail_gm = "You cannot wire money in gamemodes that are not DarkRP"
l.transfer_fail_cool = "You must wait %i's before you can transfer more money"
l.transfer_fail_ply = "Islemi tamamlamak icin acýlamýyor - gecersiz alýcý"
l.transfer_fail_amount = "Nil miktarý - islem tamamlanamadý"
l.transfer_fail_generic = "Islemi tamamlamak icin acýlamýyor , uzgunum"
l.transfer_fail_funs = "Fon eksikligi - islem tamamlanamadý" 

l.received_money = "Received $%i from %s!"
l.sent_money = "Wired $%i to %s successfully!"

l.text_cooldown = "You cannot text for %i more seconds!"
l.text_flagged = "To prevent spam, you have been blocked from texting for %i seconds!"

l.being_called = "%s Sizi Arýyor!"

-- Settings
l.wallpapers = "Duvar Kagýdý"
l.airplane_mode = "Ucak Modu"
l.vibrate = "Titresim"
l.stop_on_tab = "Sekmesinde muzigi durdurun"
l.find_album_covers = "Album kapaklarý bulun"
l.show_unusable_apps = "Kullanýssýz uygulamalarý goster"
l.reset_app_pos = "Simge konumlarý Reset"
l.archive_cleanup = "Arsiv temizleme"
l.file_life = "Dosya omru (gun)"
l.wipe_archive = "arsiv Wipe"

l.choose_new_wp = "Yeni Ekran Kagidi Sec"
l.wp_selector = "Duvar kagýdý secici"
l.dark_status = "Durum ba Koyulastýr"
l.set_lock = "Kilit Ekraný Ayarla"
l.set_home = "Ana Ekran Ayarla"
l.reset_homescreen = "Ekran Simgelerinin pozisyonlarý sýfýrlamak istediginizden emin misiniz ?"
l.lang_reboot_warn = "GPhone dili degisti ve teyit edildiginde yeniden baslayacaktýr"

l.no_description = "Acýklama Yok"
l.install_u = "Guncellemeyi Yukle"
l.wipe_archive_confirm = "Arsivi Silmek Istediginizden Eminmisin (Bu islem geri alýnamaz)"
l.archive = "Arsiv"
l.update = "Guncelleme"
l.set_color = "Rengi Ayarla"

l.wipe_log_confirm = "Gunlugu silmek istediginizden emin misiniz ? Bu geri alýnamaz"
l.developer = "Gelistirici"
l.wipe_log = "Gumluk Loglarý"
l.dump_log = "cop Dosyalar"
l.c_print = "Console Printing"

l.binds = "baglamalar"
l.open_key = "Hangi Tus Ile Acýlsýn"
l.key_hold = "Basýs Suresi"

-- Contacts
l.contacts = "Rehber"
l.search = "Arama"
l.back = "Geri"
l.number = "Numara"

-- Phone
l.phone = "Arama"
l.mute = "Sesi Kapa"
l.unmute = "Sesi Ac"
l.keypad = "Tus Takýmý"
l.speaker = "Hoparlor"
l.add = "Ekle"
l.end_call = "Cagriyi Bitir"
l.cannot_call = "%s Aranamýyor"
l.hung_up_on = "Karsý Taraf Cagrinizi Kanul Etmedi"
l.invalid_player_phone = "Bu Numara Gecersiz"

-- Pong
l.gpong = "gPong"
l.playerbot = "Oyuncu VS Bot"
l.playerplayer = "Oyuncu VS Oyuncu"
l.playerself = "Oyuncu Kendine Karsý"
l.easy = "Kolay"
l.medium = "Normal"
l.hard = "Zor"

l.challenge_ply = "Oyuncu Mucadelesi!"
l.gpong_self_instructions = " Oyuncu 1:\r\n W ve S\r\n Oyuncu 2:\r\n Yukarý ve Assagi Ok Tuslarý" 
l.start = "Basla!"
l.resume = "Devam Et"
l.quit = "Cýk"
l.p1_win = "Oyuncu 1 wins!"
l.p2_win = "Oyuncu 2 wins!"

-- Text/Messages
l.messages = "Mesaj"
l.delete = "Sil"
l.last_year = "Gecen Sene"
l.yesterday = "Dun"
l.years_ago = "Yýl Once"
l.days_ago = "Onceki Gun"
l.send = "Yolla"
l.new_msg = "Yeni Mesaj"
l.to = "Kime:"
l.invalid_player_warn = "Gecersiz Numara"
l.message_len_warn = "Bu Mesaj Cok Uzun"

-- Store
l.no_homescreen_space = "Yeni Uygulama Icýn Yeterli Yeriniz Yok!"
l.app_store = "Market"
l.no_apps = "Uygulama Yok"
l.no_apps_phrase = "Malesef Yeni Uygulama Yok Daha Sonra Tekrar Gelin"
l.get = "Indir"
l.have = "Indirilmis"

-- Music
l.music = "Muzik"
l.music_format_warn = "Bu Muzik Dosyasý(mp3 , waw) deil"
l.editor = "Editor"
l.editor_help = "Sadece Muzik Url girin"
l.artist_name = "Artist Adý"
l.song_name = "Muzik Ismi"
l.song_url = "Muzik Url"
l.album_url = "Album Url" 

-- Finances
l.finances = "Finans"
l.transfer = "Aktar"
l.current_user = "Gecerli Kullanýcý: %s"
l.balance = "Denge: $%s"
l.salary = "Maas: $%s"
l.wire_money = "Wire Funds"
l.wire_invalid_player = "Gecersiz Hedef!"
l.wire_invalid_amount = "Yanlýs Para Birimi!"
l.wire_no_money = "Yeterince Paranýz Yok!"
l.receiver = "Alýcý"

-- Flappy Garry
l.enter_play = "Enter Tusuna Basarak Oyuna Baslayýnýz"

-- Browser
l.connecting = "Baglanýlýyor"