#!/bin/bash

## ./release.sh patch

# Определяем тип релиза (патч, минор, мажор)
RELEASE_TYPE=$1

# Берем текущую версию
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)

# Разбиваем на компоненты
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Обновляем версию
case $RELEASE_TYPE in
  "major")
    NEW_VERSION="$((MAJOR + 1)).0.0"
    ;;
  "minor")
    NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
    ;;
  *)
    NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
    ;;
esac

# Обновляем pubspec.yaml
sed -i '' "s/version: $CURRENT_VERSION[0-9+]*/version: $NEW_VERSION/" pubspec.yaml

# Коммитим изменения
git add pubspec.yaml
git commit -m "Bump version to $NEW_VERSION"

# Создаем тег
./create_tag.sh

echo "Released $NEW_VERSION"