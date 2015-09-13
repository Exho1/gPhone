--// English language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

local l = gPhone.createLanguage( "Turkish" )

-- General
l.title = "gPhone"
l.slide_unlock = "Kayd�r"
l.update_check_fail = "Update Yap�lamad� Workshoptan Yeni Surumu Indirin"
l.kick = "[gPhone]: ILLEGAL Istek - ERROR: 0x01B4D0%s"
l.feature_deny = "Secilen ozellik henuz uygulamaya konmam�st�r"
l.error = "Error"

l.default = "Varsay�lan"
l.language = "Dil"
l.settings = "Ayarlar"
l.general = "General"
l.wallpaper = "Arka Plan"
l.homescreen = "Anaekran"
l.about = "Bilgi"
l.color = "Renk"

l.phone_confis = "Telefonunuza El Koyuldu"
l.unable_to_open = "su anda gPhone acam�yor"

-- Homescreen
l.battery_dead = "Pili Bitti , Tekrar Dolduruluyor"
l.battery_okay = "Sarj Edildi"
l.service_provider = "Turkcell"
l.folder_fallback = "Dosya"
l.invalid_folder_name = "Gecersiz"

-- Tutorial
l.tut_welcome = "Garry Phone hos geldiniz ! Bu telefonun temelleri hakk�nda k�sa bir giristir"
l.tut_folders = "Klasorler olusturmak ve hareket Ana ekran� kullan�n gercek bir iPhone gibi apps"
l.tut_delete = "Uygulamaya silme moduna gecis yapmak icin sag fare dugmesini bas�l� tutun"
l.tut_text = "Mesajlar uygulamas�n� kullanarak oyununda arkadaslar�n�z� Metin ! Konusma silmek icin sag taraf�n� t�klay�n"
l.tut_wallpaper = "Evinizi degistirmek ve bilgisayar�n�zdan resimleri kullanarak ekran duvar kag�tlar� kilitlemek"
l.tut_music = "Muzik uygulamas� ile internetten ya da bilgisayar�n�z� kapat�p muzik ak�s� !"
l.tut_translate = "cevirmek yard�m etmek ister ? Steam beni ekleyin ve telefonun kredisi olabilir!"
l.tut_coders = "Coders : Github uzerinde Wiki kontrol ve ornek uygulamas�, uygulamalar yapmak yard�mc� dahildir"
l.tut_end = "Bu sadece telefonun ozelliklerinden yuzeyini cizikler . Eglen!!"

-- App base
l.app_error = "Uygulama Hatas�"
l.app_deny_gm = "Bu Uygulama Bu Oyunmoduna uygun deil !"
l.app_deny_group = "Bu Uygulamayi Kullanmak Icin Yanlis Gurubdasin !"

-- Requests
l.confirmation = "Onay"
l.confirm = "Onayla"
l.request = "Istek"
l.deny = "Deny"
l.accept = "Kabul"
l.no = "Hay�r"
l.yes = "Evet"
l.okay = "Tamam"
l.response_timeout = "%s zaman icinde isteginize yan�t vermedi"

l.accept_fallback = "%s kullanmak isteginizi kabul etti %s"
l.phone_accept = "%s cagr� kabul etti"
l.gpong_accept = "%s gPong oynamak icin isteginizi kabul etti"

l.deny_fallback = "%s has denied your request to use %s"
l.phone_deny = "%s kullanmak icin istegini reddetti"
l.gpong_deny = "%s gPong oynamak icin istegini reddetti"

-- Data transfer
l.transfer_fail_gm = "You cannot wire money in gamemodes that are not DarkRP"
l.transfer_fail_cool = "You must wait %i's before you can transfer more money"
l.transfer_fail_ply = "Islemi tamamlamak icin ac�lam�yor - gecersiz al�c�"
l.transfer_fail_amount = "Nil miktar� - islem tamamlanamad�"
l.transfer_fail_generic = "Islemi tamamlamak icin ac�lam�yor , uzgunum"
l.transfer_fail_funs = "Fon eksikligi - islem tamamlanamad�" 

l.received_money = "Received $%i from %s!"
l.sent_money = "Wired $%i to %s successfully!"

l.text_cooldown = "You cannot text for %i more seconds!"
l.text_flagged = "To prevent spam, you have been blocked from texting for %i seconds!"

l.being_called = "%s Sizi Ar�yor!"

-- Settings
l.wallpapers = "Duvar Kag�d�"
l.airplane_mode = "Ucak Modu"
l.vibrate = "Titresim"
l.stop_on_tab = "Sekmesinde muzigi durdurun"
l.find_album_covers = "Album kapaklar� bulun"
l.show_unusable_apps = "Kullan�ss�z uygulamalar� goster"
l.reset_app_pos = "Simge konumlar� Reset"
l.archive_cleanup = "Arsiv temizleme"
l.file_life = "Dosya omru (gun)"
l.wipe_archive = "arsiv Wipe"

