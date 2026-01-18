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
  to specific events
- The MCU run autonomously without the phone once state is known.
- Custom logic can be created, especially when integrating with other sensors.
- Using other capabilities (such as pulling weather information from the
  internet), heating and other environmental things can be controlled.


## Some Ideas

### Smart Sunrise
Instead of a fixed sunrise lamp, using Sleep-As-Androids's smart-wake behavior
to control a lamp that is synced to the users' actual wake phase. For example:
- During wake window, gradually brighten room
- If the alarm triggers earlier use a fast ramp-up to help the transition
- Rules such as increasing brightness regardless of snoozing the alarm
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
- Starts a smart plug (or controls a relay in the coffee machine itself - may require expertise).
- Applies rules such as staying out of bed for > X minutes (eg no 'back to sleep' event).
- Combined with a human presence sensor, it could avoid starting the coffee machine if the user is not present.

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

### Lucid-dream cue generator
Use events such as REM detection to start lights or subtle cues that may
influence dreams.
- `REM` event is triggered on the ESP32/Toit by MQTT.
- This could puls LEDs softly.
- Control an ultrasonic transducer.
- Operatte vibration motors.

### The Incredible Machine
Who remembers [this game](https://en.wikipedia.org/wiki/The_Incredible_Machine)?  The possibilities are almost as endless. :)

## How to Use




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
