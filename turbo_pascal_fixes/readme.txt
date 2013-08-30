I receive a 'Runtime error 200 at ...' error message

This error is a bug with Turbo Pascal when the compiled program is run on a computer that is too fast (basically anything Pentium upwards). Thankfully there is an easy solution to this program.

Firstly download and decompress these files TurboPascal-Unpack.zip and TurboPascalPatch.zip.

Then from within command prompt run TPPATCH <target.exe>, target.exe being the program file requiring patching

If you receive a message 'Überprüfe die Datei ...defacto.exe ist keine von TP7/BP7 erzeugte Datei.' Then you need to first unpackage the file by running UNP <target file .exe>

Then if you run TPPATCH <target.exe> again, and you should receive the 'Überprüfe die Datei ...Datei ist ok. Die Datei wird jetzt gepatcht... fertig.' which means you successfully patched the file. So now it should work successfully on your modern day computer.