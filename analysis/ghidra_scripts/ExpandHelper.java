import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.*;
public class ExpandHelper extends GhidraScript {
    public void run() throws Exception {
        int added=0;
        for(long pos=0x10200;pos+4<=0x10f00;pos+=2) {
            int high=Short.toUnsignedInt(currentProgram.getMemory().getShort(toAddr(pos)));
            if((high&0xfc00)!=0xe000)continue;
            long half=((long)(high&1023)<<16)|Short.toUnsignedInt(currentProgram.getMemory().getShort(toAddr(pos+2)));
            if((half&(1L<<25))!=0)half-=1L<<26;
            long dest=pos+2*half;
            if(dest<0x10200||dest>=0x10f00)continue;
            int prefix=Short.toUnsignedInt(currentProgram.getMemory().getShort(toAddr(dest)));
            if((prefix&0xffe0)!=0x14c0 && (prefix&0xffe0)!=0x14d0)continue;
            if(getFunctionAt(toAddr(dest))==null) {
                disassemble(toAddr(dest));
                if(createFunction(toAddr(dest),null)!=null)added++;
            }
        }
        println("HELPER_FUNCTIONS_ADDED "+added);
    }
}
