// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get aboutFlauncher => 'Об Arc Launcher';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get addSection => 'Добавить раздел';

  @override
  String get alphabetical => 'По алфавиту';

  @override
  String get appCardHighlightAnimation => 'Анимация выделения карточки';

  @override
  String get showFocusBorders => 'Рамка вокруг выбранного';

  @override
  String get tvosStyle => 'Стиль Apple TV';

  @override
  String get focusBorderThickness => 'Толщина рамки выделения';

  @override
  String get focusBorderThin => 'Тонкая (1.0 dp)';

  @override
  String get focusBorderDefault => 'Обычная (1.5 dp)';

  @override
  String get focusBorderMedium => 'Средняя (2.0 dp)';

  @override
  String get focusBorderBold => 'Толстая (3.0 dp)';

  @override
  String get appInfo => 'О приложении';

  @override
  String get appKeyClick => 'Звук нажатия клавиш';

  @override
  String get appearanceSettings => 'Оформление';

  @override
  String get backgroundBlur => 'Размытие фона';

  @override
  String get dockBlur => 'Размытие дока';

  @override
  String get dockDarkBackground => 'Тёмный фон дока';

  @override
  String get dockShadow => 'Тень дока';

  @override
  String get applications => 'Приложения';

  @override
  String get autoHideAppBar => 'Автоматически скрывать строку состояния';

  @override
  String get hideStatusBarInGrid => 'Скрывать строку состояния в сетке';

  @override
  String get backButtonAction => 'Действие кнопки «Назад»';

  @override
  String get category => 'Категория';

  @override
  String get categories => 'Категории';

  @override
  String get columnCount => 'Число столбцов';

  @override
  String get date => 'Дата';

  @override
  String get dateAndTimeFormat => 'Формат даты и времени';

  @override
  String get delete => 'Удалить';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Ничего не делать';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'Показать заставку';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Показать часы';

  @override
  String get dialogTextNoFileExplorer =>
      'Чтобы выбрать картинку, установите файловый менеджер.';

  @override
  String get dialogTitleBackButtonAction => 'Что делает кнопка «Назад»';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (категория)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Дата: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Время: $timeString';
  }

  @override
  String get gradient => 'Градиент';

  @override
  String get favoriteApps => 'Избранное';

  @override
  String get grid => 'Сетка';

  @override
  String get height => 'Высота';

  @override
  String get hide => 'Скрыть';

  @override
  String get hiddenApplications => 'Скрытые приложения';

  @override
  String get launcherSections => 'Разделы';

  @override
  String get layout => 'Раскладка';

  @override
  String get loading => 'Загрузка';

  @override
  String get manual => 'Вручную';

  @override
  String get modifySection => 'Изменить раздел';

  @override
  String get mustNotBeEmpty => 'Не может быть пустым';

  @override
  String get name => 'Название';

  @override
  String get newSection => 'Новый раздел';

  @override
  String get noDateFormatSpecified => 'Формат даты не задан';

  @override
  String get noTimeFormatSpecified => 'Формат времени не задан';

  @override
  String get allApplications => 'Все приложения';

  @override
  String get nonTvApplications => 'Приложения не для ТВ';

  @override
  String get open => 'Открыть';

  @override
  String get orSelectFormatSpecifiers => 'Или выберите элементы формата';

  @override
  String get picture => 'Картинка';

  @override
  String removeFrom(String name) {
    return 'Убрать из «$name»';
  }

  @override
  String get renameCategory => 'Переименовать категорию';

  @override
  String get reorder => 'Переместить';

  @override
  String get row => 'Ряд';

  @override
  String get rowHeight => 'Высота ряда';

  @override
  String get save => 'Сохранить';

  @override
  String get spacer => 'Отступ';

  @override
  String get spacerMaxHeightRequirement =>
      'Должно быть больше 0 и не больше 500';

  @override
  String get statusBar => 'Строка состояния';

  @override
  String get settings => 'Настройки';

  @override
  String get show => 'Показать';

  @override
  String get showCategoryTitles => 'Показывать названия категорий';

  @override
  String get sort => 'Сортировка';

  @override
  String get systemSettings => 'Настройки системы';

  @override
  String get updateCheck => 'Проверить обновления';

  @override
  String get updateNoUpdateTitle => 'Обновлений нет';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'У вас последняя версия ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Доступно обновление';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'Доступна версия $latestVersion (сейчас: $currentVersion).';
  }

  @override
  String get updateChangelog => 'Что нового';

  @override
  String get updateDownloadButton => 'Скачать';

  @override
  String get updateReadyToInstallTitle => 'Готово к установке';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'APK версии $latestVersion скачан. Установить сейчас?';
  }

  @override
  String get updateInstallButton => 'Установить';

  @override
  String get updateInstallPermissionTitle => 'Нужно разрешение на установку';

  @override
  String get updateInstallPermissionBody =>
      'Разрешите Arc Launcher устанавливать неизвестные приложения и повторите обновление.';

  @override
  String get updateOpenPermissionSettingsButton =>
      'Открыть настройки разрешений';

  @override
  String get updateErrorGeneric =>
      'Не удалось проверить обновления. Попробуйте ещё раз.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'Arc Launcher — открытый лаунчер для Android TV на основе FLauncher.\n\nАвтор: Meddouri Badis.\nИсходный код: $repoUrl.';
  }

  @override
  String get textEmptyCategory => 'В этой категории пусто.';

  @override
  String get time => 'Время';

  @override
  String get titleStatusBarSettingsPage => 'Что показывать в строке состояния';

  @override
  String get tvApplications => 'Приложения для ТВ';

  @override
  String get type => 'Тип';

  @override
  String get typeInTheDateFormat => 'Введите формат даты';

  @override
  String get typeInTheHourFormat => 'Введите формат времени';

  @override
  String get uninstall => 'Удалить';

  @override
  String get wallpaper => 'Обои';

  @override
  String get withEllipsisAddTo => 'Добавить в…';

  @override
  String get timeBasedWallpaper => 'Обои по времени суток';

  @override
  String get unsplashSlideshow => 'Слайд-шоу Unsplash';

  @override
  String get unsplashEnable => 'Показывать фото с Unsplash';

  @override
  String get unsplashAccessKey => 'Ключ доступа Unsplash';

  @override
  String get unsplashAccessKeyHelp =>
      'Создайте бесплатное приложение на unsplash.com/developers и вставьте его Access Key.';

  @override
  String get unsplashNotSet => 'Не задан';

  @override
  String get unsplashInterval => 'Менять каждые';

  @override
  String unsplashIntervalMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get slideshowCategories => 'Категории';

  @override
  String get slideshowDay => 'День (6:00 – 18:00)';

  @override
  String get slideshowNight => 'Ночь (18:00 – 6:00)';

  @override
  String unsplashPhotoCredit(String author) {
    return 'Фото: $author / Unsplash';
  }

  @override
  String get pickDayWallpaper => 'Выбрать дневные обои';

  @override
  String get pickNightWallpaper => 'Выбрать ночные обои';

  @override
  String get video => 'Видео';

  @override
  String get pickDayVideoWallpaper => 'Выбрать дневное видео';

  @override
  String get pickNightVideoWallpaper => 'Выбрать ночное видео';

  @override
  String get watchNextSectionTitle => 'Продолжить просмотр';

  @override
  String get showWatchNextSection => 'Показывать «Продолжить просмотр»';

  @override
  String get watchNextPermissionTitle => 'Нужно разрешение';

  @override
  String get watchNextPermissionBody =>
      'Разрешите доступ к телепрограмме, чтобы видеть, что вы недосмотрели.';

  @override
  String get watchNextGrantPermission => 'Разрешить';

  @override
  String get watchNextCheckPermission => 'Проверить снова';

  @override
  String get interface => 'Интерфейс';

  @override
  String get system => 'Система';

  @override
  String get accentColor => 'Цвет акцента';

  @override
  String get miscellaneous => 'Разное';

  @override
  String get brightnessScheduler => 'Яркость по расписанию';

  @override
  String get screensaverSettings => 'Настройки заставки';

  @override
  String get screensaverClockStyle => 'Стиль часов на заставке';

  @override
  String get wifiUsagePeriod => 'Период трафика Wi-Fi';

  @override
  String get showAppNamesBelowIcons => 'Названия под приложениями';

  @override
  String get wifiUsage => 'Трафик Wi-Fi';

  @override
  String get networkIndicator => 'Индикатор сети';

  @override
  String get customName => 'Своё название';

  @override
  String get lastUsed => 'Недавние';

  @override
  String get daily => 'За день';

  @override
  String get weekly => 'За неделю';

  @override
  String get monthly => 'За месяц';

  @override
  String get grantPermission => 'Разрешить';

  @override
  String get checkStatus => 'Проверить';

  @override
  String get watchNextBigPictureMode => 'Полноэкранный режим';

  @override
  String get watchNextBigPictureModeDescription =>
      'Большая обложка на весь экран с кнопкой просмотра';

  @override
  String get watchNextWatch => 'Смотреть';

  @override
  String get watchNextResume => 'Продолжить';

  @override
  String get watchNextRefresh => 'Обновить';

  @override
  String get watchNextRefreshDescription =>
      'Заново загрузить рекомендации из приложений';

  @override
  String get watchNextRefreshed => '«Продолжить просмотр» обновлено';

  @override
  String get watchNextFilterApps => 'Фильтр приложений';

  @override
  String get watchNextFilterAppsDescription =>
      'Какие приложения могут показывать здесь свой контент';

  @override
  String get watchNextNoApps =>
      'Сейчас ни одно приложение не передаёт контент для этого раздела';

  @override
  String get watchNextShowAllApps => 'Показать все приложения';

  @override
  String get watchNextHideWithoutImages => 'Скрывать без картинки';

  @override
  String get watchNextHideWithoutImagesDescription =>
      'Показывать только программы с постером или обложкой';

  @override
  String get watchNextMaxItems => 'Максимум программ';

  @override
  String get watchNextMaxItemsDescription =>
      'Сколько программ показывать в разделе';

  @override
  String get watchNextMaxItemsUnlimited => 'Без ограничений';

  @override
  String get redditWallpaper => 'Обои с Reddit';

  @override
  String get redditWallpaperEnable => 'Показывать обои с Reddit';

  @override
  String get redditSubreddits => 'Сабреддиты';

  @override
  String get redditSort => 'Сортировка';

  @override
  String get redditSortHot => 'Популярные';

  @override
  String get redditSortTopDay => 'Лучшие за день';

  @override
  String get redditSortTopWeek => 'Лучшие за неделю';

  @override
  String get redditSortTopMonth => 'Лучшие за месяц';

  @override
  String get redditSortTopAll => 'Лучшие за всё время';

  @override
  String get redditSortNew => 'Новые';

  @override
  String get redditInterval => 'Менять каждые';

  @override
  String redditIntervalMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get redditInterval1Hour => '1 час';

  @override
  String redditIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours часов',
      few: '$hours часа',
      one: '$hours час',
    );
    return '$_temp0';
  }

  @override
  String get redditInterval1Day => '1 день';

  @override
  String redditIntervalDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String get redditClientId => 'Reddit Client ID (необязательно)';

  @override
  String get redditClientIdHelp =>
      'Необязательно. Создайте приложение типа installed на reddit.com/prefs/apps и вставьте его ID, если без него не работает.';

  @override
  String get redditChangeNow => 'Сменить обои сейчас';

  @override
  String get redditAddSubreddit => 'Добавить сабреддит';

  @override
  String get redditSubredditName => 'Название сабреддита (без r/)';

  @override
  String get redditSubredditAdded => 'Сабреддит добавлен';

  @override
  String get redditSubredditInvalid => 'Введите корректное название сабреддита';

  @override
  String get redditWallpaperUpdated => 'Обои обновлены';

  @override
  String get redditWallpaperFailed =>
      'Не удалось загрузить обои. Если ошибка повторяется, укажите Reddit Client ID в настройках.';

  @override
  String get addToFavorites => 'В избранное';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String get addToCategory => 'Добавить в категорию';

  @override
  String get setCustomBanner => 'Свой баннер';

  @override
  String get clearCustomBanner => 'Убрать свой баннер';

  @override
  String customBannerSetFailed(String error) {
    return 'Не удалось установить баннер: $error';
  }

  @override
  String customBannerClearFailed(String error) {
    return 'Не удалось убрать баннер: $error';
  }

  @override
  String get selectImage => 'Выбрать картинку';

  @override
  String get selectVideo => 'Выбрать видео';

  @override
  String mediaItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String get noImagesFound => 'На устройстве нет картинок';

  @override
  String get noVideosFound => 'На устройстве нет видео';

  @override
  String get mediaNavigationHint => 'Стрелки: выбор  •  Назад: отмена';

  @override
  String get mediaSelectionHint =>
      'Стрелки: выбор  •  OK: поставить обои  •  Назад: отмена';

  @override
  String get mediaPermissionRequired => 'Нужен доступ к медиафайлам';

  @override
  String get mediaPermissionHelp =>
      'Разрешите доступ, чтобы выбирать фото и видео';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get colorPurple => 'Фиолетовый';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorPink => 'Розовый';

  @override
  String get colorGreen => 'Зелёный';

  @override
  String get colorWhite => 'Белый';

  @override
  String get colorYellow => 'Жёлтый';

  @override
  String get colorRed => 'Красный';

  @override
  String get colorCyan => 'Голубой';

  @override
  String get colorIndigo => 'Индиго';

  @override
  String get colorLime => 'Лайм';

  @override
  String get colorAmber => 'Янтарный';

  @override
  String get colorRose => 'Розовый (тёплый)';

  @override
  String get colorIceBlue => 'Ледяной';

  @override
  String get clockStyleMinimal => 'Минимал';

  @override
  String get clockStyleMinimalDescription =>
      'Тонкий элегантный шрифт (по умолчанию)';

  @override
  String get clockStyleBold => 'Жирный';

  @override
  String get clockStyleBoldDescription => 'Толстый, хорошо заметный шрифт';

  @override
  String get clockStyleRetro => 'Ретро';

  @override
  String get clockStyleRetroDescription =>
      'Моноширинный, как в старом терминале';

  @override
  String get clockStyleElegant => 'Элегантный';

  @override
  String get clockStyleElegantDescription => 'Классический шрифт с засечками';

  @override
  String get clockStyleNeon => 'Неон';

  @override
  String get clockStyleNeonDescription => 'Ультратонкий, со свечением';

  @override
  String get clockStylePixel => 'Пиксель';

  @override
  String get clockStylePixelDescription => 'Жирный моноширинный, как в аркадах';

  @override
  String get clockStyleDigital => 'Цифровой';

  @override
  String get clockStyleDigitalDescription => 'Чистый моноширинный дисплей';

  @override
  String get brightnessPermissionRequired => 'Нужно разрешение';

  @override
  String get brightnessPermissionHelp =>
      'Чтобы управлять яркостью на этом устройстве, выдайте разрешение через ADB:';

  @override
  String get brightnessExperimentalNotice =>
      'ЭКСПЕРИМЕНТАЛЬНО: функция не протестирована и может быть убрана в будущих версиях.';

  @override
  String get brightnessDeviceSupportNote =>
      'Некоторые Android TV не позволяют приложениям менять яркость.';

  @override
  String get enableBrightnessScheduler => 'Включить расписание';

  @override
  String currentBrightnessSlot(String slot) {
    return 'Сейчас: $slot';
  }

  @override
  String get brightnessSlotMorning => '6:00 – 9:00';

  @override
  String get brightnessSlotDay => '9:00 – 15:00';

  @override
  String get brightnessSlotAfternoon => '15:00 – 18:00';

  @override
  String get brightnessSlotEvening => '18:00 – 22:00';

  @override
  String get brightnessSlotNight => '22:00 – 6:00';
}
