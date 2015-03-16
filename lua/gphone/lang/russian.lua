--// Russian language translations
-- Letters prefixed with a '%' (ex: %s, %i) are substituted for variables during run time, don't break those
-- '\n' and '\r\n' are used to create a new line, try to keep those in similar spots to preserve spacing
-- By PORTAL2 (STEAM_0:0:59342541)

--local l = gPhone.createLanguage( "русский" )
local l = {}

-- General
l.title = "Телефон Garry"
l.slide_unlock = "Слайд для разблокирования"
l.update_check_fail = "Подключение к gPhone сайт дал сбой, пожалуйста, сообщите об этом на семинаре страницу и проверить вашу версию!"
l.kick = "[gPhone]: НЕДОПУСТИМЫЙ ЗАПРОС - ОШИБКА: 0x01B4D0%s"
l.feature_deny = "Выбранная функция еще не реализована"
l.error = "Ошибка"

l.default = "По умолчанию"
l.language = "Язык"
l.settings = "Параметры"
l.general = "Общий"
l.wallpaper = "Обои"
l.homescreen = "Рабочий стол"
l.about = "About"
l.color = "Цвет"

-- Homescreen
l.battery_dead = "Ваш телефон работает от батареи и разредился! Зарядка..."
l.battery_okay = "Зарядка!"
l.service_provider = "Garry"
l.folder_fallback = "Папка"
l.invalid_folder_name = "Недействительный"

-- Tutorial
l.tut_welcome = "Добро пожаловать в Garry Phone! Это краткое введение об основах телефона."
l.tut_folders = "Использовать рабочем столе создавать папки и перемещать вокруг приложений просто как настоящий iPhone."
l.tut_delete = "Удерживая правую кнопку мыши, чтобы переключить приложение в режим удаления."
l.tut_text = "Текст ваших друзей можно удалить с помощью приложения Сообщения! Щелкнув правой кнопкой мыши."
l.tut_wallpaper = "Изменить обои или экран блокировки, используйте изображение с компьютера."
l.tut_music = "Вы можете слушать музыку из интернета или вашего компьютера с помощью приложения музыка"
l.tut_translate = "Хотите помочь с переводом? Добавьте меня в Steam!"
l.tut_coders = "Кодеры: посмотрите в вики на Github пример приложения"
l.tut_end = "Это только первые функции телефона. Удачи!!"

-- App base
l.app_error = "[App Error]"
l.app_deny_gm = "Это приложение не может использоваться в этот моде!"
l.app_deny_group = "Вы не в той группе, чтобы использовать это приложение!"

-- Requests
l.confirmation = "Подтверждение"
l.confirm = "Подтвердить"
l.request = "Запрос"
l.deny = "Отклонить"
l.accept = "Приминать"
l.no = "Нет"
l.yes = "Да"
l.okay = "Ок"
l.response_timeout = "%s не ответить на ваш запрос."

l.accept_fallback = "%s принял ваш запрос на использование %s"
l.phone_accept = "%s принял ваш звонок."
l.gpong_accept = "%s принял ваш запрос, чтобы играть gPong"

l.deny_fallback = "%s отклонил ваш запрос на использование %s"
l.phone_deny = "%s опроверг ваш звонок"
l.gpong_deny = "%s отклонил ваш запрос, чтобы играть gPong"

-- Data transfer
l.transfer_fail_gm = "You cannot wire money in gamemodes that are not DarkRP"
l.transfer_fail_cool = "Вы должны ждать %i's прежде чем переносить больше денег"
l.transfer_fail_ply = "Не в состоянии завершить сделку - недействительной получатель"
l.transfer_fail_amount = "Не удается завершить транзакцию - нулевую сумму"
l.transfer_fail_generic = "Не удается завершить транзакцию"
l.transfer_fail_funs = "Не в состоянии завершить сделку из - за отсутствия средств" 

l.received_money = "Получено $%i от %s!"
l.sent_money = "Перевод $%i на %s успешно!"

l.text_cooldown = "Вы не можете писать %i больше секунд"
l.text_flagged = "Для предотвращения спама, вы были заблокированы от текстовых сообщений на %i секунд!"

l.being_called = "%s вам звонит!"

