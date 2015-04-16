-- French language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

--------------------------------------------------------------------------------------
--  French translation by r0uge for the gPhone. http://steamcommunity.com/id/r0uge  --
--------------------------------------------------------------------------------------

local l = gPhone.createLanguage( "français" )

-- General
l.title = "Le Portable Garry"
l.slide_unlock = "Déverouiller"
l.feature_deny = "Cette fonctionnalité n'as pas encore été mis en œuvre"
l.error = "Erreur"

l.default = "Défaut"
l.language = "Langue"
l.settings = "Paramètres"
l.general = "Général"
l.wallpaper = "Fond d'écran"
l.homescreen = "Page d'accueil"
l.about = "À propos"
l.color = "Couleur"

l.phone_confis = "Votre portable a été confisqué!"
l.unable_to_open = "Vous n'êtes pas capable d'allumer votre portable en ce moment."

-- Homescreen
l.battery_okay = "Rechargé!"
l.service_provider = "Garry"
l.folder_fallback = "Dossier"
l.invalid_folder_name = "Non valide"

-- Tutorial
l.tut_welcome = "Bienvenue à votre gPhone, ceci est une courte présentation pour vous apprendre à utiliser votre nouveau portable."
l.tut_folders = "Vous pouvez modifier la page d'accueil comme vous voulez, pareil qu'un vrai iPhone."
l.tut_delete = "Maintenez le clic droit pour supprimer des applications."
l.tut_text = "Vous pouvez envoyer des messages à vos amis (cliquez le coté droit afin de supprimer votres conversations)."
l.tut_wallpaper = "Vous pouvez changer votre fond d'écran de vérrouillage ainsi que celui de la page d'accueil en téléchargeant les images sur votre ordinateur."
l.tut_music = "Vous pouvez écouter la musiques de votre choix en direct!"
l.tut_translate = "Voulez-vous nous aider à traduire? Ajoutez-moi sur Steam et vous pouvez vous retrouver dans les crédits!"
l.tut_coders = "Attention: codeurs! Visitez la page GitHub afin d'apprendre à développer des applications pour le gPhone."
l.tut_end = "Cette présentation n'a fait qu'effleurer la surface des fonctionnalités du gPhone, amusez-vous bien!"

-- App base
l.app_error = "[Erreur]"
l.app_deny_gm = "Vous ne pouvez pas utiliser cette application dans cette mode de jeu!"
l.app_deny_group = "Vous n'êtes pas dans le groupe nécessaire afin d'utiliser cette application!"

-- Requests
l.confirmation = "Confirmation"
l.confirm = "Confirmer"
l.request = "Demander"
l.deny = "Refuser"
l.accept = "Accepter"
l.no = "Non"
l.yes = "Oui"
l.okay = "Ok"
l.response_timeout = "%s n'a pas repondu a votre demande à temps."

l.accept_fallback = "%s a accepté votre demande a utiliser %s"
l.phone_accept = "%s a accepté votre appel"
l.gpong_accept = "%s a accepté votre défi de jeu de gPong"

l.deny_fallback = "%s a refusé votre demande a utiliser %s"
l.phone_deny = "%s a refusé votre appel"
l.gpong_deny = "%s a refusé votre défi de jeu de gPong"

-- Data transfer
l.transfer_fail_gm = "Vous ne pouvez pas transférer de l'argent dans cette mode de jeu."
l.transfer_fail_cool = "Vous devez attendre %i avant transférer votre argent"
l.transfer_fail_ply = "Vous ne pouvez pas compléter la transaction - destinataire invalide"
l.transfer_fail_amount = "Vous ne pouvez pas compléter la transaction - quantitée non valide"
l.transfer_fail_generic = "Desolé, ne pouvez pas compléter la transaction"
l.transfer_fail_funs = "Vous ne pouvez pas compléter la transaction - vous n'avez pas assez d'argent" 

l.received_money = "Vous avez reçu $%i de %s!"
l.sent_money = "Virement $%i à %s effectué!"

l.text_cooldown = "Vous ne pouvez pas envoyer de messages pour %i secondes!"
l.text_flagged = "À cause de votre spam, vous ne pouvez plus envoyer de messages pour %i secondes!"

l.being_called = "%s vous appelle!"

