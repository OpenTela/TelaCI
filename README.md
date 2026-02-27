# EOS Compiler & Test Framework v2.3

Инструменты для компиляции и тестирования проектов Evolution OS на хосте (без ESP32).

## Changelog

- **v2.3**: Исходники ckdl вложены в репо, Lua-стабы убраны (всегда реальная Lua 5.4), единый пайплайн тестов, тест декларативных таймеров
- **v2.2**: Тесты с реальным Lua VM, forward declaration preprocessor
- **v2.1**: CSS парсер, группы страниц, KDL-тесты
- **v2.0**: Mock LVGL, build.py/test.py, первые UI-тесты
- **v1.0**: Начальная версия

---

## Структура

```
compiler/
├── build.py              # Компиляция проекта (mock .o файлы)
├── test.py               # Запуск тестов
├── README.md             # Этот файл
│
├── stubs/                # Заглушки для ESP32/LVGL/Arduino
│   ├── lvgl.h            # LVGL API
│   ├── lvgl_mock.h       # Mock-виджеты для тестов
│   ├── Arduino.h         # Arduino framework
│   ├── ArduinoJson.h     # JSON (частичная реализация, см. TODO)
│   ├── NimBLEDevice.h    # BLE
│   ├── LittleFS.h        # Файловая система
│   ├── esp_log.h         # ESP32 логирование
│   └── ...               # и другие
│
├── lib/                  # Внешние библиотеки
│   ├── build_libs.sh     # Скрипт сборки
│   ├── ckdl/             # KDL парсер v1.0 (исходники + сборка)
│   │   ├── src/          # 7 .c файлов
│   │   ├── include/kdl/  # Публичные заголовки
│   │   ├── bindings/cpp/ # C++ биндинг (kdlpp, C++20)
│   │   └── build/        # libkdl.a
│   └── lua54/            # Lua 5.4.7
│       ├── include/      # lua.h, lauxlib.h, lualib.h
│       └── build/        # liblua54.a
│
├── tests/                # Тесты
│   ├── test_*.cpp        # 19 тестов
│   ├── externals.cpp     # Общие external definitions
│   └── bin/              # Скомпилированные бинарники (gitignore)
│
└── build/
    └── mock/             # Объектные файлы (gitignore)
```

---

## Быстрый старт

```bash
# 1. Собрать библиотеки (один раз)
./lib/build_libs.sh

# 2. Скомпилировать проект
python3 build.py /path/to/eos --mock

# 3. Запустить все тесты
python3 test.py /path/to/eos

# 4. Запустить конкретный тест
python3 test.py /path/to/eos timers
```

---

## build.py — Компиляция

Компилирует все `.cpp` из `src/` проекта в объектные файлы с mock-окружением.

```bash
python3 build.py <project_path> --mock [--rebuild]
```

| Аргумент | Описание |
|----------|----------|
| `project_path` | Путь к проекту с `src/` |
| `--mock` | Mock-режим (`-DLVGL_MOCK_ENABLED`) |
| `--rebuild` | Пересобрать всё |

Порядок include: `lib/lua54/include` → `stubs/` → `src/` → `lib/ckdl/include`

Инкрементальная сборка: перекомпилируются только изменённые файлы.

---

## test.py — Запуск тестов

```bash
python3 test.py <project_path> [options] [test_names...]
```

| Опция | Описание |
|-------|----------|
| (без аргументов) | Запуск всех 19 тестов |
| `align` | Тесты содержащие "align" в имени |
| `-e align` | Точно `test_align` |
| `-l, --list` | Список доступных тестов |
| `-c, --clean` | Очистить bin/ перед запуском |

Каждый тест компилируется из `test_<name>.cpp` + `externals.cpp` + все `.o` из `build/mock/` + `libkdl.a` + `liblua54.a`.

---

## Тесты

19 тестов, ~170 проверок суммарно.

### UI движок

