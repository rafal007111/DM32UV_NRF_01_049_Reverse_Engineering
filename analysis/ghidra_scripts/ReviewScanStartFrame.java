import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import java.io.*;
import java.util.*;

/** Instruction/frame check only, in a discarded read-only program session. */
public class ReviewScanStartFrame extends GhidraScript {
    public void run() throws Exception {
        Address probe=toAddr(0x030e13ecL);
        byte[] shim={(byte)0xd3,0x14,0x2d,0x14,0x03,0x6d,0x62,0x10,0x0c,0x78,0,0,(byte)0x98,(byte)0xf4,0x02,0x03};
        byte[] original=new byte[6];currentProgram.getMemory().getBytes(toAddr(0x0302f418L),original);
        if(!Arrays.equals(original,Arrays.copyOf(shim,6)))throw new Exception("Stock prologue mismatch");
        byte[] zeros=new byte[16];currentProgram.getMemory().getBytes(probe,zeros);
        if(!Arrays.equals(zeros,new byte[16]))throw new Exception("Probe region not empty");
        clearListing(probe,probe.add(15));currentProgram.getMemory().setBytes(probe,shim);disassemble(probe);
        try(PrintWriter out=new PrintWriter(getScriptArgs()[0],"UTF-8")) {
            out.println("temporary_probe\tinstruction\tstock_match");
            for(int offset:new int[]{0,2,4,6,8}) {
                Instruction ins=getInstructionAt(probe.add(offset));
                if(ins==null||ins.getLength()!=2)throw new Exception("Bad instruction at "+probe.add(offset));
                String match="not applicable";
                if(offset<6) {
                    Instruction stock=getInstructionAt(toAddr(0x0302f418L+offset));
                    if(stock==null||!stock.toString().equals(ins.toString()))throw new Exception("Different frame instruction");
                    match="identical to stock";
                }
                out.println(ins.getAddress()+"\t"+ins+"\t"+match);
            }
            Instruction load=getInstructionAt(probe.add(6));
            boolean correct=load.toString().equals("lrw r3,0x"+Long.toHexString(probe.add(12).getOffset()));
            if(!correct||currentProgram.getMemory().getInt(probe.add(12))!=0x0302f498)throw new Exception("Wrong continuation load");
            if(!getInstructionAt(probe.add(8)).toString().equals("jmp r3"))throw new Exception("Wrong jump register");
            Instruction cleanup=getInstructionAt(toAddr(0x0302f57eL));
            Instruction ret=getInstructionAt(toAddr(0x0302f580L));
            out.println("stock_exit\t"+cleanup+"; "+ret+"\t52-byte scratch plus r4/r5/r6/lr");
            out.println("continuation\t0302f498\tpost-validation path; runtime behavior untested");
        }
        println("SCAN_START_FRAME_PASS; candidate only; temporary bytes discarded");
    }
}
