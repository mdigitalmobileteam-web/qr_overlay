#!/bin/bash

# Получаем версию из pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)

# Проверяем формат версии
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version format: $VERSION"
  exit 1
fi

# Создаем тег
TAG="v$VERSION"

# Проверяем существование тега
if git rev-parse $TAG >/dev/null 2>&1; then
  echo "Tag $TAG already exists!"
  exit 1
fi

# Создаем аннотированный тег
git tag -a $TAG -m "Release $TAG"

# Пушим тег в удаленный репозиторий
git push origin $TAG

echo "Created and pushed tag: $TAG"

# Проверить удалённые теги
# git ls-remote --tags origin
#
# # Перейдите в директорию проекта
#cd ~/StudioProjects/qr_scanner
#
## Создайте новый тег (если нужно)
#git tag -f v1.0.2 -m "Updated release"
#
# # Принудительная отправка тега
#git push -f origin v1.0.2