| Тест | Проверок | Что тестирует |
|------|----------|---------------|
| `align` | 13 | Позиционирование виджетов: `align="center"`, `valign`, комбинации `x/y` + `align`, приоритет координат над `align` |
| `binding` | 11 | Привязка state ↔ UI: текстовый биндинг `{var}`, шаблоны `"Text: {var}"`, `bgcolor="{var}"`, `color="{var}"`, `visible="{var}"`, динамическое обновление |
| `css` | 14 | CSS парсер: селекторы по тегу/классу, приоритеты, `bgcolor`, `color`, `radius`, `font`, каскадирование |
| `groups` | 9 | Группы страниц (свайп): горизонтальная/вертикальная ориентация, индикаторы `dots`/`scrollbar`/`none`, `default` страница, вложенность |
| `html_parser` | 4 | HTML парсер: кнопки, лейблы, подсчёт виджетов, корректность структуры |
| `navigation` | 10 | Навигация: `href="/page"`, `navigate()` из Lua, standalone страницы, переход между группами, `default` страница |
| `visibility` | 6 | Условная видимость: `visible="{var}"`, значения `"true"`/`"false"`/`"1"`, динамическое переключение |
| `widgets` | 10 | Базовые виджеты: `label`, `button`, `slider`, `switch`, `input`, `canvas`, `image` — создание, атрибуты, биндинг |
| `ui_ids` | 7 | ID виджетов: уникальность, `ui_get()` по id, вложенные элементы |
| `ui_render` | 1 | Рендеринг: парсинг HTML → LVGL-объекты, базовая проверка результата |
| `ui_styles` | 9 | Применение CSS стилей к виджетам: классы, наследование, переопределение |
| `ui_calculator` | 11 | Интеграционный тест: полный UI калькулятора — кнопки, дисплей, layout |

### KDL

| Тест | Проверок | Что тестирует |
|------|----------|---------------|
| `html_to_kdl` | 11 | Конвертация LVGL mock-дерева в KDL-документ: структура, атрибуты, вложенность |
| `qi_align` | 10 | Выравнивание через KDL pipeline: HTML → LVGL → KDL → UIQuery, проверка координат |

### Lua VM (реальный интерпретатор)

| Тест | Проверок | Что тестирует |
|------|----------|---------------|
| `lua_preprocess` | 9 | Forward declarations: `local function` определённая ниже вызова, взаимные вызовы, рекурсия, параметры, mixed local/global |
| `timers` | 21 | Декларативные таймеры: парсинг `<timer>` из HTML, счётчик `tick()` → `string.format`, множественные таймеры с разными интервалами, toggle-blink, циклический data source |

### Console

| Тест | Проверок | Что тестирует |
|------|----------|---------------|
| `console` | 16 | Console API: `sys ping`, подсистемы, `app push` — оба порядка аргументов, валидация расширения файла, dotfiles, ошибки (нет размера, нет расширения, пустая команда) |
| `serial_console` | 9 | Serial-протокол: побайтовый ввод, парсинг команд из потока, `ui get/set`, буферизация |

### Прочее

| Тест | Проверок | Что тестирует |
|------|----------|---------------|
| `bf` | 3 | Brainfuck-интерпретатор: Hello World, арифметика, граничные условия |

---

## Библиотеки (lib/)

### build_libs.sh

```bash
./lib/build_libs.sh          # собрать всё
./lib/build_libs.sh ckdl     # только ckdl (из локальных исходников)
./lib/build_libs.sh lua      # только Lua (скачивает с lua.org)
./lib/build_libs.sh clean    # удалить .a файлы
```

### ckdl v1.0

KDL-парсер. Исходники зафиксированы в `lib/ckdl/src/` (7 файлов .c), сборка локальная без скачивания.

C++ биндинг (`kdlpp.h/cpp`) требует C++20 — компилируется автоматически если компилятор поддерживает.

### Lua 5.4.7

