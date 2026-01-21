# MQTT Wrapper for Sleep-As-Android

This is a small wrapper implementation specifically for attaching Toit projects
to events that can be raised by the excellent [Sleep As Android](https://sleep.urbandroid.org/) application, by [Urbandroid](https://team.urbandroid.org/).

This library can be used in Toit projects to do such things as turn lights on,
however, that has been done before.  With all of Toit's capabilities ad your
projects' disposal, catching events from Sleep-As-Android could lead to both
sensible, and crazy ideas.

This library uses Toit's excellent [MQTT library](https://github.com/toitware/mqtt).

## Benefits
Using the capabilities of Toit on a microcontroller like the ESP32 gives an
incredible amount of flexibility and power:
- PWM/digital control of things like fans, lights, actuators, relays, motors.
- Precise timers for things like alarm windows and fade-up sequences
- Sensor reads (light/CO₂/temp, etc) can be made through the night, or attached
  to specific events.
- Specific capabilities of Sleep-as-Android can be used, for example:
  - play a noise when `SOUND-EVENT-SNORE` is activated.
  - record when `SOUND-EVENT-TALK` is activated.
  - lights or sound could be attached to the `LULLABY-*` events.
- The MCU run autonomously without the phone once state is known.
- Custom logic can be created, especially when integrating with other sensors.
- Using other capabilities (such as pulling weather information from the
  internet), heating and other environmental things can be controlled.

## Some Ideas

### Smart Sunrise
Instead of a fixed sunrise lamp, Sleep-As-Androids's smart-wake behavior
can be used to control a lamp that is synced to the users' actual wake phase.
For example:
- During wake window, gradually brighten room.
- If the alarm triggers earlier use a fast ramp-up to help the transition.
- Rules such as increasing brightness regardless of snoozing the alarm.

Toit can run a smooth PWM fade curve easily and do proper timing without
blocking other tasks.  (This was the original purpose of this code.)

### Assistance for disabled people
Using whatever interventions are necessary to suit the user.  For example:
- Controlling of lights.
- Vibration, etc.

... anything necessary to make an alarm functionally useful for a person.

### More detailed data logging
Combining other real world items, such as printers, etc, data collected by the
phone's sensors, and by sensors on Toit/ESP32, quite in-depth analyses could be
made, with data logged online or on a local printing device (eg like a Lie
Detector!)


### Morning Coffee
Coffee machine triggered by an alarm, but intelligently:
- Toit on the ESP32 listens for `alarm_dismissed` event.
- Starts a smart plug (or controls a relay in the coffee machine itself - may
  require expertise).
- Applies rules such as staying out of bed for > X minutes (eg no 'back to
  sleep' event).
- Combined with a human presence sensor, it could avoid starting the coffee
  machine if the user is not present.

### Gamifying Waking Up
Sleep as Android publishes events like: `alarm_fired`, `snooze`, `dismissed`,
`sleep_tracking_started`, `sleep_tracking_stopped`, etc. Toit on the ESP32
listens and controls real hardware:
- Smart relays controlling lamps, fans, internet radios, or other things.
- Addressable LEDs (WS2812).
- Speaker/buzzer for noise.
- Servos/solenoids (locks a drawer/box).
- Vibration motor under pillow
The fun would start by coding some escalation logic:
- Alarm fired: lights slowly ramp up + gentle sound.
- First snooze: lights go full daylight + "mission mode".
- Second snooze: servo locks a box holding the phone
- Dismissed: unlocks things + plays "victory" animation.
- Presence Sensors: Perhaps the alarm continues to get worse until the user is
  far enough away from the bed.

### Lucid-dream cue generator
Use events such as REM detection to start lights or subtle cues that may
influence dreams.
- `REM` event is triggered on the ESP32/Toit by MQTT.
- Toit code on the ESP32 could pulse LEDs softly.
- Or, control an ultrasonic transducer.
- Or, operatte vibration motors, etc.

### The Incredible Machine
Who remembers [this game](https://en.wikipedia.org/wiki/The_Incredible_Machine)?  The possibilities are almost as endless. :)

## How to Use
The main concept is that the user is required to write some toit code to do
something, such as turn an LED on using a GPIO, in its simplest example.
Registering that code in this library, to one of the event types from Sleep As
Android, will trigger that code when the event is raised.  (This is sometimes
referred to as a 'callback'.)

### Possible events
Urbandroid list their events on their
[website](https://sleep.urbandroid.org/docs/services/automation.html#events). In
this driver, the names are exposed as constants, and can be used when setting
triggers.
#### Event List
These are mostly self explanatory.  For more details see Urbandroid's [Event List](https://sleep.urbandroid.org/docs/services/automation.html#events).

| Constant/Event Name | Explanation |
| - | - |
| `SLEEP-TRACKING-STARTED` | Fires when sleep tracking has started. |
| `SLEEP-TRACKING-STOPPED` | Fires when sleep tracking has stopped. |
| `SLEEP-TRACKING-PAUSED` | Fires when sleep tracking is paused. |
| `SLEEP-TRACKING_RESUMED` | Fires when sleep tracking has been resumed. |
| `ALARM-SNOOZE-CLICKED` |   Fires when a ringing alarm was snoozed. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time, example: "1582719660934"</li> <li>**value2:** alarm label as the user has specified it in the app, example: "label". (Any tabs and newline characters in the label are removed.) |
| `ALARM-SNOOZE-CANCELLED` | Fires when a snoozed alarm alarm is cancelled. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `TIME-TO-BED-ALARM-ALERT` | Fires when the app gives a 'bedtime' notification. <br> <ul><li>**value1:** UNIX timestamp of the _alarm start time_ triggering the sleep notification, not the time of the 'time to go to bed' alert. </li></ul> |
| `ALARM-ALERT-START` | Fires when an alarm starts. <br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `ALARM-RESCHEDULED` | Fires when the app is saving a new alarm time, different from the previous alarm time (it allows an external automation system to track the latest set alarm time on Sleep as Android). <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `ALARM-ALERT-DISMISS` | Fires when the alarm is dismissed.  (After the CAPTCHA is solved, if one is set).<br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label. |
| `ALARM-SKIP-NEXT` | Fires when an alarm is dismissed from notification before it actually rings. <br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label. |
| `BEFORE-ALARM` | Fires exactly 1 hour before the next alarm is triggered.<br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li></ul>
| `REM` | Fires when the app estimates the start of the REM phase of sleep. |
| `SMART-PERIOD` | Fires at the start of the smart period. |
| `BEFORE-SMART-PERIOD` | Fires 45 minutes before the start of smart period. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li></ul>

| `LULLABY-START` | Fires when lullaby starts playing. |
| `LULLABY-STOP` | Fires when lullaby is stopped (either manually or automatically). |
| `LULLABY-VOLUME-DOWN` | Fires when the app detects that the user fell asleep, and is starting lowering the volume of lullaby. |
| `DEEP-SLEEP` | Fires when the app detects the user is going into a deep sleep phase. <br>**Warning:** This may result in lots of events during the night and may not exactly fit the resulting sleep graph as the app can only detect phases reliably from whole-night data. |
| `LIGHT-SLEEP` |
| `AWAKE` |
| `NOT-AWAKE` |
| `APNEA-ALARM` |
| `ANTISNORING` |
| `SOUND-EVENT-SNORE` |
| `SOUND-EVENT-TALK` |
| `SOUND-EVENT-COUGHING` |
| `SOUND-EVENT-BABY` |
| `SOUND-EVENT-LAUGH` |
| `ALARM-WAKE-UP-CHECK` |
| `ALARM-RESCHEDULED-2` |
| `JET-LAG-START` |
| `JET-LAG-STOP` |

Some of these provide other data alongside the event name, as 'value1' and
'value2' in the map.  This information is available to lambdas in the following
way:
```Toit
import sleep-as-android show *

main:
  username := "username"
  password := "password"

  sleep-as-android := Sleep-as-android
      --mqtt-host="host.mqtt.example"
      --mqtt-username=username
      --mqtt-password=password
      --mqtt-topic="clock/alarms"

  sleep-as-android.assign-event
      --event=Sleep-as-android.ALARM-ALERT-START
      :: | event-data/Map |
        print "  ALARM! $event-data"
```
When the alarm triggers, will display, as an example:
```
[sleep-as] INFO: starting mqtt client... {client-id: 9c:9e:6e:ff:fe:77, username: username}
[sleep-as.mqtt] DEBUG: connected to broker
[sleep-as.mqtt] DEBUG: connection established
[sleep-as] DEBUG: lambda assigned: {event: alarm_alert_start}
[sleep-as] DEBUG: received json from 'clock/alarms': {value1: 1768698540000, value2: Ring Paul, event: alarm_alert_start}
  Alarm! {value1: 1768698540000, value2: Ring Paul, event: alarm_alert_start}
```
As explained in the Urbandroid documentation, `value1` in this case is a `UNIXTIME`
of the alarm set time.  (This one refers to the alarm, and therefore stays the
same even when snoozed.)  Output and dDebug levels can be changed, see Toit's
[`logger` class](https://libs.toit.io/log/class-Logger).

## Issues
If there are any issues, changes, or any other kind of feedback, please
[raise an issue](./issues). Feedback is welcome and appreciated!

## Disclaimer
- All trademarks belong to their respective owners.
- No warranties for this work, express or implied.

## Credits
- AI has been used for code reviews, analysing & compiling data/results, etc.
- The Toit team (past and present) for a truly excellent product

## About Toit
One would assume you are here because you know what Toit is.  If you dont:
> Toit is a high-level, memory-safe language, with container/VM technology built
> specifically for microcontrollers (not a desktop language port). It gives fast
> iteration (live reloads over Wi-Fi in seconds), robust serviceability, and
> performance that’s far closer to C than typical scripting options on the
> ESP32. [[link](https://toitlang.org/)]
- [Review on Soracom](https://soracom.io/blog/internet-of-microcontrollers-made-easy-with-toit-x-soracom/)
- [Review on eeJournal](https://www.eejournal.com/article/its-time-to-get-toit)
