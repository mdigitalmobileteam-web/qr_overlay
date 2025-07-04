# QR Overlay Package

[![GitLab release](https://img.shields.io/badge/GitLab-v1.0.1-orange)](https://gitlab.mdigital.kg/mobile-global/qr_overlay)
![Flutter](https://img.shields.io/badge/Flutter-%5E3.0.0-blue)

Кастомизируемый оверлей для сканирования QR-кодов с анимированным позиционированием и визуальными эффектами. Пакет идеально интегрируется с [mobile_scanner](https://pub.dev/packages/mobile_scanner).

## Особенности

- 🎯 Точное отслеживание QR-кодов
- 🚀 Плавная анимация перемещения
- 🎨 Настраиваемый дизайн (цвета, размеры)
- 🌑 Автоматическое затемнение фона вокруг QR
- ⚙️ Поддержка различных режимов камеры

## Установка

Добавьте в `pubspec.yaml` вашего проекта:

```yaml
dependencies:
  mobile_scanner: ^7.0.1  # Обязательная зависимость
  qr_overlay:
    git:
      url: https://gitlab.mdigital.kg/mobile-global/qr_overlay.git
      ref: v1.0.1  # Укажите актуальную версию