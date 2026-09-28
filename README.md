# Kuromi rice

Kuromi rice для Omarchy: тема, cava, fastfetch, now-playing, power menu и раскладка `SUPER + SHIFT + K`.

## Установка на новый ПК

```bash
git clone https://github.com/rual1sher/kurumi-rice.git ~/Projects/kuromi-rice
~/Projects/kuromi-rice/install.sh
```

## Обновление

```bash
kuromi-update
```

Файлы в `~/.config` и `~/.local/bin` — это симлинки на этот репо, так что правки сразу попадают сюда:

```bash
cd ~/Projects/kuromi-rice && git commit -am "..." && git push
```

## Клавиши

| Клавиши | Что делает |
|---|---|
| `SUPER + SHIFT + K` | cava, часы, живой fastfetch и плеер на пустом воркспейсе |
| `SUPER + ESCAPE` | Kuromi power menu |
| `SUPER + SHIFT + ESCAPE` | системное меню Omarchy |