l.choose_new_wp = "Yeni Ekran Kagidi Sec"
l.wp_selector = "Duvar kag�d� secici"
l.dark_status = "Durum ba Koyulast�r"
l.set_lock = "Kilit Ekran� Ayarla"
l.set_home = "Ana Ekran Ayarla"
l.reset_homescreen = "Ekran Simgelerinin pozisyonlar� s�f�rlamak istediginizden emin misiniz ?"
l.lang_reboot_warn = "GPhone dili degisti ve teyit edildiginde yeniden baslayacakt�r"

l.no_description = "Ac�klama Yok"
l.install_u = "Guncellemeyi Yukle"
l.wipe_archive_confirm = "Arsivi Silmek Istediginizden Eminmisin (Bu islem geri al�namaz)"
l.archive = "Arsiv"
l.update = "Guncelleme"
l.set_color = "Rengi Ayarla"

l.wipe_log_confirm = "Gunlugu silmek istediginizden emin misiniz ? Bu geri al�namaz"
l.developer = "Gelistirici"
l.wipe_log = "Gumluk Loglar�"
l.dump_log = "cop Dosyalar"
l.c_print = "Console Printing"

l.binds = "baglamalar"
l.open_key = "Hangi Tus Ile Ac�ls�n"
l.key_hold = "Bas�s Suresi"

-- Contacts
l.contacts = "Rehber"
l.search = "Arama"
l.back = "Geri"
l.number = "Numara"

-- Phone
l.phone = "Arama"
l.mute = "Sesi Kapa"
l.unmute = "Sesi Ac"
l.keypad = "Tus Tak�m�"
l.speaker = "Hoparlor"
l.add = "Ekle"
l.end_call = "Cagriyi Bitir"
l.cannot_call = "%s Aranam�yor"
l.hung_up_on = "Kars� Taraf Cagrinizi Kanul Etmedi"
l.invalid_player_phone = "Bu Numara Gecersiz"

-- Pong
l.gpong = "gPong"
l.playerbot = "Oyuncu VS Bot"
l.playerplayer = "Oyuncu VS Oyuncu"
l.playerself = "Oyuncu Kendine Kars�"
l.easy = "Kolay"
l.medium = "Normal"
l.hard = "Zor"

l.challenge_ply = "Oyuncu Mucadelesi!"
l.gpong_self_instructions = " Oyuncu 1:\r\n W ve S\r\n Oyuncu 2:\r\n Yukar� ve Assagi Ok Tuslar�" 
l.start = "Basla!"
l.resume = "Devam Et"
l.quit = "C�k"
l.p1_win = "Oyuncu 1 wins!"
l.p2_win = "Oyuncu 2 wins!"

-- Text/Messages
l.messages = "Mesaj"
l.delete = "Sil"
l.last_year = "Gecen Sene"
l.yesterday = "Dun"
l.years_ago = "Y�l Once"
l.days_ago = "Onceki Gun"
l.send = "Yolla"
l.new_msg = "Yeni Mesaj"
l.to = "Kime:"
l.invalid_player_warn = "Gecersiz Numara"
l.message_len_warn = "Bu Mesaj Cok Uzun"

-- Store
l.no_homescreen_space = "Yeni Uygulama Ic�n Yeterli Yeriniz Yok!"
l.app_store = "Market"
l.no_apps = "Uygulama Yok"
l.no_apps_phrase = "Malesef Yeni Uygulama Yok Daha Sonra Tekrar Gelin"
l.get = "Indir"
l.have = "Indirilmis"

-- Music
l.music = "Muzik"
l.music_format_warn = "Bu Muzik Dosyas�(mp3 , waw) deil"
l.editor = "Editor"
l.editor_help = "Sadece Muzik Url girin"
l.artist_name = "Artist Ad�"
l.song_name = "Muzik Ismi"
l.song_url = "Muzik Url"
l.album_url = "Album Url" 

-- Finances
l.finances = "Finans"
l.transfer = "Aktar"
l.current_user = "Gecerli Kullan�c�: %s"
l.balance = "Denge: $%s"
l.salary = "Maas: $%s"
l.wire_money = "Wire Funds"
l.wire_invalid_player = "Gecersiz Hedef!"
l.wire_invalid_amount = "Yanl�s Para Birimi!"
l.wire_no_money = "Yeterince Paran�z Yok!"
l.receiver = "Al�c�"

-- Flappy Garry
l.enter_play = "Enter Tusuna Basarak Oyuna Baslay�n�z"

-- Browser
l.connecting = "Baglan�l�yor"