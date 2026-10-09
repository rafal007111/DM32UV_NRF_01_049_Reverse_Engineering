import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import ghidra.program.model.pcode.JumpTable;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/** Analysis annotations only; run on the firmware project in read-only mode. */
public class RecoverMenuFlow extends GhidraScript {
    public void run() throws Exception {
        File dir=new File(getScriptArgs()[0]);dir.mkdirs();
        long[][] switches={
            {0x03038548L,0x030b0c8cL,50},
            {0x030385b0L,0x030b0d54L,10},
            {0x0303b6f0L,0x030b0d7cL,53},
            {0x03048f66L,0x030b1e38L,109}
        };
        try(PrintWriter out=writer(new File(dir,"recovered_switches.tsv"))) {
            out.println("jump\tindex\ttarget");
            for(long[] sw:switches) {
                Instruction jump=getInstructionAt(toAddr(sw[0]));
                if(jump==null||!jump.getFlowType().isJump())throw new Exception("Not a jump at "+toAddr(sw[0]));
                for(int i=0;i<sw[2];i++) {
                    long dest=Integer.toUnsignedLong(currentProgram.getMemory().getInt(toAddr(sw[1]+4*i)))&~1L;
                    if(dest<0x0300c000L||dest>=0x030727d0L)throw new Exception("Invalid UI target");
                    currentProgram.getReferenceManager().addMemoryReference(toAddr(sw[0]),toAddr(dest),RefType.COMPUTED_JUMP,SourceType.USER_DEFINED,0);
                    out.println(toAddr(sw[0])+"\t"+i+"\t"+toAddr(dest));
                }
            }
        }
        long[][] roots={{0x03038500L,0x03038f5cL},{0x0303b6acL,0x0303c850L},{0x03048f50L,0x030493f8L}};
        DecompInterface dc=new DecompInterface();dc.openProgram(currentProgram);
        try(PrintWriter out=writer(new File(dir,"menu_control.c"))) {
            for(long[] range:roots) {
                Function f=getFunctionAt(toAddr(range[0]));
                AddressSet body=new AddressSet();
                Set<Address> visited=new HashSet<>();ArrayDeque<Address> queue=new ArrayDeque<>();
                queue.add(toAddr(range[0]));
                while(!queue.isEmpty()) {
                    Address a=queue.removeFirst();long off=a.getOffset();
                    if(off<range[0]||off>=range[1]||!visited.add(a))continue;
                    Instruction ins=getInstructionAt(a);
                    if(ins==null){disassemble(a);ins=getInstructionAt(a);}
                    if(ins==null)continue;
                    body.add(ins.getMinAddress(),ins.getMaxAddress());
                    Address next=ins.getFallThrough();if(next!=null)queue.add(next);
                    if(!ins.getFlowType().isCall())for(Address target:ins.getFlows())queue.add(target);
                }
                body.add(f.getBody());
                f.setBody(body);
                for(long[] sw:switches) {
                    if(!body.contains(toAddr(sw[0])))continue;
                    ArrayList<Address> destinations=new ArrayList<>();
                    for(int i=0;i<sw[2];i++) {
                        long target=Integer.toUnsignedLong(currentProgram.getMemory().getInt(toAddr(sw[1]+4*i)))&~1L;
                        destinations.add(toAddr(target));
                    }
                    new JumpTable(toAddr(sw[0]),destinations,true,0).writeOverride(f);
                }
                dc.flushCache();
                out.println("\n/* Address: "+f.getEntryPoint()+"; expanded instructions="+visited.size()+" */");
                DecompileResults result=dc.decompileFunction(f,45,monitor);
                if(result.decompileCompleted())out.println(result.getDecompiledFunction().getC());
                else out.println("/* FAILED: "+result.getErrorMessage()+" */");
                println("UI_FLOW "+f.getEntryPoint()+" body="+body.getNumAddresses());
            }
        }
        dc.dispose();
    }
    private PrintWriter writer(File f)throws Exception{return new PrintWriter(new OutputStreamWriter(new FileOutputStream(f),StandardCharsets.UTF_8));}
}
