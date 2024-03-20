import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';


class ChatView extends StatefulWidget {
  final Room room;
  final String displayName;
   final Participant participant;
  

  const ChatView({Key? key, required this.room, required this.displayName, required this.participant});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late PubSubMessages messages;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    messages = PubSubMessages(messages: []);

    widget.room.pubSub.subscribe("CHAT", messageHandler).then((value) {
      setState(() {
        messages = value;
      });
    });
  }

  void messageHandler(PubSubMessage message) {
    setState(() {
      messages.messages.add(message);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,  // height of the container
      padding: const EdgeInsets.all(8.0),
      color: Colors.transparent.withOpacity(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display messages in a scrollable view
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: messages.messages
                    .map(
                      (message) => Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0),                 //
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          // '${_getDisplayName(message.senderId)}: ${message.message}', // Concatenate display name with message
                          // style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Set text color to black and make display name bold

                          // message.message,
                          '${widget.displayName}: ${message.message}',
                          style: const TextStyle(color: Colors.white), // Set text color to white
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
         const SizedBox(height: 20),
          // Input area for sending messages
        Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: ChatInput(
            messageController: _messageController,
            onSendMessage: sendMessage,
          ),
        ),
        ],
      ),
    );
  }

  // Method to send a chat message
  void sendMessage(String message) {
    widget.room.pubSub.publish(
      "CHAT",
      message,
      const PubSubPublishOptions(persist: true),
    );
    _messageController.clear();
  }

  @override
  void dispose() {
    widget.room.pubSub.unsubscribe("CHAT", messageHandler);
    super.dispose();
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController messageController;
  final void Function(String) onSendMessage;

  const ChatInput({
    Key? key,
    required this.messageController,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                onSendMessage(messageController.text);
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

