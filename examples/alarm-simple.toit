import sleep-as-android show *

/**
Simple example showing a Lambda being assigned to the sleep-as-android object
  and it being triggered for all events raised by the app.

When the lambda is called, it is passed the event data as a map.  In order
  to tell what kind of event it is, the `| event-data/Map |` part of the code
  below is necessary for the Lambda.
*/

main:
  sleep-as-android := Sleep-as-android
      --mqtt-host="3d42df32e786404fb37dd849277b56db.s1.eu.hivemq.cloud"
      --mqtt-password="TestingUsersUnite1"
      --mqtt-username="testing"
      --mqtt-topic="clock/alarms"

  sleep-as-android.assign-catch-all :: | event-data/Map |
    print " Catchall! $event-data"