-- Settings
l.wallpapers = "Обои"
l.airplane_mode = "Режим полета"
l.vibrate = "Вибрация"
l.stop_on_tab = "Остановить музыку на Tab"
l.find_album_covers = "Подобрать блошку для альбома"
l.show_unusable_apps = "Показать не пригодное для использования приложении"
l.reset_app_pos = "Упорядочить значки автоматически"
l.archive_cleanup = "Очистить архив"
l.file_life = "Файл жизни (дней)"
l.wipe_archive = "Очистить архив"

l.choose_new_wp = "Выбрать новые обои"
l.wp_selector = "Обои селектор"
l.dark_status = "Даркен статус бар"
l.set_lock = "Набор блокировочного экрана"
l.set_home = "Установить рабочий стол"
l.reset_homescreen = "Вы уверены, что хотите сбросить рабочий стол и значок позиции?"
l.lang_reboot_warn = "gPhone перезагрузился, измените язык и подтвердите."

l.no_description = "Нет описания"
l.install_u = "Установите обновление"
l.wipe_archive_confirm = "Вы уверены, что хотите удалить все файлы в архиве? (это не может быть отменено)"
l.archive = "Архив"
l.update = "Обновление"
l.set_color = "Установить Цвет"

l.wipe_log_confirm = "Вы уверены, что хотите стереть логи? (Этого не может быть отменено)"
l.developer = "Разработчик"
l.wipe_log = "Очистить журнал"
l.dump_log = "Сброс файла"
l.c_print = "Консоль для печати"

-- Contacts
l.contacts = "Контакты"
l.search = "Поиск"
l.back = "Назад"
l.number = "Число"

-- Phone
l.phone = "Телефон"
l.mute = "Отключить звук"
l.unmute = "Включить звук"
l.keypad = "Клавиатура"
l.speaker = "Динамик"
l.add = "Добавить"
l.end_call = "Завершить вызов"
l.cannot_call = "%s нельзя звонить в этот моменты."
l.hung_up_on = "Ваш звонок завершился человеком, которому вы звонили"
l.invalid_player_phone = "Этот номер не доступен!"

-- Pong
l.gpong = "gPong"
l.playerbot = "Игрок v Бот"
l.playerplayer = "Игрок 1 v Игрок 2"
l.playerself = "Игрок 1 v Игрок 1"
l.easy = "Легкий"
l.medium = "Средний"
l.hard = "Сложный"

l.challenge_ply = "Задача Игрока!"
l.gpong_self_instructions = " Игрок 1:\r\n W and S\r\n Игрок 2:\r\n Up and Down arrow keys" 
l.start = "Старт!"
l.resume = "Возобновить"
l.quit = "Выйти"
l.p1_win = "Р1 выигрывает!"
l.p2_win = "P2 выигрывает!"

-- Text/Messages
l.messages = "Сообщения"
l.delete = "Удалить"
l.last_year = "прошлый год"
l.yesterday = "вчерашнее"
l.years_ago = "лет назад"
l.days_ago = "дней назад"
l.send = "Отправить"
l.new_msg = "Новое сообщение"
l.to = "Для:"
l.invalid_player_warn = "That is not a valid player or number to send a message to"
l.message_len_warn = "Текст сообщения слишком длинный чтобы его отправить!"

-- Store
l.no_homescreen_space = "У вас не хватает места на рабочем столе, чтобы добавить новое приложение.!"
l.app_store = "Магазин"
l.no_apps = "Нет приложений"
l.no_apps_phrase = "Нет доступных переложений, звените :(  "
l.get = "Получить"
l.have = "Иметь"

-- Music
l.music = "Уузыка"
l.music_format_warn = "Расширение файла должно быть .mp3 или .wav"
l.editor = "Редактор"
l.editor_help = "* Для музыки требуется  URL адрес"
l.artist_name = "Имя исполнителя"
l.song_name = "Название песни"
l.song_url = "Песня URL-Адрес"
l.album_url = "Альбом URL-Адрес" 

-- Finances
l.finances = "Финансовое состояние"
l.transfer = "Перечислить"
l.current_user = "Текущий Пользователь: %s"
l.balance = "Баланс: $%s"
l.salary = "Зарплата: $%s"
l.wire_money = "Перевод денег"
l.wire_invalid_player = "Недопустимое целевое для перевода денег!"
l.wire_invalid_amount = "Недействительным сумму денег, для провода!"
l.wire_no_money = "у вас нет таких денег, чтобы их отправить!"
l.receiver = "Получатель" 