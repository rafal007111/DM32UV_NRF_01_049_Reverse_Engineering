import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import java.io.*;
public class ReviewMissingMenuCalls extends GhidraScript {
 public void run() throws Exception {
  long[] calls={0x03036a9eL,0x03036b12L,0x03037156L,0x0303cc0cL,0x0303cc9eL,0x0303ce46L,0x0303d19aL,0x0303d8faL,0x0303d93aL,0x0303d9aaL,0x0303da14L,0x0303da62L,0x0303dac0L,0x0303db3aL,0x0303dbbeL,0x0303dc0cL,0x0303ddf0L};
  try(PrintWriter out=new PrintWriter(getScriptArgs()[0])) {
   for(long call:calls) {
    out.println("\nCALL "+toAddr(call));
    Address a=toAddr(call-32),end=toAddr(call+4);
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
