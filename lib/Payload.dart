
class Payload{
  String sender='';
  String receiver='';
  String message='';
  String timestamp='';
  bool broadcast=true;
  String type='Payload';
  Payload(this.sender,this.receiver,this.message,this.timestamp);
  
}
class Ack{
  String id='';
  String type="Ack";
  Ack(this.id);

}