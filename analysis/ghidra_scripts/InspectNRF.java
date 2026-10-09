import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import ghidra.program.model.address.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
public class InspectNRF extends GhidraScript {
    public void run() throws Exception {
        File dir=new File(getScriptArgs()[0]); dir.mkdirs();
        long[] addresses={0x03012c40L,0x03050cf0L,0x0301c644L,0x0301cbe4L,
            0x030221a4L,0x03023418L,0x03049c90L,0x0304a60cL,0x030419c4L,0x0303e200L,
            0x0304107cL,0x03041970L,0x0300b4e0L,0x03052134L,0x03025fd4L,
            0x030179d4L,0x03017eb8L,0x03018120L,0x030177b8L,0x03051a8cL};
        long delta=currentProgram.getMemory().getBlock("FLASH_LCSFC").getStart().getOffset()-0x03000000L;
        for(int index=0;index<addresses.length;index++)addresses[index]+=delta;
        DecompInterface dc=new DecompInterface();dc.openProgram(currentProgram);
        try(PrintWriter code=writer(new File(dir,"target_functions_corrected.c"));
            PrintWriter asm=writer(new File(dir,"target_functions.asm"));
            PrintWriter refs=writer(new File(dir,"target_callers.tsv"))) {
            refs.println("target\tcaller\tcallsite");
            for(long value:addresses){
                Address a=toAddr(value);Function f=getFunctionAt(a);
                if(f==null){code.println("/* Missing function "+a+" */");continue;}
                code.println("\n/* Address: "+a+"; "+f.getName()+" */");
                DecompileResults r=dc.decompileFunction(f,60,monitor);
                if(r.decompileCompleted())code.println(r.getDecompiledFunction().getC());
                InstructionIterator ii=currentProgram.getListing().getInstructions(f.getBody(),true);
                asm.println("\n; "+f.getName()+" @ "+a);
                while(ii.hasNext()){
                    Instruction i=ii.next();StringBuilder bytes=new StringBuilder();
                    for(byte b:i.getBytes())bytes.append(String.format("%02x ",b&255));
                    asm.println(i.getAddress()+"  "+bytes+" "+i);
                }
                ReferenceIterator ri=currentProgram.getReferenceManager().getReferencesTo(a);
                while(ri.hasNext()){
                    Reference ref=ri.next();if(!ref.getReferenceType().isCall())continue;
                    Function from=getFunctionContaining(ref.getFromAddress());
                    refs.println(a+"\t"+(from==null?"":from.getEntryPoint())+"\t"+ref.getFromAddress());
                }
            }
        }
        dc.dispose();println("TARGET_EXPORT_COMPLETE");
    }
    private PrintWriter writer(File f)throws Exception{return new PrintWriter(new OutputStreamWriter(new FileOutputStream(f),StandardCharsets.UTF_8));}
}
