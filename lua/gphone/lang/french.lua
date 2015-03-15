--// French language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By Azmok (STEAM_0:0:75743178)

local l = gPhone.createLanguage( "francais" )

-- General
l.title = "Le telephone de Garry"
l.slide_unlock = "Glissez pour deverouiller"
l.update_check_fail = "Connection au site web Gphone echouee , rapportez votre erreur sur la page du workshop et verifiez votre version !"
l.kick = "[gPhone]: Requete illegale - ERREUR: 0x01B4D0%s"
l.feature_deny = "Cette fonctionnalitee n'as pas encore ete implemantee"
l.error = "Erreur"

l.default = "Defaut"
l.language = "Languages du telephone"
l.settings = "Parametres"
l.general = "General"
l.wallpaper = "Fonds d'ecran"
l.homescreen = "Accueil"
l.about = "A propos"
l.color = "Couleur"

-- Homescreen
l.battery_dead = "Votre telephone n'as plus de batterie ! Rechargement .."
l.battery_okay = "Telephone recharge !"
l.service_provider = "Garry"
l.folder_fallback = "Dossier"
l.invalid_folder_name = "Nom du dossier invalide"

-- Tutorial
l.tut_welcome = "Bienvenue sur le Gphone , ceci est une courte presentation pour vous apprendre a l'utiliser."
l.tut_folders = "Vous pouvez modifier l'accueil comme bon vous semble comme un reel iPhone."
l.tut_delete = "Maintenez le clic droit afin d'entrer dans le mode suppression afin de supprimer une application."
l.tut_text = "Vous pouvez envoyer des messages a vos amis . (Clic droit afin de supprimer les conversations.)"
l.tut_wallpaper = "Vous pouvez changer le fonds d'ecran de verrouillage ainsi que celui de l'accueil en utilisant les images de votre ordinateur."
l.tut_music = "Vous pouvez ecouter les musiques de votre choix en stream direct!"
l.tut_translate = "Vous voulez aider le developpeur a traduire ? envoyez-lui vos traductions sur le workshop afin d'etre present dans le credit !"
l.tut_coders = "Pur les codeurs ! Allez sur la page Github de l'addon afin d'apprendre a developper des applications pour le Gphone"
l.tut_end = "C'etait la presentation des fonctions essentielles du Gphone , merci d'avoir patienter, bon jeu!"

-- App base
l.app_error = "[Erreur]"
l.app_deny_gm = "Vous ne pouvez pas utiliser cette application en Gamemode!"
l.app_deny_group = "Vous n'etes pas dans le groupe requis afin d'utiliser cette fonctionnalite!"

-- Requests
l.confirmation = "Confirmation"
l.confirm = "Confirmer"
l.request = "Demmander"
l.deny = "Refuser"
l.accept = "Accepter"
l.no = "Non"
l.yes = "Oui"
l.okay = "Ok"
l.response_timeout = "%s N'a pas repondu a votre requete dans le temps requis ."

l.accept_fallback = "%s a accpeter votre demmande a %s"
l.phone_accept = "%s a accepter de repondre a votre appel"
l.gpong_accept = "%s a accepeter votre demmande de jeu pour Gpong"

l.deny_fallback = "%s A refuser votre requete a %s"
l.phone_deny = "%s A refuser votre appel"
l.gpong_deny = "%s A refuser votre demmande de jeu pour Gpong"

-- Data transfer
l.transfer_fail_gm = "Vous ne pouvez pas effectuer de virement de votre argent DarkRP quand vous faites parti d'un groupe a part"
l.transfer_fail_cool = "Vous devez attendre %i avant de transferer votre argent"
l.transfer_fail_ply = "Vous ne pouvez pas completer la transaction - Contenu invalide"
l.transfer_fail_amount = "Vous ne pouvez pas completer la transaction - Quantite non valide"
l.transfer_fail_generic = "Desoler , vous devez completer la transaction"
l.transfer_fail_funs = "Vous ne pouvez pas completer la transaction - Vous etes trop pauvre" 

l.received_money = "Vous avez reçu $%i de %s!"
l.sent_money = "Virement $%i a %s effectue!"

l.text_cooldown = "Vou ne pouvez pas envoyer de messages pour %i secondes de plus!"
l.text_flagged = "En raison de votre spam , Vous ne pouvez plus envoyer de messages pour %i secondes!"

l.being_called = "%s vous appel!"

