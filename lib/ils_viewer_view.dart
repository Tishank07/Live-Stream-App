import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:videosdk/videosdk.dart';
import './livestream_player.dart';
import 'package:videosdk_flutter_quickstart_ils/chat/chat_view.dart';

class ILSViewerView extends StatefulWidget {
  final Room room;
  final String email; // Add email field
  const ILSViewerView({super.key, required this.room,required this.email});

  @override
  State<ILSViewerView> createState() => _ILSViewerViewState();
}

class _ILSViewerViewState extends State<ILSViewerView> {
  String hlsState = "HLS_STOPPED";
  String? downstreamUrl;
  Map<String, Participant> participants = {};

  @override
  void initState() {
    super.initState();
    //initialize the room's hls state and hls's downstreamUrl
    hlsState = widget.room.hlsState;
    downstreamUrl = widget.room.hlsDownstreamUrl;

        //Add the ChatView widget to display chat messages
    //  ChatView(room: widget.room, displayName: "John Deo");
          ChatView(
  room: widget.room,
 displayName: widget.email,
  participants: participants,
 // participant: widget.room.localParticipant,
); 


    //add the hlsStateChanged event listener
    setMeetingEventListener();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(widget.room.id,
                        style: const TextStyle(color: Colors.white))),
                ElevatedButton(
                  onPressed: () =>
                      {Clipboard.setData(ClipboardData(text: widget.room.id))},
                  child: const Text("Copy Meeting Id"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => {widget.room.leave()},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Leave"),
                )
              ],
            ),
          ),
          //Show the livestream player if the downstreamUrl is present
          downstreamUrl != null
              ? LivestreamPlayer(downstreamUrl: downstreamUrl!)
              : const Text("Host has not started the HLS",
                  style: TextStyle(color: Colors.white)),

          // ChatView(room: widget.room, displayName: "John Deo"),       //chatbox called
                ChatView(
  room: widget.room,
 displayName: widget.email,
  participants: participants,
 // participant: widget.room.localParticipant,
),

        ],
      ),
      
    );

  }

  void setMeetingEventListener() {
    // listening to hlsStateChanged events and updating the hlsState and downstremUrl
    widget.room.on(
      Events.hlsStateChanged,
      (Map<String, dynamic> data) {
        String status = data['status'];
        if (mounted) {
          setState(() {
            hlsState = status;
            if (status == "HLS_PLAYABLE" || status == "HLS_STOPPED") {
              downstreamUrl = data['downstreamUrl'];
            }
          });
        }
      },
    );
  }
}