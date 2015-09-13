--// English language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

local l = gPhone.createLanguage( "Turkish" )

-- General
l.title = "GEO PHONE"
l.slide_unlock = "Kaydi"
l.update_check_fail = "Update Yapilamadi Workshoptan Yeni Surumu Indirin"
l.kick = "[gPhone]: ILLEGAL Istek - ERROR: 0x01B4D0%s"
l.feature_deny = "Seçilen özellik henüz uygulamaya konmamiþtir"
l.error = "Error"

l.default = "Varsayilan"
l.language = "Dil"
l.settings = "Ayarlar"
l.general = "General"
l.wallpaper = "Arka Plan"
l.homescreen = "Anaekran"
l.about = "Bilgi"
l.color = "Renk"

l.phone_confis = "Telefonunuza El Koyuldu"
l.unable_to_open = "Þu anda GPhone açamiyor"

-- Homescreen
l.battery_dead = "Pili Bitti , Tekrar Dolduruluyor"
l.battery_okay = "Sarj Edildi"
l.service_provider = "GEO"
l.folder_fallback = "Dosya"
l.invalid_folder_name = "Gecersiz"

-- Tutorial
l.tut_welcome = "Garry Phone hoþ geldiniz ! Bu telefonun temelleri hakkinda kisa bir giriþtir"
l.tut_folders = "Klasörler oluþturmak ve hareket Ana ekrani kullanin gerçek bir iPhone gibi apps"
l.tut_delete = "Uygulamaya silme moduna geçiþ yapmak için sað fare düðmesini basili tutun"
l.tut_text = "Mesajlar uygulamasini kullanarak oyununda arkadaþlarinizi Metin ! Konuþma silmek için sað tarafini tiklayin"
l.tut_wallpaper = "Evinizi deðiþtirmek ve bilgisayarinizdan resimleri kullanarak ekran duvar kaðitlari kilitlemek"
l.tut_music = "Müzik uygulamasi ile internetten ya da bilgisayarinizi kapatip müzik akiþi !"
l.tut_translate = "Çevirmek yardim etmek ister ? Steam beni ekleyin ve telefonun kredisi olabilir!"
l.tut_coders = "Coders : Github üzerinde Wiki kontrol ve örnek uygulamasi, uygulamalar yapmak yardimci dahildir"
l.tut_end = "Bu sadece telefonun özelliklerinden yüzeyini çizikler . Eðlen!!"

-- App base
l.app_error = "Uygulama Hatasi"
l.app_deny_gm = "This app cannot be used in this gamemode!"
l.app_deny_group = "You are not in the correct group to use this app!"

-- Requests
l.confirmation = "Onay"
l.confirm = "Onayla"
l.request = "Istek"
l.deny = "Deny"
l.accept = "Kabul"
l.no = "Hayir"
l.yes = "Evet"
l.okay = "Tamam"
l.response_timeout = "%s zaman içinde isteðinize yanit vermedi"

l.accept_fallback = "%s kullanmak isteðinizi kabul etti %s"
l.phone_accept = "%s çaðri kabul etti"
l.gpong_accept = "%s gPong oynamak için isteðinizi kabul etti"

l.deny_fallback = "%s has denied your request to use %s"
l.phone_deny = "%s kullanmak için isteðini reddetti"
l.gpong_deny = "%s gPong oynamak için isteðini reddetti"

-- Data transfer
l.transfer_fail_gm = "You cannot wire money in gamemodes that are not DarkRP"
l.transfer_fail_cool = "You must wait %i's before you can transfer more money"
l.transfer_fail_ply = "Iþlemi tamamlamak için açilamiyor - geçersiz alici"
l.transfer_fail_amount = "Nil miktari - iþlem tamamlanamadi"
l.transfer_fail_generic = "Iþlemi tamamlamak için açilamiyor , üzgünüm"
l.transfer_fail_funs = "Fon eksikliði - iþlem tamamlanamadi" 

l.received_money = "Received $%i from %s!"
l.sent_money = "Wired $%i to %s successfully!"

l.text_cooldown = "You cannot text for %i more seconds!"
l.text_flagged = "To prevent spam, you have been blocked from texting for %i seconds!"

l.being_called = "%s Sizi Ariyor!"

-- Settings
l.wallpapers = "Duvar Kaðidi"
l.airplane_mode = "Uçak Modu"
l.vibrate = "Titreþim"
l.stop_on_tab = "Sekmesinde müziði durdurun"
l.find_album_covers = "Albüm kapaklari bulun"
l.show_unusable_apps = "Kullaniþsiz uygulamalari göster"
l.reset_app_pos = "Simge konumlari Reset"
l.archive_cleanup = "Arþiv temizleme"
l.file_life = "Dosya ömrü (gün)"
l.wipe_archive = "arþiv Wipe"

