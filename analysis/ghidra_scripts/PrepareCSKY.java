import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import ghidra.program.model.mem.*;
import java.io.ByteArrayInputStream;
import java.io.IOException;

public class PrepareCSKY extends GhidraScript {
    private long imageStart;
    public void run() throws Exception {
        setAnalysisOption(currentProgram,"Aggressive Instruction Finder", "false");
        setAnalysisOption(currentProgram,"Decompiler Parameter ID", "false");
        setAnalysisOption(currentProgram,"Non-Returning Functions - Discovered", "false");
        Memory memory = currentProgram.getMemory();
        MemoryBlock flash = memory.getBlocks()[0];
        imageStart=flash.getStart().getOffset();
        flash.setName("FLASH_LCSFC"); flash.setRead(true); flash.setWrite(false); flash.setExecute(true);
        long runtimeDest=word(memory,0xd0), runtimeEnd=word(memory,0xd4), runtimeSource=word(memory,0xd8);
        long dataDest=word(memory,0xc4), dataEnd=word(memory,0xc8), dataSource=word(memory,0xcc);
        copy(memory,"IRAM_runtime",runtimeSource,runtimeDest,(int)(runtimeEnd-runtimeDest),true);
        copy(memory,"SRAM_initialized",dataSource,dataDest,(int)(dataEnd-dataDest),false);
        MemoryBlock bss = memory.createUninitializedBlock("IRAM_bss_stack",toAddr(runtimeEnd),0x58000-runtimeEnd,false);
        bss.setRead(true); bss.setWrite(true); bss.setExecute(false);
        Address entry = currentProgram.getMinAddress();
        entry = toAddr(imageStart);
        disassemble(entry);
        createFunction(entry,"startup_entry");
        // Vector base is loaded by startup from payload+0xb8. Only seed in-range code pointers.
        for (int off=0;off<0x200;off+=4) {
            long target=Integer.toUnsignedLong(memory.getInt(toAddr(0x10000+off)));
            if ((target&1)==0 && target>=0x10200 && target<runtimeEnd) {
                Address address=toAddr(target); disassemble(address);
                if(getFunctionAt(address)==null) createFunction(address,null);
            }
        }
        println("CSKY_STARTUP_SEEDED "+entry);
    }
    private long word(Memory m,int offset) throws Exception { return Integer.toUnsignedLong(m.getInt(toAddr(imageStart+offset))); }
    private void copy(Memory memory,String name,long source,long dest,int size,boolean executable) throws Exception {
        MemoryBlock original=memory.getBlock(toAddr(source));
        int available=(int)Math.min(size,original.getEnd().getOffset()-source+1);
        byte[] bytes=new byte[available];
        if(memory.getBytes(toAddr(source),bytes)!=available)throw new IOException("Partial source read");
        MemoryBlock b=memory.createInitializedBlock(name,toAddr(dest),new ByteArrayInputStream(bytes),available,monitor,false);
        b.setRead(true); b.setWrite(!executable); b.setExecute(executable);
        if(available<size){
            MemoryBlock tail=memory.createUninitializedBlock(name+"_missing_source",toAddr(dest+available),size-available,false);
            tail.setRead(true);tail.setWrite(false);tail.setExecute(false);
            println("MISSING_RUNTIME_SOURCE bytes="+(size-available));
        }
    }
}