Скачивается с lua.org при первом запуске `build_libs.sh`. Заголовки: `lib/lua54/include/`, библиотека: `lib/lua54/build/liblua54.a`.

Lua-стабов нет — всегда используется реальный интерпретатор. `liblua54.a` обязательна для `build.py` и `test.py`.

---

## Стабы (stubs/)

Заглушки для компиляции ESP32-кода на хосте.

| Стаб | Что эмулирует | Полнота |
|------|---------------|---------|
| `lvgl.h` | LVGL 9 API (виджеты, стили, объекты) | Структуры + основные функции |
| `lvgl_mock.h` | Mock-дерево виджетов для тестов | Полная: MockWidget с захватом всех свойств |
| `Arduino.h` | Arduino framework (Serial, millis, String) | Минимальная |
| `ArduinoJson.h` | JSON парсинг/сериализация | **Частичная** (см. TODO) |
| `NimBLEDevice.h` | BLE стек | Только компиляция |
| `LittleFS.h` | Файловая система | Только компиляция |
| `esp_log.h` | ESP_LOGI/W/E макросы | printf-обёртка |
| `esp_heap_caps.h` | heap_caps_malloc | malloc-обёртка |
| `TFT_eSPI.h` | Дисплей | Только компиляция |
| `lz4.h` | LZ4 сжатие | Только компиляция |
| `ui_layout.h` / `ui_query.h` | UI query helpers | Рабочие |

---

## Написание тестов

### Шаблон

```cpp
#include <cstdio>
#include "lvgl.h"
#include "lvgl_mock.h"
#include "ui/ui_engine.h"
#include "core/state_store.h"

#define TEST(name) printf("  %-50s ", name); total++;
#define PASS() do { printf("✓\n"); passed++; } while(0)
#define FAIL(msg) do { printf("✗ %s\n", msg); } while(0)

int main() {
    printf("=== My Tests ===\n\n");
    int passed = 0, total = 0;

    LvglMock::create_screen(480, 480);
    State::store().clear();
    UI::Engine::instance().init();
    UI::Engine::instance().render(MY_HTML);

    TEST("something works") {
        if (/* check */) PASS();
        else FAIL("nope");
    }

    printf("\n");
    if (passed == total) {
        printf("=== ALL %d TESTS PASSED ===\n", total);
        return 0;
    } else {
        printf("=== %d/%d FAILED ===\n", total - passed, total);
        return 1;
    }
}
```

### С Lua VM

```cpp
#include "lua/lua_engine.h"
#include "core/state_store.h"

LuaEngine engine;
engine.init();
engine.execute("function foo() state.x = 'bar' end");
engine.call("foo");
assert(State::store().getString("x") == "bar");
engine.shutdown();
```

### Маркеры результата

Тест считается **пройденным** если в stdout есть `PASSED`/`PASS`/`Complete` и нет `FAILED`/`FAIL`.

---

## Troubleshooting

**`liblua54.a not found`** — запустите `./lib/build_libs.sh`

**`build/mock/ not found`** — запустите `python3 build.py <path> --mock`

**`undefined reference`** — добавьте стаб в `stubs/` или определение в `tests/externals.cpp`

**Тест упал после изменения кода** — пересоберите: `build.py --mock` → `test.py -c`

**`qi_align` не компилируется** — нужен g++ с поддержкой C++20 для `kdlpp`

---

## TODO

- [ ] **ArduinoJson стаб**: `deserializeJson()` всегда возвращает `Ok` но документ пустой. `JsonArray` работает (хранит строки), поэтому консольные тесты проходят. Но тесты BLE-протокола или HTTP-ответов потребуют настоящий парсер — подключить реальный ArduinoJson или `nlohmann/json` для тестовой среды
- [ ] Тесты `setAttr()`/`getAttr()`
- [ ] Тесты `focus()`, `onenter`, `onblur`
- [ ] Тесты BLE bridge протокола
- [ ] Тесты `fetch()` через mock HTTP
