-- French language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing

--------------------------------------------------------------------------------------------------------
-- Credits: 
-- 3rd Revision: PwndKilled (STEAM_0:0:71420212)
-- 2nd Revision: r0uge (STEAM_0:0:41083988)
-- 1st Revision: Azmok (STEAM_0:0:75743178)
--------------------------------------------------------------------------------------------------------

local l = gPhone.createLanguage( "français" )

-- General
l.title = "Le Portable Garry"
l.slide_unlock = "Déverouiller"
l.update_check_fail = "La connexion au site web de gPhone a échoué, merci de le signaler sur la page Workshop et de vérifier votre version!"
l.kick = "[gPhone]: ILLEGAL REQUEST - ERROR: 0x01B4D0%s"
l.feature_deny = "Cette fonctionnalité n'a pas encore été ajouté."
l.error = "Erreur"

l.default = "Défaut"
l.language = "Langue"
l.settings = "Paramètres"
l.general = "Général"
l.wallpaper = "Fonds d'écran"
l.homescreen = "Page d'accueil"
l.about = "À propos"
l.color = "Couleur"

l.phone_confis = "Votre portable a été confisqué!"
l.unable_to_open = "Vous ne pouvez pas allumer votre portable pour le moment."

-- Homescreen
l.battery_dead = "Votre portable n'a plus de batterie! Chargement en cours..."
l.battery_okay = "Rechargé!"
l.service_provider = "Garry"
l.folder_fallback = "Dossier"
l.invalid_folder_name = "Non valide"

-- Tutorial
l.tut_welcome = "Bienvenue sur votre gPhone, ceci est une courte présentation pour vous apprendre à utiliser votre nouveau portable."
l.tut_folders = "Vous pouvez modifier la page d'accueil comme vous le souhaiter, comme sur un vrai iPhone."
l.tut_delete = "Maintenez le bouton clic droit de votre souris pour supprimer des applications."
l.tut_text = "Vous pouvez envoyer des messages à vos amis (cliquez sur le coté droit afin de supprimer la conversation)."
l.tut_wallpaper = "Changer le fond d'écran de votre page d'accueil ou de votre écran de verrouillage en téléchargeant des images directement à partir de votre ordinateur."
l.tut_music = "Vous pouvez écouter la musique de votre choix en direct!"
l.tut_translate = "Voulez-vous nous aider à traduire? Ajoutez-moi sur Steam et vous pourriez vous retrouver dans les crédits!"
l.tut_coders = "Attention: codeurs! Visitez la page GitHub afin d'apprendre à développer des applications pour le gPhone."
l.tut_end = "Cette présentation n'a fait qu'effleurer la surface des fonctionnalités du gPhone, amusez-vous bien!"

-- App base
l.app_error = "[Erreur]"
l.app_deny_gm = "Vous ne pouvez pas utiliser cette application dans ce mode de jeu!"
l.app_deny_group = "Vous n'êtes pas dans le groupe nécessaire pour utiliser cette application!"

-- Requests
l.confirmation = "Confirmation"
l.confirm = "Confirmer"
l.request = "Demander"
l.deny = "Refuser"
l.accept = "Accepter"
l.no = "Non"
l.yes = "Oui"
l.okay = "Ok"
l.response_timeout = "%s n'a pas répondu à votre demande à temps."

l.accept_fallback = "%s a accepté votre demande pour utiliser %s"
l.phone_accept = "%s a accepté votre appel"
l.gpong_accept = "%s a accepté votre défi pour jouer à gPong"

l.deny_fallback = "%s a refusé votre demande pour utiliser %s"
l.phone_deny = "%s a refusé votre appel"
l.gpong_deny = "%s a refusé votre défi pour jouer à gPong"

-- Data transfer
l.transfer_fail_gm = "Vous ne pouvez pas transférer d'argent dans ce mode de jeu."
l.transfer_fail_cool = "Vous devez attendre %i secondes avant de pouvoir transférer de l'argent à nouveau."
l.transfer_fail_ply = "Vous ne pouvez pas compléter la transaction - destinataire invalide"
l.transfer_fail_amount = "Vous ne pouvez pas compléter la transaction - quantitée non valide"
l.transfer_fail_generic = "Desolé, vous ne pouvez pas compléter la transaction"
l.transfer_fail_funs = "Vous ne pouvez pas compléter la transaction - vous n'avez pas assez d'argent"

