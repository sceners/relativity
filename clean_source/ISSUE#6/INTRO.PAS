unit intro;
interface
procedure Introduction;

implementation
uses variable,vga,sprite,tech,crt;

Procedure WriteMda(x,y:word; stringi:string; buf:buffer);
var numb,i:integer;
begin
     for i:= 1 to Length(stringi) do
     begin
          if (stringi[i]>='a') and (stringi[i]<='z') then
          begin
               numb:=ord(stringi[i])-96;
               put_image(x + (i*font.images[1].x)+1 ,y,numb,buf,font,false);
          end;
          if (stringi[i]>='A') and (stringi[i]<='Z') then
          begin
               numb:=ord(stringi[i])-64+26;
               put_image(x + (i*font.images[1].x)+1 ,y,numb,buf,font,false);
          end;
          if (stringi[i]='''') then
               put_image(x + (i*font.images[1].x)+1 ,y,53,buf,font,false);
          if (stringi[i]=',') then
               put_image(x + (i*font.images[1].x)+1 ,y,54,buf,font,false);
          if (stringi[i]='.') then
               put_image(x + (i*font.images[1].x)+1 ,y,55,buf,font,false);
          if (stringi[i]=':') then
               put_image(x + (i*font.images[1].x)+1 ,y,56,buf,font,false);
          if (stringi[i]='!') then
               put_image(x + (i*font.images[1].x)+1 ,y,57,buf,font,false);
          if (stringi[i]='?') then
               put_image(x + (i*font.images[1].x)+1 ,y,58,buf,font,false);
          if (stringi[i]>='0') and (stringi[i]<='9') then
          begin
               numb:=ord(stringi[i])-47;
               put_image(x + (i*font.images[1].x)+2 ,y+3,numb,buf,num,false);
          end;
     end;
end;

procedure Introduction;
begin
     fillchar(buf^,maxbuf,0);
     writeMda(20,1,'Fury of The Furry Fighter v1.0',buf);
     put_image(1,20,1,buf,allenemy[1],false);
     put_image(25,20,1,buf,allenemy[2],false);
     put_image(50,20,1,buf,allenemy[3],false);
     put_image(1,40,1,buf,allenemy[4],false);
     put_image(25,40,1,buf,allenemy[5],false);
     put_image(50,40,1,buf,allenemy[6],false);
     put_image(1,60,1,buf,allenemy[7],false);
     put_image(25,60,1,buf,allenemy[8],false);
     put_image(50,60,1,buf,allenemy[9],false);
     put_image(1,80,1,buf,allenemy[10],false);
     put_image(25,80,1,buf,allenemy[11],false);
     put_image(50,80,1,buf,allenemy[12],false);
     put_image(25,100,1,buf,allenemy[13],false);
     fury_color(2);
     put_image(160,100,1,buf,fury_image,false);
     WaitRetrace;
     move32fast(buf^,mem[$a000:00],maxbuf);
     readkey;
     fillchar(buf^,maxbuf,0);
     WaitRetrace;
     move32fast(buf^,mem[$a000:00],maxbuf);
end;

end.