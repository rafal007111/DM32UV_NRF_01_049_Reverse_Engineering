import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import java.io.*;
public class RecoverPickerEntry extends GhidraScript {
 public void run() throws Exception {
  disassemble(toAddr(0x0303a748L));
  Function f=getFunctionAt(toAddr(0x0303a748L));if(f==null) f=createFunction(toAddr(0x0303a748L),"stock_menu_confirm");
  DecompInterface dc=new DecompInterface();dc.openProgram(currentProgram);
  try(PrintWriter out=new PrintWriter(getScriptArgs()[0])) {
   DecompileResults result=dc.decompileFunction(f,45,monitor);
   if(!result.decompileCompleted())throw new Exception(result.getErrorMessage());
   out.println(result.getDecompiledFunction().getC());
  }
  dc.dispose();
 }
}
