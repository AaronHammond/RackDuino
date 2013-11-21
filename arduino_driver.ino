void setup(){
  Serial.begin(9600);  
}
void loop (){

  int i=0;
  char commandbuffer[100];

  if(Serial.available()){
     delay(100);
     while( Serial.available() && i< 99) {
        commandbuffer[i++] = Serial.read();
     }
     commandbuffer[i++]='\0';
  }

  if(i>0){
   String temp = String(commandbuffer); 
   int pos1 = temp.indexOf("#");
   int pos2 = temp.indexOf("#", pos1+1);
   
   String ports = temp.substring(0, pos1);
   String commands = temp.substring(pos1+1, pos2);
   String vals = temp.substring(pos2+1);
   
   char port_char[ports.length()+1];
   char command_char[commands.length()+1];
   char val_char[vals.length()+1];
   
   ports.toCharArray(port_char, ports.length()+1);
   commands.toCharArray(command_char, commands.length()+1);
   vals.toCharArray(val_char, vals.length()+1);
   
   int portnum = atoi(port_char);
   int command = atoi(command_char);
   int val = atoi(val_char);
   int res = 0;
   
   if(command == 0){
     digitalWrite(portnum, (val == 1)? true: false); 
   }
   else if (command == 1){
     Serial.println(digitalRead(portnum));
   }
   else if (command == 2){
     analogWrite(portnum, val);
   }
   else if (command == 3){
     Serial.println(analogRead(portnum));
   }
   else{
     Serial.println("ERROR");
   }
  }
}