-- Settings
l.wallpapers = "Fonds d'ecran"
l.airplane_mode = "Mode Avion"
l.vibrate = "Vibreur"
l.stop_on_tab = "Arreter la musique en cours"
l.find_album_covers = "Retrouver les fiches d'albums"
l.show_unusable_apps = "Montrer les applications non-usables"
l.reset_app_pos = "Reinitialiser la position des icones"
l.archive_cleanup = "Nettoyer les archives"
l.file_life = "Date de possession du fichier : (days)"
l.wipe_archive = "Supprimer les archives"

l.choose_new_wp = "Choisir un fond d'ecran"
l.wp_selector = "Fonds d'ecran"
l.dark_status = "Barre de notification : sombre"
l.set_lock = "Definir l'ecran de verrouillage"
l.set_home = "Definir l'accueil"
l.reset_homescreen = "Etes vous sur de vouloir reinitialiser la position des icones ?"
l.lang_reboot_warn = "Le Gphone va redemarrer quand le language choisi sera confirme ."

l.no_description = "Aucune description"
l.install_u = "Installer la mise a jour"
l.wipe_archive_confirm = "Etes vous sur de vouloir supprimer les fichiers d'archives ? ( Cette action est irreversible )"
l.archive = "Archive"
l.update = "Mise a jour"
l.set_color = "Choisir la couleur"

l.wipe_log_confirm = "Etes vous sur de vouloir supprimer les logs ? ( Cette action est irreversible )"
l.developer = "Developper"
l.wipe_log = "Supprimer les logs"
l.dump_log = "Jeter le fichier"
l.c_print = "Imprimer la console"

-- Contacts
l.contacts = "Contactes"
l.search = "Rechercher"
l.back = "Retour"
l.number = "Numero"

-- Phone
l.phone = "Telephone"
l.mute = "Muet"
l.unmute = "De-muet"
l.keypad = "Clavier"
l.speaker = "Haut-parleur"
l.add = "Ajouter"
l.end_call = "Fermer l'appel"
l.cannot_call = "%s Ne peut pas etre appeler en ce moment desoler !"
l.hung_up_on = "Votre appel a ete fermer par la personne que vous avez appelee"
l.invalid_player_phone = "Ce n'est pas un numero valide !"

-- Pong
l.gpong = "gPong"
l.playerbot = "Joueur Vs Ordinateur"
l.playerplayer = "Joueur Vs Joueur"
l.playerself = "Joueur Vs Soit"
l.easy = "Facile"
l.medium = "Intermediaire"
l.hard = "Difficile"

l.challenge_ply = "Defier un joueur!"
l.gpong_self_instructions = " Joueur 1:\r\n W et S\r\n Joueur 2:\r\n Haut et Bas (Fleches)" 
l.start = "Commencer!"
l.resume = "Continuer"
l.quit = "Quitter"
l.p1_win = "Le joueur 1 a gagne!"
l.p2_win = "Le joueur 2 a gagne!"

-- Text/Messages
l.messages = "Messages"
l.delete = "Supprimer"
l.last_year = "L'annee passee"
l.yesterday = "Hier"
l.years_ago = "Il y a un an"
l.days_ago = "Il y a quelques jours"
l.send = "Envoyer"
l.new_msg = "Nouveau message"
l.to = "A:"
l.invalid_player_warn = "Ce n'est pas un numero valable"
l.message_len_warn = "Ce message est trop long pour etre envoye!"

-- Store
l.no_homescreen_space = "Vous n'avez pas assez d'espace sur votre accueil afin d'ajouter des icones!"
l.app_store = "App Store"
l.no_apps = "Pas d'applications"
l.no_apps_phrase = "Aucunes applications disponnibles pour le moment ! :("
l.get = "Avoir"
l.have = "En possession"

-- Music
l.music = "Musique"
l.music_format_warn = "Cette URL n'est pas valide ! Le ficghier doit etre en extension .mp3 ou .wav"
l.editor = "Edition"
l.editor_help = "* Seul l'Url de la musique est requise"
l.artist_name = "Nom de l'artiste"
l.song_name = "Nom de la musique"
l.song_url = "URL de la musique"
l.album_url = "URL de l'album" 

-- Finances
l.finances = "Finances"
l.transfer = "Transferer"
l.current_user = "Utilisateur actuel: %s"
l.balance = "Compte: $%s"
l.salary = "Salaire: $%s"
l.wire_money = "Virer des fonds"
l.wire_invalid_player = "Virement imossible!"
l.wire_invalid_amount = "Montant imossible a virer!"
l.wire_no_money = "Vous n'avaez pas assez d'argent afin d'effectuer un virement de ce montant!"
l.receiver = "Destinataire"