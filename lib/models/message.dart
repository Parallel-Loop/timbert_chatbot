class Message {
  bool isSender;
  String msg;
  bool isThumbsUpClicked;
  Message(this.isSender, this.msg, {this.isThumbsUpClicked = false});
}