l.choose_new_wp = "Yeni Ekran Kagidi Sec"
l.wp_selector = "Duvar kaðidi seçici"
l.dark_status = "Durum ba Koyulaþtir"
l.set_lock = "Kilit Ekrani Ayarla"
l.set_home = "Ana Ekran Ayarla"
l.reset_homescreen = "Ekran Simgelerinin pozisyonlari sifirlamak istediðinizden emin misiniz ?"
l.lang_reboot_warn = "GPhone dili deðiþti ve teyit edildiðinde yeniden baþlayacaktir"

l.no_description = "Aciklama Yok"
l.install_u = "Guncellemeyi Yukle"
l.wipe_archive_confirm = "Arþivi Silmek Istediðinizden Eminmisin (Bu iþlem geri alinamaz)"
l.archive = "Arþiv"
l.update = "Güncelleme"
l.set_color = "Rengi Ayarla"

l.wipe_log_confirm = "Günlüðü silmek istediðinizden emin misiniz ? Bu geri alinamaz"
l.developer = "Geliþtirici"
l.wipe_log = "Gümlük Loglari"
l.dump_log = "Çöp Dosyalar"
l.c_print = "Console Printing"

l.binds = "baðlamalar"
l.open_key = "Hangi Tus Ile Açilsin"
l.key_hold = "Basiþ Suresi"

-- Contacts
l.contacts = "Rehber"
l.search = "Arama"
l.back = "Geri"
l.number = "Numara"

-- Phone
l.phone = "Arama"
l.mute = "Sesi Kapa"
l.unmute = "Sesi Ac"
l.keypad = "Tus Takimi"
l.speaker = "Hoparlor"
l.add = "Ekle"
l.end_call = "Cagriyi Bitir"
l.cannot_call = "%s Aranamiyor"
l.hung_up_on = "Karsi Taraf Cagrinizi Kanul Etmedi"
l.invalid_player_phone = "Bu Numara Gecersiz"

-- Pong
l.gpong = "gPong"
l.playerbot = "Oyuncu VS Bot"
l.playerplayer = "Oyuncu VS Oyuncu"
l.playerself = "Oyuncu Kendine Karsi"
l.easy = "Kolay"
l.medium = "Normal"
l.hard = "Zor"

l.challenge_ply = "Oyuncu Mucadelesi!"
l.gpong_self_instructions = " Oyuncu 1:\r\n W ve S\r\n Oyuncu 2:\r\n Yukari ve Assagi Ok Tuslari" 
l.start = "Basla!"
l.resume = "Devam Et"
l.quit = "Cik"
l.p1_win = "Oyuncu 1 wins!"
l.p2_win = "Oyuncu 2 wins!"

-- Text/Messages
l.messages = "Mesaj"
l.delete = "Sil"
l.last_year = "Gecen Sene"
l.yesterday = "Dun
l.years_ago = "Yil Once"
l.days_ago = "Onceki Gun"
l.send = "Yolla"
l.new_msg = "Yeni Mesaj"
l.to = "Kime:"
l.invalid_player_warn = "Gecersiz Numara"
l.message_len_warn = "Bu Mesaj Cok Uzun"

-- Store
l.no_homescreen_space = "Yeni Uygulama Icin Yeterli Yeriniz Yok!"
l.app_store = "Market"
l.no_apps = "Uygulama Yok"
l.no_apps_phrase = "Malesef Yeni Uygulama Yok Daha Sonra Tekrar Gelin"
l.get = "Indir"
l.have = "Indirilmis"

-- Music
l.music = "Müzik"
l.music_format_warn = "Bu Müzik Dosyasi(mp3 , waw) deil"
l.editor = "Editor"
l.editor_help = "Sadece Müzik Url girin"
l.artist_name = "Artist Adi"
l.song_name = "Müzik Ismi"
l.song_url = "Müzik Url"
l.album_url = "Albüm Url" 

-- Finances
l.finances = "Finans"
l.transfer = "Aktar"
l.current_user = "Gecerli Kullanici: %s"
l.balance = "Denge: $%s"
l.salary = "Maaþ: $%s"
l.wire_money = "Wire Funds"
l.wire_invalid_player = "Gecersiz Hedef!"
l.wire_invalid_amount = "Yanliþ Para Birimi!"
l.wire_no_money = "Yeterince Paraniz Yok!"
l.receiver = "Alici"

-- Flappy Garry
l.enter_play = "Enter Tusuna Basarak Oyuna Baslayiniz"

-- Browser
l.connecting = "Baglaniliyor"