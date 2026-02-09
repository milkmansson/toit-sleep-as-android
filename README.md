# MQTT Wrapper for Sleep-As-Android

This is a small wrapper implementation specifically for attaching Toit projects
to events that can be raised by the excellent [Sleep As Android](https://sleep.urbandroid.org/) application, by [Urbandroid](https://team.urbandroid.org/).

This library can be used in Toit projects to do such things as turn lights on,
however, this really is just the tip of the iceberg.  With all of Toit's
capabilities at your projects' disposal, catching events from Sleep-As-Android
could lead to much more.

This library uses Toit's excellent [MQTT library](https://github.com/toitware/mqtt).

## Benefits
Combining the capabilities of this app with Toit presents significant
flexibility:
- PWM/digital control of things like fans, lights, actuators, relays, motors.
- Precise timers for things like alarm windows and fade-up sequences.
- Sensor reads (light/CO₂/temp, etc) can be made through the night, or attached
  to specific events.
- Specific capabilities of Sleep-as-Android can be used, for example:
  - play a noise when `SOUND-EVENT-SNORE` is activated.
  - record when `SOUND-EVENT-TALK` is activated.
  - lights or sound could be attached to the `LULLABY-*` events.
- The MCU can run autonomously without the phone, especially once state is known.
- Custom logic can be created, especially when integrating with other sensors.
- Using other capabilities (such as pulling weather information from the
  internet), heating and other environmental things can be controlled.

## Some Ideas

### Smart Wakeup
Instead of a fixed lamp for a sunrise event, Sleep-As-Androids's smart-wake
behavior can be used to control a lamp that is synced to the users' actual wake
phase.  For example:
- During wake window, gradually brighten room.
- If the alarm triggers earlier use a fast ramp-up to help the transition.
- Rules such as increasing brightness regardless of snoozing the alarm.

Toit can run smooth PWM fade curves easily and do proper timing, without
blocking other tasks.  (This was the original purpose of this code.)

### Accessibility Assistance
Create whatever interventions are necessary to suit an individuals neeeds:
- Controlling of lights: Not just a bedside light, but room lamps, LED strips,
  strobes, etc.
- Gentle mechanical motion including vibration, or a rocking pad, etc.
- Combining with other sensors, detecting when the user is present or has left,
  alongside alerts/notifications to caregivers.
- Using whatever physical responses the user is physically able to make,
  including proximity or gesture detection to dismiss alarms.

... essentially anything necessary that would make a functional combination for
a particular users' needs.

### More detailed data logging
Combining other real world items, data collected by sensors on Toit/ESP32, or the
phone's built-in sensors, quite in-depth analyses could be made.  Data could
be logged online or connected to a local printing device.  (In my imagination
that could even look like a Lie Detector.)

### Coffee Maker
Coffee machine triggered by an alarm, but intelligently:
- Toit on the ESP32 listens for `alarm_dismissed` event.
- Starts a smart plug (or controls a relay in the coffee machine itself) to
  start making coffee.
- Can apply rules such as staying out of bed for > X minutes (eg no 'back to
  sleep' event).
- Combined with a human presence sensor, it could avoid starting the coffee
  machine if the user is not present.

### Gamifying Waking Up
Sleep as Android publishes events like: `alarm_fired`, `snooze`, `dismissed`,
`sleep_tracking_started`, `sleep_tracking_stopped`, etc. Toit on the ESP32
listens and controls other physical hardware, as above:
- Smart relays controlling lamps, fans, internet radios, or other things.
- Speaker/buzzer for noise.
- Servos/solenoids (locks a drawer/box).
- Vibration motor under pillow.

The fun would start by coding escalation logic:
- Alarm fired: lights slowly ramp up + gentle sound.
- First snooze: lights go full daylight + "mission mode".
- Second snooze: servo locks a box holding the phone.
- Dismissed: unlocks things + plays "victory" animation.
- Presence Sensors: Perhaps the alarm continues to get worse until the user is
  far enough away from the bed.
- Proof of life: Regardless of what the user does with the phone, an alarm state
  could remain until the user gets up and does something physical somwhere else
  in the room - eg, puts a ball through a hoop.

### Lucid-dream cue generation
Use events such as REM detection to start lights or subtle cues that may
influence dreams.  In this case, the `REM` event is triggered on the ESP32/Toit
by Sleep-as-Android/MQTT.  Toit code on the ESP32 could pulse LEDs softly,
control an ultrasonic transducer, operatte vibration motors, etc.

## How to Use
The main concept is that the user would need to assemble the hardware and write
the required code/logic to do something.  Registering that code using this
library, to one of the event types from Sleep As Android, will trigger that
code when the event is raised.  (This is sometimes referred to as a 'callback'.)

### Possible events
Urbandroid list their events on [Event List](https://sleep.urbandroid.org/docs/services/automation.html#events).
In this driver, the names are exposed as constants, and can be used when setting
triggers.
#### Event List Reference
These are mostly self explanatory.  Some provide extra data alongside the alert
itself, in entries called 'value1' and 'value2':

| Constant/Event Name | Explanation |
| - | - |
| `.SLEEP-TRACKING-STARTED` | Fires when sleep tracking has started. |
| `.SLEEP-TRACKING-STOPPED` | Fires when sleep tracking has stopped. |
| `.SLEEP-TRACKING-PAUSED` | Fires when sleep tracking is paused. |
| `.SLEEP-TRACKING_RESUMED` | Fires when sleep tracking has been resumed. |
| `.ALARM-SNOOZE-CLICKED` |   Fires when a ringing alarm was snoozed. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time, example: "1582719660934"</li> <li>**value2:** alarm label as the user has specified it in the app, example: "label". (Any tabs and newline characters in the label are removed.) |
| `.ALARM-SNOOZE-CANCELLED` | Fires when a snoozed alarm alarm is cancelled. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `.TIME-TO-BED-ALARM-ALERT` | Fires when the app gives a 'bedtime' notification. <br> <ul><li>**value1:** UNIX timestamp of the _alarm start time_ triggering the sleep notification, not the time of the 'time to go to bed' alert. </li></ul> |
| `.ALARM-ALERT-START` | Fires when an alarm starts. <br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `.ALARM-RESCHEDULED` | Fires when the app is saving a new alarm time, different from the previous alarm time (it allows an external automation system to track the latest set alarm time on Sleep as Android). <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label.</li></ul> |
| `.ALARM-ALERT-DISMISS` | Fires when the alarm is dismissed.  (After the CAPTCHA is solved, if one is set).<br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label. |
| `.ALARM-SKIP-NEXT` | Fires when an alarm is dismissed from notification before it actually rings. <br><ul><li>**value1:** UNIX timestamp of the alarm start time.</li><li>**value2:** alarm label. |
| `.BEFORE-ALARM` | Fires exactly 1 hour before the next alarm is triggered.<br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li></ul>
| `.REM` | Fires when the app estimates the start of the REM phase of sleep. |
| `.SMART-PERIOD` | Fires at the start of the smart period. |
| `.BEFORE-SMART-PERIOD` | Fires 45 minutes before the start of smart period. <br><ul> <li>**value1:** UNIX timestamp of the alarm start time.</li></ul>
| `.LULLABY-START` | Fires when lullaby starts playing. |
| `.LULLABY-STOP` | Fires when lullaby is stopped (either manually or automatically). |
| `.LULLABY-VOLUME-DOWN` | Fires when the app detects that the user fell asleep, and is starting lowering the volume of lullaby. |
| `.DEEP-SLEEP` | Fires when the app detects the user is going into a deep sleep phase. <br>**Warning:** This may result in lots of events during the night and may not exactly fit the resulting sleep graph as the app can only detect phases reliably from whole-night data. |
| `.LIGHT-SLEEP` | Fires when the app detects the user going into a light sleep phase. <br>**Warning:** This may result in lots of events during the night and may not exactly fit the resulting sleep graph as the app can only detect phases reliably from whole-night data. |
| `.AWAKE` | Fires when a wake up is detected. |
| `.NOT-AWAKE` | Fires when the app detectes that the user fell asleep. |
| `.APNEA-ALARM` | Fires when the app detects a significant dip in oxygen levels. |
| `.ANTISNORING` | Fires when the app's antisnoring feature is triggered. |
| `.SOUND-EVENT-SNORE` | Fires when the app detects snoring. |
| `.SOUND-EVENT-TALK` | Fires when the app detects talking. |
| `.SOUND-EVENT-COUGHING` | Fires when the app detects coughing. |
| `.SOUND-EVENT-BABY` | Fires when the app detects the sound of a baby crying. |
| `.SOUND-EVENT-LAUGH` | Fires when the app detects laughter. |
| `.ALARM-WAKE-UP-CHECK` | Fires when the wake-up check notification is triggered. |
| `.JET-LAG-START` | Fires when the JetLag prevention feature starts. |
| `.JET-LAG-STOP` | Fires when the JetLag prevention feature is finished. |

The additional data is available to lambdas in the following way. If we wish to trigger an alert for `ALARM-ALERT-START`, and print the additional data:
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
Its as simple as that.  The code on the final line (the print statement) is
executed when the `ALARM-ALERT-START` event is triggered.  If the user writes a
function like `turn-on-lights`, this could be placed there.  Several more
instructions can be registered to other events simultaneously.

When the alarm triggers, will display, as an example:
```
[sleep-as] INFO: starting mqtt client... {client-id: 9c:9e:6e:ff:fe:77, username: username}
[sleep-as.mqtt] DEBUG: connected to broker
[sleep-as.mqtt] DEBUG: connection established
[sleep-as] DEBUG: lambda assigned: {event: alarm_alert_start}
[sleep-as] DEBUG: received json from 'clock/alarms': {value1: 1768698540000, value2: Ring Paul, event: alarm_alert_start}
  ALARM! {value1: 1768698540000, value2: Ring Paul, event: alarm_alert_start}
```
As explained alongside the event descriptiona above, `value1` in this case is
a `UNIXTIME` of the alarm set time.  (This one refers to the alarm itself in the
app, and therefore stays the same even when snoozed.)  Output and debug levels
can be changed, see Toit's
[logger capabilities](https://libs.toit.io/log/class-Logger).

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
