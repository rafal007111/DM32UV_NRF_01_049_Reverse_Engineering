import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import java.io.*;
public class ReviewPickerConfirm extends GhidraScript {
 public void run() throws Exception {
  long[] calls={0x0303a774L,0x0303a8f0L};
  try(PrintWriter out=new PrintWriter(getScriptArgs()[0])) {
   for(long call:calls) {
    out.println("\nCALL "+toAddr(call));
    Address a=toAddr(call-96),end=toAddr(call+16);
    clearListing(a,end);
    while(a.compareTo(end)<0) {
     disassemble(a);Instruction ins=getInstructionAt(a);
     if(ins==null){a=a.add(2);continue;}
     out.print(a+"  "+ins);
     if(ins.getMnemonicString().equals("lrw")) for(Object obj:ins.getOpObjects(1)) if(obj instanceof Address) out.print("  literal="+Integer.toUnsignedString(currentProgram.getMemory().getInt((Address)obj),16));
     out.println();a=a.add(ins.getLength());
    }
   }
  }
 }
}
