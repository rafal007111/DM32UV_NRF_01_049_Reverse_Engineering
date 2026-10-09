import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.mem.*;
import ghidra.program.model.symbol.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/** Read-only evidence export. Does not assign patch state or alter firmware. */
public class InspectScanIntegration extends GhidraScript {
    public void run() throws Exception {
        File dir=new File(getScriptArgs()[0]); dir.mkdirs();
        Set<Function> functions=new LinkedHashSet<>();
        long[] entries={0x0300c000L,0x0302e144L,0x0302e1a4L,0x0302edc8L,
            0x0302f2f8L,0x0302f370L,0x0302f388L,0x0302f3d0L,0x0302f418L,
            0x0302f780L,0x0304d07cL,0x0304d970L,0x0304d9c4L,
            0x0305693aL,0x030569b8L,0x0307050cL,0x030705a8L,0x0002e174L,
            0x0001064aL,0x0303c1f4L,0x0303859cL,0x0305680cL,
            0x0303a748L,0x0303cda8L,0x0304d46cL,0x0305696cL,0x030569bcL,
            0x030567ecL,0x0303ec8cL,0x03013078L,0x03037674L,0x03037658L,
            0x03036498L,0x03036480L,0x03036468L,0x03036440L,0x030363c4L,
            0x030369f8L,0x0303cb04L,0x0303cb78L};
        try(PrintWriter refs=writer(new File(dir,"integration_callers.tsv"))) {
            refs.println("target\tfrom\tfunction\ttype");
            for(long entry:entries) {
                Function f=getFunctionAt(toAddr(entry));
                if(f==null) f=getFunctionContaining(toAddr(entry));
                if(f==null) {
                    disassemble(toAddr(entry)); f=createFunction(toAddr(entry),null);
                }
                if(f!=null)functions.add(f);
                ReferenceIterator ri=currentProgram.getReferenceManager().getReferencesTo(toAddr(entry));
                while(ri.hasNext()) {
                    Reference r=ri.next(); Function caller=getFunctionContaining(r.getFromAddress());
                    refs.println(toAddr(entry)+"\t"+r.getFromAddress()+"\t"+(caller==null?"":caller.getEntryPoint())+"\t"+r.getReferenceType());
                }
            }
        }
        // Every aligned literal in initialized memory; absence of refs is not proof of unused RAM.
        try(PrintWriter out=writer(new File(dir,"ram_boundary_literals.tsv"))) {
            out.println("location\tvalue\tref_from\tfunction\tinstruction");
            Memory mem=currentProgram.getMemory();
            for(MemoryBlock block:mem.getBlocks()) {
                if(!block.isInitialized())continue;
                long start=block.getStart().getOffset(),end=block.getEnd().getOffset();
                for(long p=(start+3)&~3L;p+3<=end;p+=4) {
                    long value=Integer.toUnsignedLong(mem.getInt(toAddr(p)));
                    if(!((value>=0x3e140L&&value<=0x3e200L)||(value>=0x4a7c0L&&value<=0x50000L)))continue;
                    Address literal=toAddr(p); boolean found=false;
                    ReferenceIterator ri=currentProgram.getReferenceManager().getReferencesTo(literal);
                    while(ri.hasNext()) {
                        Reference r=ri.next(); Function f=getFunctionContaining(r.getFromAddress());
                        Instruction i=getInstructionAt(r.getFromAddress());
                        out.println(literal+"\t"+String.format("0x%08x",value)+"\t"+r.getFromAddress()+"\t"+(f==null?"":f.getEntryPoint())+"\t"+(i==null?"":i));
                        found=true;
                    }
                    if(!found)out.println(literal+"\t"+String.format("0x%08x",value)+"\t\t\t");
                }
            }
        }
        DecompInterface dc=new DecompInterface();dc.openProgram(currentProgram);
        try(PrintWriter code=writer(new File(dir,"scan_integration.c"));
            PrintWriter asm=writer(new File(dir,"scan_integration.asm"))) {
            for(Function f:functions) {
                code.println("\n/* Address: "+f.getEntryPoint()+" */");
                DecompileResults r=dc.decompileFunction(f,40,monitor);
                if(r.decompileCompleted())code.println(r.getDecompiledFunction().getC());
                else code.println("/* DECOMPILATION FAILED: "+r.getErrorMessage()+" */");
                asm.println("\n; "+f.getEntryPoint()+" "+f.getName());
                InstructionIterator ii=currentProgram.getListing().getInstructions(f.getBody(),true);
                while(ii.hasNext()) {
                    Instruction i=ii.next(); StringBuilder bytes=new StringBuilder();
                    for(byte b:i.getBytes())bytes.append(String.format("%02x ",b&255));
                    asm.println(i.getAddress()+"  "+bytes+" "+i);
                }
            }
        }
        dc.dispose();println("SCAN_INTEGRATION_EXPORT functions="+functions.size());
    }
    private PrintWriter writer(File f)throws Exception {
        return new PrintWriter(new OutputStreamWriter(new FileOutputStream(f),StandardCharsets.UTF_8));
    }
}
