# FutureClock Test Suite — Overview

**36 tests · ~600 assertions · 8,289 LOC · 31/45 modules covered (69%)**

```
$ python3 test.py /home/claude/esp

✓ ALL 36 TESTS PASSED
```

---

## Test Map

### Console (4 tests · 168 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `console/console` | 16 | `sys ping`, `ui render`, `app push` arg parsing, unknown commands, empty input |
| `console/console_args` | 134 | `isIntStr`, `isFloat`, `isColor`, `parseArgs` quote-aware tokenizer, edge cases |
| `console/console_fs` | 9 | `app pull` (single + `*`), `app delete`, missing app errors — **uses VFS** |
| `console/serial_console` | 9 | Serial transport: echo, prompt, line parsing |

### Core (4 tests · 81 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `core/app_manager` | 22 | `scanApps` from VFS, `extractMeta` (title/icon/category), `launch`, `systemConfig`, `queueLaunch`, `refreshApps`, edge cases — **uses VFS** |
| `core/call_queue` | 13 | push/process, deduplication, overflow (max 16), size tracking |
| `core/state_store` | 33 | define/get/set all types (string/int/bool/float), `has`/`count`, `getAsString`, `setFromString`, `reset`/`clear`, `onChange` callback |
| `core/yaml_config` | 13 | define + defaults, load from VFS, save to VFS, roundtrip, auto-save on `set()`, comments, partial load — **uses VFS** |

### E2E (4 tests · ~115 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `e2e/bf` | ~5 | Brainfuck engine: Hello World execution |
| `e2e/calc_console` | 68 | Full calculator app via console commands: digit entry, operations, chaining, clear, display |
| `e2e/crossword` | 35 | Crossword app via `ui call`/`ui click`: cell selection, letter input, navigation, victory detection |
| `e2e/ui_calculator` | ~12 | Calculator app via direct LVGL button clicks |

### Lua (5 tests · 61 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `lua/lua_fetch` | 8 | `fetch()` / `ble_connected()` registration, BLE-down error path, callback with status=0 |
| `lua/lua_preprocess` | 9 | Lua preprocessor: comment stripping, string preservation |
| `lua/lua_system` | 15 | `app_launch`/`app_home` callbacks, canvas table functions, `freezeUI`/`unfreezeUI` |
| `lua/lua_ui` | 8 | `focus()`/`getAttr()`/`navigate()` registration, `setAttr` visible/nonexistent widget |
| `lua/timers` | 21 | Timer create/fire/cancel, intervals, `setInterval`/`clearInterval`, multiple timers |

### Parser (2 tests)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `parser/html_parser` | ~15 | Tag parsing, attributes, nesting, self-closing tags |
| `parser/html_to_kdl` | ~10 | HTML → KDL intermediate format conversion |

### UI (9 tests · ~140 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `ui/align` | 13 | `align="center center"`, `valign`, `text-align`, `text-valign`, coordinate priority |
| `ui/canvas` | 20 | Canvas creation, `clear`/`rect`/`pixel`/`circle`/`line`, bounds clamping, error handling |
| `ui/css` | 31 | Tag/class/id selectors, cascade priority, `tag.class`, property parsing, `applyCss()` on all widget types |
| `ui/groups` | 9 | Page groups, orientation, default page, indicator, swipe navigation |
| `ui/navigation` | 10 | `href`, `navigate()`, page switching, `default` page |
| `ui/qi_align` | 10 | Quick-integration alignment tests with real render |
| `ui/ui_ids` | ~8 | Auto-generated IDs, explicit IDs, uniqueness |
| `ui/ui_render` | ~3 | Basic render pipeline: HTML → screen |
| `ui/ui_styles` | ~10 | `<style>` block, class application, property inheritance |

### Utils (5 tests · 117 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `utils/log_config` | 18 | Default levels, set/get per category, `setAll`, level ordering, `catName`/`levelName`, `command()` parsing |
| `utils/name_gen` | 23 | ASCII sanitize, Cyrillic→Latin, diacritics stripping, edge cases (empty, all symbols), `generate()` |
| `utils/string_utils` | 39 | `trim`/`trimmed`, `toLower`, `contains`, `toBool`, `equals`/`equalsIgnoreCase`, `decodeEntities` (HTML entities, decimal, hex) |
| `utils/task_queue` | 14 | Keyed deduplication, unkeyed ordering, clear, `UpdateLabelTask`/`UpdateBindingTask`, `UI::updateLabel`/`updateBinding` |
| `utils/vfs` | 23 | VFS read/write, sequential reads, `available()`, File write+close, exists, dirs, `openNextFile`, `name()`/`path()`, remove, `usedBytes`, reset |

### Widgets (3 tests · 27 assertions)

| Test | Assertions | What's tested |
|------|-----------|---------------|
| `widgets/binding` | 11 | Text binding `{var}`, template `"Text: {var}"`, two-way bind on slider/switch/input |
| `widgets/input` | 10 | Input creation, placeholder, `bind`, `onenter`, `onblur`, password mode |
| `widgets/visibility` | 6 | `visible="{var}"`, dynamic show/hide via state |

---

## Module Coverage

### Covered (31/45 = 69%)

