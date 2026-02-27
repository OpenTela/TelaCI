/**
 * Test: App Lifecycle
 * 
 * Render app → state works → clear → render another → state isolated
 */
#include <cstdio>
#include "lvgl.h"
#include "lvgl_mock.h"
#include "ui/ui_engine.h"
#include "core/state_store.h"

static int g_passed = 0, g_total = 0;
#define TEST(name) printf("  %-50s ", name); g_total++;
#define PASS() do { printf("✓\n"); g_passed++; } while(0)
#define FAIL(msg) printf("✗ %s\n", msg)

static const char* APP_A = R"(
<app>
  <ui default="/main"><page id="main">
    <label id="lblA" x="10" y="10">{greeting}</label>
  </page></ui>
  <state>
    <string name="greeting" default="Hello A"/>
    <int name="score" default="0"/>
  </state>
</app>
)";

static const char* APP_B = R"(
<app>
  <ui default="/main"><page id="main">
    <label id="lblB" x="10" y="10">{status}</label>
  </page></ui>
  <state>
    <string name="status" default="Ready B"/>
    <int name="level" default="1"/>
  </state>
</app>
)";

int main() {
    printf("=== App Lifecycle Tests ===\n\n");

    LvglMock::create_screen(240, 240);
    auto& engine = UI::Engine::instance();

    // --- Launch App A ---
    State::store().clear();
    engine.render(APP_A);

    TEST("App A: default state greeting = 'Hello A'") {
        if (State::store().getString("greeting") == "Hello A") PASS();
        else FAIL(State::store().getString("greeting").c_str());
    }

    State::store().set("score", "42");
    TEST("App A: score set to 42") {
        if (State::store().getString("score") == "42") PASS();
        else FAIL("not set");
    }

    // --- Switch to App B (simulates showLauncher + launch) ---
    engine.clear();
    State::store().clear();
    engine.render(APP_B);

    TEST("App B: default state status = 'Ready B'") {
        if (State::store().getString("status") == "Ready B") PASS();
        else FAIL(State::store().getString("status").c_str());
    }

    TEST("App B: App A's 'score' is gone") {
        auto v = State::store().getString("score");
        if (v.empty()) PASS();
        else FAIL(v.c_str());
    }

    TEST("App B: App A's 'greeting' is gone") {
        auto v = State::store().getString("greeting");
        if (v.empty()) PASS();
        else FAIL(v.c_str());
    }

    // --- Back to App A (fresh) ---
    engine.clear();
    State::store().clear();
    engine.render(APP_A);

    TEST("App A re-launch: greeting back to default") {
        if (State::store().getString("greeting") == "Hello A") PASS();
        else FAIL(State::store().getString("greeting").c_str());
    }

    TEST("App A re-launch: score back to default 0") {
        if (State::store().getString("score") == "0") PASS();
        else FAIL(State::store().getString("score").c_str());
    }

    // --- Verify UI elements ---
    auto* page = LvglMock::g_screen->first("Container");

    TEST("App A re-launch: lblA exists with default text") {
        auto* w = page ? page->findById("lblA") : nullptr;
        if (w && w->text == "Hello A") PASS();
        else FAIL(w ? w->text.c_str() : "not found");
    }

    TEST("App A re-launch: lblB does NOT exist") {
        auto* w = page ? page->findById("lblB") : nullptr;
        if (!w) PASS();
        else FAIL("lblB should not exist");
    }

    printf("\n");
    if (g_passed == g_total) {
        printf("=== ALL %d LIFECYCLE TESTS PASSED ===\n", g_total);
        return 0;
    } else {
        printf("=== %d/%d LIFECYCLE TESTS PASSED ===\n", g_passed, g_total);
        return 1;
    }
}
