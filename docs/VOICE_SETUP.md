# Voice task creation: setup and behaviour

## Pipeline

```
microphone ─▶ SpeechToTextEngine ─▶ transcript ─▶ TaskTextParser ─▶ ParsedTask
   (platform recognizer)                         (English rules)        │
                                                                       ▼
                                   task editor (prefilled, sentence shown) ─▶ Save ─▶ task
```

Nothing is created until the person taps **Save** in the editor. Both
providers sit behind interfaces (`features/voice/domain/services`), so a cloud
recognizer or an NLP/LLM parser (`POST voice/parse`, contract §3.4) replaces
one registration in `voice_dependencies.dart`.

## Native setup (after `flutter create .`)

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>The microphone is used when you add a task by voice.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Speech recognition turns what you say into a task. Apple may process the audio to recognize it.</string>
```

Minimum iOS version: as required by `speech_to_text` (see its README).

**Android** — `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<queries>
  <intent>
    <action android:name="android.speech.RecognitionService"/>
  </intent>
</queries>
```

The `<queries>` entry is needed on Android 11+ to find the system recognizer.
Devices without one (some de-Googled phones) show "Speech recognition isn't
available"; typing still works.

## Privacy

The app receives text only. On iOS, Apple's recognizer may send audio to Apple
unless the device supports on-device recognition; on Android the system
recognition service (usually Google) handles the audio. The privacy policy
(Phase 13) must say so. No audio or transcript is stored by the app, except the
sentence shown in the editor until the task is saved or discarded.

## English rules (the on-device parser)

| Said | Understood as |
| --- | --- |
| "tomorrow", "today", "tonight", "the day after tomorrow", "next week", "in 3 days" | date (tonight also means 21:00 unless a time is said) |
| "Friday", "on Friday", "this Friday" | the next Friday, today included |
| "next Friday" | the Friday of next week |
| "October 20", "20th of October", "on the 15th" | the next such date |
| "at 7", "at 7:30 pm", "7pm", "half past 7", "quarter to 8", "noon" | time; a bare hour 1–6 is afternoon, 7–11 morning |
| "in the morning/afternoon/evening", "at night", "tomorrow evening" | picks am/pm, or 09:00 / 15:00 / 19:00 / 21:00 when no time is said |
| "in 20 minutes", "in an hour" | a time from now |
| "for 30 minutes", "for an hour and a half", "for 2 hours 15 minutes", "a 30-minute walk" | expected duration (1 min – 24 h) |
| "every day", "every 2 days", "every weekday", "on weekends", "every Monday and Wednesday", "every other week", "monthly", "on the 1st of every month" | repetition |
| "sometime", "any time" | any time that day |
| "for work", "in Study", "#home" (a category name) | that category |
| keywords such as run, gym, meeting, homework, groceries, birthday | a suggested default category (Health, Work, Study, Home, Personal) |
| "remind me to", "I need to", "add a task to" | dropped |

A time already gone today, with no date or repetition said, moves to tomorrow.
Whatever is not understood stays in the title, so nothing said is lost.
