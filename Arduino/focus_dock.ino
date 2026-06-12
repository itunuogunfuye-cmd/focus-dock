#include <Adafruit_NeoPixel.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// ---------------- BLUETOOTH & DFPLAYER ----------------
SoftwareSerial bluetooth(4, 5);   // RX=4 (HC-05 TX), TX=5 (HC-05 RX)
SoftwareSerial dfSerial(10, 11);  // RX, TX for DFPlayer
DFRobotDFPlayerMini player;

// ---------------- LED ----------------
#define LED_PIN 6
#define LED_COUNT 48
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

// ---------------- PINS ----------------
int fsrPin = A0;
int potPin = A1;
int buttonPin = 2;
int buzzerPin = 8;

// ---------------- SETTINGS ----------------
int threshold = 300;

// ---------------- STATES ----------------
bool systemOn = false;
bool focusMode = false;
bool lastButtonState = HIGH;
bool readyForNewSession = true;
bool focusFinished = false;

// ---------------- TIMING ----------------
unsigned long focusStartTime = 0;
unsigned long focusDuration = 10000;

void setup() {
  Serial.begin(9600);
  bluetooth.begin(9600);
  dfSerial.begin(9600);

  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(buzzerPin, OUTPUT);

  strip.begin();
  strip.show();

  delay(2000);
  if (!player.begin(dfSerial)) {
    Serial.println("DFPlayer NOT FOUND");
  } else {
    player.volume(25);
  }

  Serial.println("=== TUNU Dock Ready ===");
}

void loop() {
  // -------- SYSTEM BUTTON LOGIC --------
  bool buttonState = digitalRead(buttonPin);
  if (buttonState == LOW && lastButtonState == HIGH) {
    systemOn = !systemOn;
    if (systemOn) {
      beepShort();
      bluetooth.println("SYSTEM_ON");
    } else {
      beepLong();
      focusMode = false;
      focusFinished = false;
      strip.clear();
      strip.show();
      bluetooth.println("SYSTEM_OFF");
    }
    delay(200);
  }
  lastButtonState = buttonState;

  if (!systemOn) return;

  // -------- SENSOR & POTENTIOMETER --------
  int fsrValue = analogRead(fsrPin);
  bool phonePresent = fsrValue > threshold;

  int potValue = analogRead(potPin);

int seconds = ((potValue / 170) + 1) * 10;

if (seconds > 60) seconds = 60;

static int lastSentSeconds = 0;

if (!focusMode && seconds != lastSentSeconds) {
  bluetooth.print("TIME:");
  bluetooth.println(seconds);
  lastSentSeconds = seconds;
}

unsigned long previewDuration = (unsigned long)seconds * 1000;

  // -------- FOCUS LOGIC --------
  if (phonePresent) {

    // 1. START SESSION
    if (!focusMode && readyForNewSession && !focusFinished) {
      focusMode = true;
      readyForNewSession = false;
      focusFinished = false;
      beepShort();
      player.play(3);  // Start Voice
      bluetooth.print("TIME:");
      bluetooth.println(seconds);
      bluetooth.println("START");
      focusStartTime = millis();
      focusDuration = previewDuration;
    }

    // 2. RUNNING SESSION
    if (focusMode && !focusFinished) {
      unsigned long elapsed = millis() - focusStartTime;
      float progress = (float)elapsed / focusDuration;
      progress = constrain(progress, 0, 1);

      // Progress Colors (Red to Green)
      setColor(255 * (1 - progress), 255 * progress, 0);

      // 3. COMPLETE SESSION
      if (elapsed >= focusDuration) {
        bluetooth.println("COMPLETE");
        for (int i = 0; i < 3; i++) {
          tone(buzzerPin, 1000, 200);
          delay(300);
        }
        player.play(1);  // Finish Voice

        focusMode = false;
        focusFinished = true;  // Lock the session
        readyForNewSession = false;
      }
    }

    // Stay green when finished until phone is removed
    if (focusFinished) {
      setColor(0, 255, 0);
    }

  } else {
    // 4. PHONE REMOVED
    readyForNewSession = true;
    focusFinished = false;

    if (focusMode) {
      bluetooth.println("AWAY");
      beepLong();
      player.play(2);  // Warning Voice
      focusMode = false;
    }
    blinkIdle();
  }

  delay(300);
}

// ---------------- UI FUNCTIONS ----------------

void setColor(int r, int g, int b) {
  for (int i = 0; i < LED_COUNT; i++) strip.setPixelColor(i, strip.Color(r, g, b));
  strip.show();
}

void blinkIdle() {
  static unsigned long lastTime = 0;
  static bool on = false;
  if (millis() - lastTime > 500) {
    lastTime = millis();
    on = !on;
    on ? setColor(80, 80, 80) : strip.clear();
    strip.show();
  }
}

void beepShort() {
  tone(buzzerPin, 1000, 100);
}
void beepLong() {
  tone(buzzerPin, 600, 300);
}
