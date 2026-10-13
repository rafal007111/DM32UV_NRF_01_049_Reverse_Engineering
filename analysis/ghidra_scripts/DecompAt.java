import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
public class DecompAt extends GhidraScript { public void run() throws Exception {
  DecompInterface d=new DecompInterface(); d.openProgram(currentProgram);
  for(String s:getScriptArgs()){ var a=toAddr(Long.parseLong(s,16)); Function f=getFunctionAt(a);
    if(f==null){ disassemble(a); f=createFunction(a,null); }
    println("==== "+s+" callers="+f.getCallingFunctions(monitor));
    println(d.decompileFunction(f,60,monitor).getDecompiledFunction().getC()); } } }
