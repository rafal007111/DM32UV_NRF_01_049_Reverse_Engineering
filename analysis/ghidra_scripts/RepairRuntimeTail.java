import ghidra.app.script.GhidraScript;
import ghidra.program.model.mem.*;
import ghidra.program.model.address.*;
public class RepairRuntimeTail extends GhidraScript {
    public void run() throws Exception {
        Memory m=currentProgram.getMemory();
        long src=Integer.toUnsignedLong(m.getInt(toAddr(0x030000d8L)));
        long dest=Integer.toUnsignedLong(m.getInt(toAddr(0x030000d0L)));
        long end=Integer.toUnsignedLong(m.getInt(toAddr(0x030000d4L)));
        long available=m.getBlock(toAddr(src)).getEnd().getOffset()-src+1;
        Address missing=toAddr(dest+available);
        if(missing.getOffset()>=end)return;
        MemoryBlock runtime=m.getBlock(missing);
        if(runtime.isInitialized()){
            if(!runtime.getStart().equals(missing))m.split(runtime,missing);
            MemoryBlock tail=m.getBlock(missing);
            clearListing(missing,toAddr(end-1));
            tail=m.convertToUninitialized(tail);
            tail.setName("IRAM_runtime_missing_source");tail.setExecute(false);
        }
        println("RUNTIME_UNKNOWN_TAIL "+missing+" .. "+toAddr(end-1));
    }
}