```
✓ core/app_manager        ✓ core/call_queue         ✓ core/state_store
✓ core/script_engine       ✓ core/script_manager      ✓ core/yaml_config
✓ console/console          ✓ bf/bf_engine
✓ lua/lua_engine           ✓ lua/lua_fetch            ✓ lua/lua_system
✓ lua/lua_timer            ✓ lua/lua_ui
✓ ui/css_parser            ✓ ui/html_parser           ✓ ui/ui_canvas
✓ ui/ui_engine             ✓ ui/ui_html               ✓ ui/ui_page_group
✓ ui/ui_widget_builder     ✓ ui/ui_task               ✓ ui/ui_types
✓ ui/xml_utils
✓ utils/font               ✓ utils/log_config         ✓ utils/name_gen
✓ utils/string_utils       ✓ utils/task_queue
✓ widgets/widget_common
```

### Uncovered — Hardware-Dependent (14/45)

```
✗ ble/ble_bridge          BLE GATT server, characteristic I/O
✗ ble/bin_receive         Binary file receive over BLE
✗ ble/bin_transfer        Binary chunked transfer over BLE
✗ hal/display_hal         Display init, buffer management, SPI
✗ hal/device              Board-specific hardware abstraction
✗ hal/boards/*            ESP4848, ESP8048, T-Watch2020 drivers
✗ ui/ui_launcher          Launcher grid, icon rendering, swipe
✗ ui/ui_shade             Notification shade, brightness control
✗ ui/ui_touch             Touch input processing, gestures
✗ utils/screenshot        Framebuffer capture to PNG
✗ core/base_script_engine Abstract script engine interface
✗ core/native_app         Native C++ app registry
✗ utils/esp_log           ESP-IDF log wrapper
✗ main.cpp                Entry point, FreeRTOS task setup
```

---

## Test Infrastructure

### Stubs (1,924 LOC)

| Stub | Purpose |
|------|---------|
| `lvgl.h` + `lvgl_mock.h` | Full LVGL mock: 600+ API functions, object tree, styles, events |
| `LittleFS.h` | **VFS** — in-memory filesystem: File read/write/dir, LittleFSClass |
| `freertos/FreeRTOS.h` | Mutex/semaphore stubs (non-null handles) |
| `Arduino.h` | `Serial`, `millis()`, `String` |
| `esp_heap_caps.h` | `heap_caps_malloc` → `malloc` |
| `ArduinoJson.h` | Passthrough to real ArduinoJson |
| `board_config.h` | Screen dimensions, pin definitions |

### Build System

| File | LOC | Purpose |
|------|-----|---------|
| `build.py` | 184 | Compiles ESP32 source with stubs, `-MMD` dep tracking |
| `test.py` | 230 | Discovers tests, links with objects, runs, checks exit codes |
| `externals.cpp` | 47 | Global stubs (`LittleFS`, `Serial`, `WidgetCallbacks`) |

### Key Design Decisions

- **No test framework** — plain C++ with `TEST()` macro, `printf` output, exit code
- **Real code under test** — compiled from `esp/src/` with mock HAL, not reimplemented
- **VFS for filesystem** — in-memory drop-in for LittleFS, enables testing app_manager, yaml_config, console FS commands
- **LVGL mock** — allocates real objects with parent-child tree, tracks styles/flags/events, but no actual rendering
- **Dep tracking** — `-MMD` flags ensure header changes trigger recompilation

---

## File Tree

```
compiler/tests/
├── console/
│   ├── test_console.cpp          149 LOC
│   ├── test_console_args.cpp     760 LOC
│   ├── test_console_fs.cpp       147 LOC
│   └── test_serial_console.cpp   174 LOC
├── core/
│   ├── test_app_manager.cpp      296 LOC
│   ├── test_call_queue.cpp       189 LOC
│   ├── test_state_store.cpp      295 LOC
│   └── test_yaml_config.cpp      227 LOC
├── e2e/
│   ├── test_bf.cpp                75 LOC
│   ├── test_calc_console.cpp     906 LOC
│   ├── test_crossword.cpp        761 LOC
│   └── test_ui_calculator.cpp    195 LOC
├── lua/
│   ├── test_lua_fetch.cpp        108 LOC
│   ├── test_lua_preprocess.cpp   266 LOC
│   ├── test_lua_system.cpp       155 LOC
│   ├── test_lua_ui.cpp           171 LOC
│   └── test_timers.cpp           380 LOC
├── parser/
│   ├── test_html_parser.cpp       87 LOC
│   └── test_html_to_kdl.cpp      69 LOC
├── ui/
│   ├── test_align.cpp            204 LOC
│   ├── test_canvas.cpp           243 LOC
│   ├── test_css.cpp              397 LOC
│   ├── test_groups.cpp           125 LOC
│   ├── test_navigation.cpp       150 LOC
│   ├── test_qi_align.cpp         136 LOC
│   ├── test_ui_ids.cpp            62 LOC
│   ├── test_ui_render.cpp         50 LOC
│   └── test_ui_styles.cpp        98 LOC
├── utils/
│   ├── test_log_config.cpp       168 LOC
│   ├── test_name_gen.cpp         164 LOC
│   ├── test_string_utils.cpp     215 LOC
│   ├── test_task_queue.cpp       190 LOC
│   └── test_vfs.cpp              256 LOC
├── widgets/
│   ├── test_binding.cpp          168 LOC
│   ├── test_input.cpp            142 LOC
│   └── test_visibility.cpp       111 LOC
└── externals.cpp                  47 LOC
```
