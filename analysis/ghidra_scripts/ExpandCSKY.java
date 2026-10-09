import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.mem.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
public class ExpandCSKY extends GhidraScript {
    public void run() throws Exception {
        Memory mem=currentProgram.getMemory(); int added=0;
        long imageBase=mem.getBlock("FLASH_LCSFC").getStart().getOffset();
        long flashCodeEnd=Integer.toUnsignedLong(mem.getInt(toAddr(imageBase+0xcc)));
        long runtimeEnd=Integer.toUnsignedLong(mem.getInt(toAddr(imageBase+0xd4)));
        long[][] ranges={{imageBase,flashCodeEnd},{0x10200L,runtimeEnd}};
        for(long[] range:ranges) {
            for(long pos=range[0];pos+4<range[1];pos+=2) {
                int hi=Short.toUnsignedInt(mem.getShort(toAddr(pos)));
                if((hi&0xfc00)!=0xe000)continue;
                int lo=Short.toUnsignedInt(mem.getShort(toAddr(pos+2)));
                long displacement=((long)(hi&0x3ff)<<16)|lo;
                if((displacement&0x2000000L)!=0)displacement-=0x4000000L;
                long target=pos+displacement*2;
                if(!((target>=imageBase&&target<flashCodeEnd)||(target>=0x10200L&&target<runtimeEnd)))continue;
                Address a=toAddr(target);
                int prologue=Short.toUnsignedInt(mem.getShort(a));
                if((prologue&0xffe0)!=0x14c0)continue;
                if(getFunctionAt(a)!=null)continue;
                if(getFunctionContaining(a)!=null)continue;
                disassemble(a); if(createFunction(a,null)!=null)added++;
            }
        }
        long[] known=currentProgram.getName().contains("NRF") ? new long[]{} : new long[]{0x0305c600L,0x03053788L};
        String[] names={"boot_sequence_with_modified_call","candidate_function_called_at_patch_site"};
        for(int i=0;i<known.length;i++){
            Address a=toAddr(known[i]); disassemble(a);
            Function f=getFunctionAt(a); if(f==null)f=createFunction(a,null);
            if(f!=null)f.setName(names[i],SourceType.USER_DEFINED);
        }
        println("DIRECT_CALL_PUSH_CANDIDATES_ADDED "+added);
    }
}