l.received_money = "Vous avez reçu $%i de la part de %s!"
l.sent_money = "Virement de %i$ pour %s effectué!"

l.text_cooldown = "Vous ne pouvez pas envoyer de message pendant %i secondes!"
l.text_flagged = "À cause de votre spam, vous ne pouvez plus envoyer de message pendant %i secondes!"

l.being_called = "%s vous appelle!"

-- Settings
l.wallpapers = "Fonds d'écran"
l.airplane_mode = "Mode avion"
l.vibrate = "Vibreur"
l.stop_on_tab = "Arrêter la musique en cours"
l.find_album_covers = "Retrouver les pochettes d'albums"
l.show_unusable_apps = "Afficher les applications inutilisables"
l.reset_app_pos = "Réinitialiser la position des icônes"
l.archive_cleanup = "Suppression des archives"
l.file_life = "Existence de fichier: (days)"
l.wipe_archive = "Nettoyer les archives"

l.choose_new_wp = "Choisir un nouveau fond d'écran"
l.wp_selector = "Sélectionner un fond d'écran"
l.dark_status = "Assombrir la barre de notification"
l.set_lock = "Choisir le fond d'écran de verrouillage"
l.set_home = "Choisir le fond d'écran de la page d'accueil"
l.reset_homescreen = "Êtes-vous sûr de vouloir réinitialiser la position des icônes de la page d'accueil? (cette action est irréversible)"
l.lang_reboot_warn = "Votre portable va redémarré lorsque le changement de la langue sera effectué et confirmé."

l.no_description = "Aucune description"
l.install_u = "Installer la mise à jour"
l.wipe_archive_confirm = "Êtes-vous sûr de vouloir supprimer les fichiers archivés? (cette action est irréversible)"
l.archive = "Archives"
l.update = "Mise à jour"
l.set_color = "Choisir la couleur"

l.wipe_log_confirm = "Êtes-vous sûr de vouloir supprimer le registre? (cette action est irréversible)"
l.developer = "Développeur"
l.wipe_log = "Supprimer le registre"
l.dump_log = "Créer un fichier comportant le registre"
l.c_print = "Imprimer la console"

l.binds = "Bouttons"
l.open_key = "Boutton d'ouverture"
l.key_hold = "Retenir le bouton"

-- Contacts
l.contacts = "Contacts"
l.search = "Rechercher"
l.back = "Retour"
l.number = "Numéro"

-- Phone
l.phone = "Téléphone"
l.mute = "Désactiver le son"
l.unmute = "Activer le son"
l.keypad = "Clavier"
l.speaker = "Haut-parleur"
l.add = "Ajouter"
l.end_call = "Raccrocher"
l.cannot_call = "%s n'est pas disponible pour le moment, desolé!"
l.hung_up_on = "Votre appel a été coupé par la personne que vous avez appelée"
l.invalid_player_phone = "Ceci n'est pas un numéro valide!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Joueur vs Ordinateur"
l.playerplayer = "Joueur vs Joueur"
l.playerself = "Joueur vs Soi-même"
l.easy = "Facile"
l.medium = "Intermédiaire"
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
l.last_year = "L'année dernière"
l.yesterday = "Hier"
l.years_ago = "il y a 1 an"
l.days_ago = "il y a quelques jours"
l.send = "Envoyer"
l.new_msg = "Nouveau message"
l.to = "À:"
l.invalid_player_warn = "Ceci n'est pas un joueur ou numéro valide"
l.message_len_warn = "Ce message est trop long pour être envoyé!"

-- Store
l.no_homescreen_space = "Vous n'avez plus assez d'espace sur votre page d'accueil pour ajouter une nouvelle application!"
l.app_store = "App Store"
l.no_apps = "Aucune application"
l.no_apps_phrase = "Aucune application disponible pour le moment!"
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
l.finances = "Banque"
l.transfer = "Transférer"
l.current_user = "Utilisateur actuel: %s"
l.balance = "Solde: $%s"
l.salary = "Salaire: $%s"
l.wire_money = "Transférer des fonds"
l.wire_invalid_player = "Destinataire invalide!"
l.wire_invalid_amount = "Montant invalide!"
l.wire_no_money = "Vous n'avez pas assez d'argent pour en envoyer!"
l.receiver = "Destinataire"

-- Flappy Garry
l.enter_play = "Appuyer sur la touche 'Entrée' pour jouer!"

-- Browser
l.connecting = "Connexion"
