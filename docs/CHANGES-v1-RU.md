# Неофициальная v1 (первый публичный выпуск)

| | |
|---|---|
| Ядро | 7.1.13, та же сборка, что в Debian Phosh / postmarketOS Phosh v1 (`kernel/patches/`) |
| Корень | Debian forky arm64, Plasma Mobile 6.8.3 (своя сборка), KDE Frameworks 6.30, Qt 6.11; 1815 пакетов ([список](packages-debian.txt)), 27 на удержании |
| Образ | снимок раздела system телефона из TWRP, без личных данных, ключей и закрытых прошивок; ext4 5400 МиБ, 2 части |
| Архив | `debian-plasma-mobile-m52xq-mainline-v1.zip` (1,69 ГБ), md5 `ebb4aae33a465c16a5c1c74845d4e644` |

- **Плитка Wi-Fi** по-настоящему выключает Wi-Fi (выгрузка ath11k, остановка WPSS) и включает без цикла падений прошивки: `m52xq-wpss-restart` ждёт
  вторую настройку Bluetooth и подаёт импульс WL_EN (`m52xq-wl-reset`); проверено: 2 полных цикла и включение Bluetooth, падений 0.
- **Telegram:** входящий звонок будит экран и выводит окно звонка, сообщение — нет (`m52xq-call-screen-wake` смотрит клиента звукового потока);
  выключение и включение камеры в звонке больше не роняет программу (правка 8 байт, `build/telegram`).
- **Камера:** GNOME Snapshot m52xq6 — поворот по акселерометру (в KWin нет Mutter DisplayConfig), правильная ориентация после смены камеры; libcamera 0.8,
  PipeWire пересобран под неё.
- Плитки NFC, «Местоположение», Speakerphone, Sound output, Hotspot; исправлен ползунок яркости (plasmashell запускается после PowerDevil).
- `/home` на разделе userdata; модули Venus, исправление громкой связи и звук USB из выпуска Phosh.
- Сон без точки доступа Wi-Fi: на время сна ath11k выгружается (`m52xq-wifi-lost.sh`).

Известные проблемы — в README.
