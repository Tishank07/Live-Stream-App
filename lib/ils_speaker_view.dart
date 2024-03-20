import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import 'package:videosdk_flutter_quickstart_ils/meeting_controls.dart';
import 'package:videosdk_flutter_quickstart_ils/participant_tile.dart';
import 'package:videosdk_flutter_quickstart_ils/chat/chat_view.dart';

class ILSSpeakerView extends StatefulWidget {
  final Room room;

  const ILSSpeakerView({Key? key, required this.room}) : super(key: key);

  @override
  State<ILSSpeakerView> createState() => _ILSSpeakerViewState();
}

class _ILSSpeakerViewState extends State<ILSSpeakerView> {
  var micEnabled = true;
  var camEnabled = true;
  String hlsState = "HLS_STOPPED";

  Map<String, Participant> participants = {};

  @override
  void initState() {
    super.initState();
    // Setting up the event listeners and initializing the participants and HLS state
    setMeetingEventListener();
    participants.putIfAbsent(
        widget.room.localParticipant.id, () => widget.room.localParticipant);
    // Filtering the CONFERENCE participants to be shown in the grid
    widget.room.participants.values.forEach((participant) {
      if (participant.mode == Mode.CONFERENCE) {
        participants.putIfAbsent(participant.id, () => participant);
      }
    });
    hlsState = widget.room.hlsState;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.room.id,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => {
                  Clipboard.setData(ClipboardData(text: widget.room.id)),
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Meeting Id Copied"),
                  ))
                },
                child: const Text("Copy Meeting Id"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => {widget.room.leave()},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Leave"),
              ),
              const SizedBox(width: 10),
              // Add PopupMenuButton here

              PopupMenuButton<int>(
  icon: const Icon(
    Icons.people,
    color: Colors.white,
  ),
  color: Colors.white,
  itemBuilder: (context) {
    return List.generate(
      participants.length,
      (index) {
        var participant = participants.values.elementAt(index);
        return PopupMenuItem<int>(
          value: index,
          child: Text(
            '${index + 1}. ${participant.displayName}',
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  },
)

            ],
          ),
          const SizedBox(
            height: 20,
          ),
          // Showing the current HLS state
          Text(
            "Current HLS State: ${hlsState == "HLS_STARTED" || hlsState == "HLS_PLAYABLE" ? "Livestream is Started" : hlsState == "HLS_STARTING" ? "Livestream is starting" : hlsState == "HLS_STOPPING" ? "Livestream is stopping" : "Livestream is stopped"}",
            style: const TextStyle(color: Colors.white),
          ),
          // Render all participants in the room
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemBuilder: (context, index) {
                return ParticipantTile(
                    participant: participants.values.elementAt(index));
              },
              itemCount: participants.length,
            ),
          ),

          ////////////////chat box/////////////////////////

         ChatView(
  room: widget.room,
 displayName: widget.room.localParticipant.displayName,
  participant: widget.room.localParticipant,
),


          // Rendering the meeting Controls
          MeetingControls(
            hlsState: hlsState,
            onToggleMicButtonPressed: () {
              micEnabled ? widget.room.muteMic() : widget.room.unmuteMic();
              micEnabled = !micEnabled;
            },
            onToggleCameraButtonPressed: () {
              camEnabled ? widget.room.disableCam() : widget.room.enableCam();
              camEnabled = !camEnabled;
            },
            // HLS handler which will start and stop HLS
            onHLSButtonPressed: () => {
              if (hlsState == "HLS_STOPPED")
                {
                  widget.room.startHls(config: {
                    "layout": {
                      "type": "SPOTLIGHT",
                      "priority": "PIN",
                      "GRID": 20,
                    },
                    "mode": "video-and-audio",
                    "theme": "DARK",
                    "quality": "high",
                    "orientation": "portrait",
                  })
                }
              else if (hlsState == "HLS_STARTED" || hlsState == "HLS_PLAYABLE")
                {widget.room.stopHls()}
            },
          ),
        ],
      ),
    );
  }

  // Listening to room events for participants join, left and HLS state changes
  void setMeetingEventListener() {
    widget.room.on(
      Events.participantJoined,
      (Participant participant) {
        // Adding only Conference participant to show in grid
        if (participant.mode == Mode.CONFERENCE) {
          setState(
            () => participants.putIfAbsent(participant.id, () => participant),
          );
        }
      },
    );

    widget.room.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(
          () => participants.remove(participantId),
        );
      }
    });
    widget.room.on(
      Events.hlsStateChanged,
      (Map<String, dynamic> data) {
        setState(
          () => hlsState = data['status'],
           );
      },
    );
  }
}

