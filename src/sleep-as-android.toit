// Copyright (C) 2026 Toit Contributors. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import esp32
import mqtt
import encoding.json
import certificate-roots
import log

/**
Simple MQTT wrapper tailored for triggering toit events when the Sleep-As-Android
  application fires its events.

*/

class Sleep-as-android:
  /**
  Fires when sleep tracking has started.
  */
  static SLEEP-TRACKING-STARTED ::= "sleep_tracking_started"

  /**
  Fires when sleep tracking has stopped.
  */
  static SLEEP-TRACKING-STOPPED ::= "sleep_tracking_stopped"

  /**
  Fires when sleep tracking is paused.
  */
  static SLEEP-TRACKING-PAUSED ::= "sleep_tracking_paused"

  /**
  Fires when sleep tracking has been resumed.
  */
  static SLEEP-TRACKING_RESUMED ::= "sleep_tracking_resumed"

  /**
  Fires when a ringing alarm was snoozed.

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934".
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending).
  */
  static ALARM-SNOOZE-CLICKED ::= "alarm_snooze_clicked"

  /**
  Fires when a snoozed alarm alarm is cancelled.

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934".
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending).
  */
  static ALARM-SNOOZE-CANCELLED ::= "alarm_snooze_canceled"

  /**
  Fires when the app gives a 'bedtime' notification.

  - value1: UNIX timestamp of the alarm start time triggering the sleep notification.
  */
  static TIME-TO-BED-ALARM-ALERT ::= "time_to_bed_alarm_alert"

  /**
  Fires when an alarm starts.

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934".
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending).
  */
  static ALARM-ALERT-START ::= "alarm_alert_start"

  /**
  Fires when the app is saving a new alarm time, different from the previous
    alarm time (it allows an external automation system to track the latest set
    alarm time on Sleep as Android).

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934".
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending).
  */
  static ALARM-RESCHEDULED ::= "alarm_rescheduled"

  /**
  Fires when the alarm is dismissed.  (After the CAPTCHA is solved, if it’s set).

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934"
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending)
  */
  static ALARM-ALERT-DISMISS ::= "alarm_alert_dismiss"

  /**
  Fires when an alarm is dismissed from notification before it actually rings.

  - value1: UNIX timestamp of the alarm start time, example: "1582719660934"
  - value2: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending)
  */
  static ALARM-SKIP-NEXT ::= "alarm_skip_next"

  /**
  Fires exactly 1 hour before the next alarm is triggered.
    value1: UNIX timestamp of the alarm start time, example: "1582719660934"
  */
  static BEFORE-ALARM ::= "before_alarm"

  /**
  Fires when the app estimates the start of the REM phase of sleep.
  */
  static REM ::= "rem"

  /**
  Fires at the start of the smart period.
  */
  static SMART-PERIOD ::= "smart_period"

  /**
  Fires 45 minutes before the start of smart period.

  - value: alarm label, example: "label" (Any tabs and newline characters in the label will be removed before sending)
  */
  static BEFORE-SMART-PERIOD ::= "before_smart_period"

  /**
  Fires when lullaby starts playing.
  */
  static LULLABY-START ::= "lullaby_start"

  /**
  Fires when lullaby is stopped (either manually or automatically).
  */
  static LULLABY-STOP ::= "lullaby_stop"

  /**
  Fires when the app detects that the user fell asleep, and is starting lowering
    the volume of lullaby.
  */
  static LULLABY-VOLUME-DOWN ::= "lullaby_volume_down"

  /**
  Fires when the app detects the user is going into a deep sleep phase.

  Warning: This may result in lots of events during the night and may not
    exactly fit the resulting sleep graph as the app can only detect phases
    reliably from whole-night data.
  */
  static DEEP-SLEEP ::= "deep_sleep"

  /**
  Fires when the app detects the user going into a light sleep phase.

  Warning: This may result in lots of events during the night and may not
    exactly fit the resulting sleep graph as the app can only detect phases
    reliably from whole-night data.
  */
  static LIGHT-SLEEP ::= "light_sleep"

  /**
  Fires when a wake up is detected.
  */
  static AWAKE ::= "awake"

  /**
  Fires when the app detectes that the user fell asleep.
  */
  static NOT-AWAKE ::= "not_awake"

  /**
  Fires when the app detects a significant dip in oxygen levels.
  */
  static APNEA-ALARM ::= "apnea_alarm"

  /**
  Fires when the app's antisnoring feature is triggered.
  */
  static ANTISNORING ::= "antisnoring"

  /**
  Fires when the app detects snoring.
  */
  static SOUND-EVENT-SNORE ::= "sound_event_snore"

  /**
  Fires when the app detects talking.
  */
  static SOUND-EVENT-TALK ::= "sound_event_talk"

  /**
  Fires when the app detects coughing.
  */
  static SOUND-EVENT-COUGHING ::= "sound_event_cough"

  /**
  Fires when the app detects the sound of a baby crying.
  */
  static SOUND-EVENT-BABY ::= "sound_event_baby"

  /**
  Fires when the app detects laughter.
  */
  static SOUND-EVENT-LAUGH ::= "sound_event_laugh"

  /**
  Fires when the wake-up check notification is triggered.
  */
  static ALARM-WAKE-UP-CHECK ::= "alarm_wake_up_check"

  /**
  Fires when the the app is saving the next alarm time (after snoozing, after alarm start, after alarm dismiss).

  Todo: Was defined twice - determine if this is required:
  */
  static ALARM-RESCHEDULED-2 ::= "alarm_rescheduled"

  /**
  Fires when the JetLag prevention feature starts.
  */
  static JET-LAG-START ::= "jet_lag_start"

  /**
  Fires when the JetLag prevention feature is finished.
  */
  static JET-LAG-STOP ::= "jet_lag_stop"

  static event-list_/Set ::= {
    SLEEP-TRACKING-STARTED,
    SLEEP-TRACKING-STOPPED,
    SLEEP-TRACKING-PAUSED,
    SLEEP-TRACKING_RESUMED,
    ALARM-SNOOZE-CLICKED,
    ALARM-SNOOZE-CANCELLED,
    TIME-TO-BED-ALARM-ALERT,
    ALARM-ALERT-START,
    ALARM-RESCHEDULED,
    ALARM-ALERT-DISMISS,
    ALARM-SKIP-NEXT,
    BEFORE-ALARM,
    REM,
    SMART-PERIOD,
    BEFORE-SMART-PERIOD,
    LULLABY-START,
    LULLABY-STOP,
    LULLABY-VOLUME-DOWN,
    DEEP-SLEEP,
    LIGHT-SLEEP,
    AWAKE,
    NOT-AWAKE,
    APNEA-ALARM,
    ANTISNORING,
    SOUND-EVENT-SNORE,
    SOUND-EVENT-TALK,
    SOUND-EVENT-COUGHING,
    SOUND-EVENT-BABY,
    SOUND-EVENT-LAUGH,
    ALARM-WAKE-UP-CHECK,
    ALARM-RESCHEDULED-2,
    JET-LAG-START,
    JET-LAG-STOP}


  // Application defaults as statics
  static LOGGER-NAME_ ::= "sleep-as"
  static DEFAULT-TOPIC_ ::= "clock/alarms"
  static DEFAULT-PORT_ ::= 1883
  static DEFAULT-TLS-PORT_ ::= 8883

  logger_/log.Logger := ?
  client_/mqtt.Client? := null
  topic_/string := ?
  topic-callback_/Lambda? := null
  event-lambdas_/Map := {:}
  catch-all_/Lambda? := null

  /**
  Constructor that creates its own MQTT client object.
  */
  constructor
      --mqtt-topic/string=DEFAULT-TOPIC_
      --mqtt-port/int?=null
      --mqtt-host/string
      --mqtt-password/string
      --mqtt-username/string
      --mqtt-client-id/string?=null
      --tls/bool=true
      --logger/log.Logger=log.default:
    logger_ = logger.with-name LOGGER-NAME_
    topic_ = mqtt-topic
    client-id := mqtt-client-id ? mqtt-client-id : mac-address-string
    set-topic-callback_

    // Using routes method to avoid catch-22 defined in docs.
    routes/Map := {topic_ : topic-callback_}
    if tls:
      port := mqtt-port ? mqtt-port : DEFAULT-TLS-PORT_
      certificate-roots.install-common-trusted-roots
      client_ = mqtt.Client.tls --host=mqtt-host --routes=routes --port=port --logger=(logger_.with-name "mqtt")
    else:
      port := mqtt-port ? mqtt-port : DEFAULT-PORT_
      client_ = mqtt.Client --host=mqtt-host --routes=routes --port=port --logger=(logger_.with-name "mqtt")

    options := mqtt.SessionOptions
        --client-id=client-id
        --username=mqtt-username
        --password=mqtt-password

    logger_.info "starting mqtt client..." --tags={"client-id":client-id, "username":mqtt-username}
    client_.start --options=options

  /**
  Constructor for use with a user-created MQTT client object.
  */
  constructor --topic/string=DEFAULT-TOPIC_ --client/mqtt.Client --logger/log.Logger=log.default:
    logger_ = logger.with-name LOGGER-NAME_
    topic_ = topic
    client_ = client
    set-topic-callback_
    if client.is-closed:
      logger_.info "starting mqtt client..."
      client_.start
    client_.subscribe topic_ topic-callback_

  /**
  Sets the callback lambda for the topic.

  Can't do this iņ the constructors without defining it twice.
  */
  set-topic-callback_ -> none:
    topic-callback_ = :: | topic/string payload/ByteArray |
      decoded := {:}
      exception := catch:
        decoded = json.decode payload

      if exception:
        logger_.error "invalid json message" --tags={"topic":topic, "exception":exception}
      else:
        logger_.debug "received valid json" --tags={"topic":topic, "content":decoded}

      handle-event_ decoded

  handle-event_ json-map/Map -> none:
    event-name := ""
    if json-map.contains "event":
      event-name = json-map["event"]

    if event-lambdas_.contains event-name:
      event-lambdas_[event-name].call json-map
    else if event-list_.contains event-name and catch-all_:
      catch-all_.call json-map
    else:
      logger_.error "unhandled event" --tags=json-map


  /**
  Sends a simple message with the system time to the topic for testing purposes.
  */
  publish topic/string=topic_  -> none:
    payload := json.encode {"now": Time.now.utc.to-iso8601-string}
    client_.publish topic payload

  /**
  Produces the ESP32 mac-address in hex representation as a string.

  Used as a default client id in this class.
  */
  static mac-address-string separator/int=':' -> string:
    out-list/List := []
    esp32.mac-address.do: | byte |
      out-list.add "$(%02x byte)"
    return out-list.join (string.from-rune separator)

  /**
  Assigns a lambda to a Sleep-As-Android event.
  */
  assign-event --event/string lambda/Lambda? -> none:
    assert: event-list_.contains event
    if lambda:
      logger_.debug "event lambda assigned" --tags={"event": event}
      event-lambdas_[event] = lambda
    else:
      logger_.debug "event lambda removed" --tags={"event": event}
      event-lambdas_.remove event

  /**
  Assigns this lambda to all Sleep-As-Android events, if they have not got
    a lambda assigned of their own.  (For troubleshooting.  Use with care.)
  */
  assign-catch-all lambda/Lambda? -> none:
    if lambda:
      logger_.debug "catchall lambda assigned"
      catch-all_ = lambda
    else:
      logger_.debug "catchall lambda removed"
      catch-all_ = null
