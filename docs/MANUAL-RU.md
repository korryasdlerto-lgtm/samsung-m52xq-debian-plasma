# Debian + Plasma Mobile 6.8.3 на mainline-ядре для Samsung Galaxy M52 5G (m52xq) — полное руководство

Выпуск «неофициальная v1», 2026-11-23. Английская версия: [MANUAL-EN.md](MANUAL-EN.md).

## 1. Что это

Debian forky (testing) arm64 с systemd и **KDE Plasma Mobile 6.8.3** (KDE Frameworks 6.30, Qt 6.11) на mainline-ядре Linux 7.1.13 для Samsung
Galaxy M52 5G (SM-M526B / SM-M526BR, Snapdragon 778G / SM7325 «yupik»). Без Halium, libhybris, ядра и служб Android. В Debian forky — Plasma 6.7;
все модули Plasma 6.8.3 собраны для этого порта. Ядро, device tree и службы `m52xq-*` общие с портами Debian Phosh, postmarketOS и Ubuntu Lomiri.
Загрузочный образ использует initramfs postmarketOS, он монтирует корень Debian с раздела `system`. Личный неофициальный проект, проверен на
одном SM-M526BR.

## 2. Что работает

Таблица и известные проблемы — в [README](../README.md#what-works).

## 3. Требования

- Разблокированный загрузчик, TWRP для m52xq: <https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>.
- Резервные копии EFS, persist, modem, boot, vendor_boot, vbmeta (TWRP) и стоковая прошивка для Odin.
- До установки — прошивка на основе Samsung (сток, UN1CA или LineageOS): установщик берёт прошивки устройства с её разделов `vendor`, `apnhlos`,
  `modem`, `persist`, `efs`. UN1CA_3.1.0 даёт самый большой раздел `system`.

## 4. Установка

### 4.1. Архив для TWRP

Видео: <https://www.youtube.com/watch?v=f1Jyf0NcX0M>

1. Скопировать [debian-plasma-mobile-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1RBB5iu6X1_HuRpaFq_SBQ2Z3bwgMjOoi/view?usp=sharing)
   (md5 `ebb4aae33a465c16a5c1c74845d4e644`) на microSD (или `adb push` в `/data` после Format Data в TWRP).
2. В TWRP:

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - debian-plasma-mobile-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

3. Дождаться `Updater process ended with RC=0` (около двух минут). Первая загрузка дольше, затем — мастер первого запуска.

Установщик увеличивает `system` до 8 000 000 000 байт, проверяет, что образ помещается, пишет образ из двух частей, boot, vendor_boot и dtbo, берёт
прошивки с разделов самого телефона (только чтение), добавляет прошивку IPA в ramdisk, готовит реестр датчиков, включает службы и `/home` на
userdata. Слой `m52xq-*` уже внутри образа.

Телефон при установке греется. Если на экране уже есть вертикальные цветные полосы — не устанавливайте.

### 4.2. Пароль и доступ

- Пароль по умолчанию (экран, `user`, `root`): `1111`, смена — `passwd` в QMLKonsole.
- SSH по USB (через ~30 с после загрузки): `ssh root@172.16.42.1`, пароль `1111`.
- Снимок экрана: Громкость+ и Громкость−, папка `~/Pictures/Screenshots`.
- «Reboot menu»: перезагрузка, recovery, выключение; «SIM cards manager»: режим SIM и SIM данных.
- Мобильные данные: плитка переключает подключение «Mobile data» (APN `internet`).

### 4.3. Обновления

27 пакетов на `apt-mark hold` — не снимать, иначе сломаются звонки, две SIM, камера и сон. Пакеты Plasma 6.8.3 (`…-0m52xq1/2/3`) новее, чем в forky,
и останутся, пока в Debian не появится более новая Plasma; каждое обновление сначала проверять `apt-get -s`. `apt update` сообщает об ошибке
локального репозитория сборки: удалить `/etc/apt/sources.list.d/m52xq-plasma.list`.

## 5. Возврат на Android

Видео: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

TWRP («Reboot menu» — «Reboot into recovery» или кнопки питания и громкости); архив прошивки заранее на microSD.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - yes - enter - Reboot System
```

Архивы LineageOS и UN1CA сами перезаписывают boot, vendor_boot и dtbo. Сток — через Odin или Heimdall.

## 6. Ядро

Mainline Linux 7.1.13, исходники <https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq>, конфигурация и патчи выпуска —
[`../kernel/`](../kernel/README.md), образы — в архиве (`firmware/`), DTB — из [`../device-tree/`](../device-tree).

## 7. Сборка с нуля

1. Среда сборки: `debootstrap --arch=arm64 forky rootfs-plasma` (qemu-user-static) и chroot amd64 с кросс-компилятором
   ([`../build/crossdirect/`](../build/crossdirect/README.md): C++ быстрее в 5–50 раз). Команды — [ИНСТРУКЦИЯ.md](ИНСТРУКЦИЯ.md), 2026-11-13.
2. Plasma 6.8.3: архивы из [`../build/plasma-6.8.3-tarballs.txt`](../build/plasma-6.8.3-tarballs.txt) + упаковка Debian 6.7.4, по модулю скриптом
   `build/scripts/build-mod.sh`, порядок — `queue.sh`, исправления упаковки — `build/fixups/<модуль>.sh`. Наши патчи
   ([`../build/patches/`](../build/patches)) добавляют fixups; `M52XQ_REV=2 m52xq-build-mod <модуль>` даёт `-0m52xq2`. В журнале искать
   `PATCH FAIL`: неподходящие патчи скрипт выбрасывает.
3. Пакеты оборудования: папки [`../build/`](../build) (ModemManager, NetworkManager, libcamera → PipeWire → Snapshot и m52xq-rawphoto, libssc),
   `apt-get source` + патчи + `dpkg-buildpackage -B`, затем `apt-mark hold`.
4. Корень телефона: копия корня Debian Phosh без Phosh + пакеты Plasma из локального репозитория (шаги P1–P8 в [ИНСТРУКЦИЯ.md](ИНСТРУКЦИЯ.md)),
   автовход greetd в Plasma Mobile, затем [`../rootfs-overlay/`](../rootfs-overlay).
5. Telegram: `telegram-desktop` 5.7.2+ds-6 из Debian с правкой [`../build/telegram/`](../build/telegram).
6. Образ выпуска: снимок раздела `system` из TWRP и настройки оболочки, очистка — [`../image/build-release.sh`](../image/build-release.sh)
   ([заметки](../image/README.md)); две части, `zip -9` изнутри папки.
7. Состав папки архива: `META-INF/` ([`../installer/`](../installer)), `firmware/`, пустая `mainline-extras/rootfs-files/` (слой в образе),
   `data/rootfs-chunks/`.

## 8. Состав репозитория

См. [README](../README.md#repository-layout).

## 9. Пересобранные программы (`build/`)

См. [README](../README.md#rebuilt-programs-build).

## 10. Службы и скрипты (слой)

| Имя | Что делает |
|---|---|
| `m52xq-adsp-start`, `m52xq-audio-reprobe`, `m52xq-audio-rescue` | запуск ADSP после прошивки на корне, подъём звуковой карты |
| `m52xq-modem-setup`, `m52xq-sim-mode*`, `m52xq-dds`, `m52xq-nas-mode`, `m52xq-flight-mode` | модем и GNSS, режим SIM, SIM данных, режимы сети, авиарежим |
| `m52xq-voicecall`, `m52xq-callaudiod`, `m52xq-voice-mixers.sh`, `m52xq-usb-call-bridge` | голосовой тракт звонка, CallAudio D-Bus, USB-гарнитура |
| `m52xq-tfa-guard` | переоткрывает громкий динамик при сбое усилителя TFA9878 |
| `m52xq-tg-stream`, `m52xq-voip-audio`, `m52xq-audio-route`, `m52xq-speakerphone` | звонки Telegram: разговорный / громкий / гарнитуры, нужный микрофон |
| `m52xq-call-screen-wake`, `m52xq-notify-screen-wake`, `m52xq-notify-sound`, `m52xq-notify-heal` | звонок будит экран и поднимает окно; уведомления и звуки |
| `m52xq-incall-proximity`, `m52xq-sensor-kick`, `m52xq-sensor-reclaim` | экран у уха; датчики после старта ADSP и после сна |
| `m52xq-wifi-soft`, `m52xq-wifi-hw`, `m52xq-wpss-restart`, `m52xq-wl-reset`, `m52xq-wpss-guard` | плитка Wi-Fi: настоящее выключение/включение, холодный перезапуск WPSS, сторож падений |
| хуки system-sleep (`m52xq-*.sh`), `m52xq-wifi-dark`, `m52xq-wow-params` | тёмное пробуждение, GPS, 2G во сне, Wi-Fi во сне, потеря точки, UFS, камера, WoW |
| `m52xq-suspend-guard`, `m52xq-app-reaper`, `m52xq-sleep-report` | повтор сорванного сна, журнал приложений, отчёт о сне |
| `m52xq-gps*`, `m52xq-hotspot*`, `m52xq-nfc` | плитки местоположения, точки доступа, NFC и разрешения |
| `m52xq-virtualcam`, `m52xq-camera-lock-close`, `m52xq-camera-active` | виртуальные камеры, закрытие камеры при блокировке, индикатор |
| `m52xq-home-on-userdata`, `m52xq-ssh-hostkeys`, `m52xq-bt-firmware`, `m52xq-bt-addr.py` | `/home` на userdata, ключи SSH, прошивка и адрес Bluetooth |
| `m52xq-vol-screenshot`, `m52xq-reboot-menu`, `m52xq-sim-manager`, `m52xq-backlight-min` | снимок кнопками, меню перезагрузки, SIM, яркость при загрузке |

## 11. Подводные камни (кратко)

- `/etc/fstab` не должен быть пустым: initramfs pmOS ждёт раздел `pmOS_boot` и уходит в отладочную консоль.
- `m52xq-wpss-restart` без ожидания второй настройки Bluetooth и импульса WL_EN: первое включение Wi-Fi кончается циклом падений WPSS, помогает только
  перезагрузка.
- Сокет KWin здесь `wayland-1`; скрипты с `wayland-0` молча ничего не делают.
- plasmashell должен стартовать после PowerDevil на шине (ползунок яркости), но `After=`/`Wants=` создаёт цикл — ждать в `ExecStartPre`.
- Раскладка домашнего экрана привязана к id активити: без `kactivitymanagerdrc` новая установка начинается с пустого экрана.
- Snapshot под KWin не имеет Mutter DisplayConfig: поворот берётся из iio-sensor-proxy; пересобирать бинарник по-настоящему (`-nc` может пропустить).
- Потоки Telegram не несут свойств `application.*`: определять по клиенту PulseAudio.
- Громкий динамик (TFA9878) молчит в S24_LE: PipeWire открывает карту в S16LE. `MODVERSIONS` выключен: модули только со своим Image.

## 12. Благодарности

Debian и Mobian, KDE Plasma Mobile и разработчики KDE, GNOME Snapshot, libcamera, PipeWire, ModemManager, NetworkManager, Telegram Desktop,
postmarketOS, разработчики mainline Linux для Qualcomm SC7280 / QCM6490, LineageOS (эталонные исходники), сопровождающие TWRP для m52xq.