-- Settings
l.wallpapers = "Fonds d'écran"
l.airplane_mode = "Mode avion"
l.vibrate = "Vibreur"
l.stop_on_tab = "Arrêter la musique en cours"
l.find_album_covers = "Retrouver les pochettes d'albums"
l.show_unusable_apps = "Afficher les applications inutilisables"
l.archive_cleanup = "Effacement des archives"
l.file_life = "Existence de fichier: (days)"
l.wipe_archive = "Supprimer les archives"

l.choose_new_wp = "Choisir un fond d'écran"
l.wp_selector = "Selection de fonds d'écrans"
l.dark_status = "Assombrir la barre de notification"
l.set_lock = "Choisir le fond d'écran de verrouillage"
l.set_home = "Choisir le fond d'écran de la page d'accueil"

l.no_description = "Aucune description"
l.install_u = "Installer la mise à jour"
l.wipe_archive_confirm = "Êtes vous sûr de vouloir supprimer les fichiers d'archives? (cette action est irréversible)"
l.archive = "Archives"
l.update = "Mise à jour"
l.set_color = "Choisir la couleur"

l.wipe_log_confirm = "Êtes vous sûr de vouloir supprimer les records? (cette action est irréversible)"
l.developer = "Développeur"
l.wipe_log = "Supprimer les records"
l.dump_log = "Décharger au fichier"
l.c_print = "Imprimer la console"

l.binds = "Clés"
l.open_key = "Clé d'ouverture"
l.key_hold = "Temps de retenir la clé"

-- Contacts
l.contacts = "Contactes"
l.search = "Rechercher"
l.back = "Retour"
l.number = "Numéro"

-- Phone
l.phone = "Téléphone"
l.mute = "Couper le son"
l.unmute = "Rallumer le son"
l.keypad = "Clavier"
l.speaker = "Haut-parleur"
l.add = "Ajouter"
l.end_call = "Couper l'appel"
l.cannot_call = "%s n'est pas disponible en ce moment, desolé!"
l.hung_up_on = "Votre appel a été coupé par la personne que vous avez appelée"

-- Pong
l.gpong = "gPong"
l.playerbot = "Joueur vs Ordinateur"
l.playerplayer = "Joueur vs Joueur"
l.playerself = "Joueur vs Soit-Même"
l.easy = "Facile"
l.medium = "Intermediaire"
l.hard = "Difficile"

l.challenge_ply = "Défier un joueur!"
l.gpong_self_instructions = " Joueur 1:\r\n W et S\r\n Joueur 2:\r\n Haut et Bas (flèches)" 
l.start = "Commencer!"
l.resume = "Continuer"
l.quit = "Quitter"
l.p1_win = "Joueur 1 a gagné!"
l.p2_win = "Joueur 2 a gagné!"

-- Text/Messages
l.messages = "Messages"
l.delete = "Supprimer"
l.last_year = "L'année passée"
l.yesterday = "Hier"
l.years_ago = "ans passés"
l.days_ago = "jours passés"
l.send = "Envoyer"
l.new_msg = "Nouveau message"
l.to = "A:"
l.invalid_player_warn = "Ceci n'est pas un numéro valide"
l.message_len_warn = "Ce message est trop long pour être envoyé!"

-- Store
l.app_store = "App Store"
l.no_apps = "Aucunes applications"
l.no_apps_phrase = "Aucunes applications disponibles pour le moment!"
l.get = "Obtenir"
l.have = "Avoir"

-- Music
l.music = "Musique"
l.music_format_warn = "Cet URL n'est pas valide! Le fichier doit être un .mp3 ou un .wav"
l.editor = "Éditeur"
l.editor_help = "* Seul l'URL de la musique est nécessaire"
l.artist_name = "Nom de l'artiste"
l.song_name = "Nom de la chanson"
l.song_url = "URL de la chanson"
l.album_url = "URL de l'album" 

-- Finances
l.finances = "Finances"
l.transfer = "Transférer"
l.current_user = "Utilisateur actuel: %s"
l.balance = "Compte: $%s"
l.salary = "Salaire: $%s"
l.wire_money = "Transférer des fonds"
l.wire_invalid_player = "Destinataire invalide!"
l.wire_invalid_amount = "Montant invalide!"
l.wire_no_money = "Vous n'avez pas assez d'argent à envoyer!"
l.receiver = "Destinataire"

-- Flappy Garry
l.enter_play = "Appuyer 'Entrée' pour jouer!"

-- Browser
l.connecting = "Connexion"