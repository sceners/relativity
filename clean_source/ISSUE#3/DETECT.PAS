{$m 20000,0,0}  {dont' forget to reduce the heap!}
uses sds_det;
var
  Base, Irq, Dma : WORD;
  Card           : WORD;

begin
  Writeln('SDS Quick Detection Utility, written by Maple Leaf, 1997.');
  Writeln('Autodetecting ...');

  if DetectGUS(Base, Irq, Dma) then writeln('GUS found at base port ',base,', using IRQ',irq,' and DMA #',dma);
  If DetectSB16(Base, Irq, Dma) then writeln('SB16 found at base port ',base,', using IRQ',irq,' and DMA #',dma);
  if DetectARIA(Base, Irq, Dma) then writeln('ARIA found at base port ',base,', using IRQ',irq,' and DMA #',dma);
  If DetectSBPro(Base, Irq, Dma) then writeln('SB Pro found at base port ',base,', using IRQ',irq,' and DMA #',dma);
  If DetectPAS(Base, Irq, Dma) then writeln('PAS/PAS16 found at base port ',base,', using IRQ',irq,' and DMA #',dma); {}
  If DetectWSS(Base,Irq,Dma) then writeln('WSS or comp. (Crystal/Analog CODEC) found at base ',base,', IRQ',irq,' DMA #',dma);

  If DetectSB(Base, Irq, Dma) and
     not(DetectPAS(Base, Irq, Dma) or
         DetectSBPro(Base, Irq, Dma) or
         DetectSB16(Base, Irq, Dma) or
         DetectARIA(Base, Irq, Dma)) then writeln('SB found at base port ',base,', using IRQ',irq,' and DMA #',dma);

  if not DetectGUS(Base, Irq, Dma) and
     not DetectSB16(Base, Irq, Dma) and
     not DetectSBPro(Base, Irq, Dma) and
     not DetectSB(Base, Irq, Dma) and
     not DetectPAS(Base, Irq, Dma) and
     not DetectARIA(Base, Irq, Dma) then writeln('Sorry, cannot find any of the known sound cards.');

end.