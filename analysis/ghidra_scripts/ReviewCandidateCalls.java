import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import java.nio.file.*;
import java.io.*;
import java.util.*;

/** Apply review bytes only to a read-only Ghidra session; never exports a firmware image. */
public class ReviewCandidateCalls extends GhidraScript {
    private byte[] hex(String text) {
        byte[] out=new byte[text.length()/2];
        for(int i=0;i<out.length;i++)out[i]=(byte)Integer.parseInt(text.substring(2*i,2*i+2),16);
        return out;
    }
    private long decodedTarget(long va,byte[] data) {
        long high=(data[0]&255)|((data[1]&255)<<8), low=(data[2]&255)|((data[3]&255)<<8);
        long half=((high&1023)<<16)|low;
        if((half&(1L<<25))!=0)half-=1L<<26;
        return va+2*half;
    }
    public void run() throws Exception {
        String[] args=getScriptArgs();
        List<String> patches=Files.readAllLines(Paths.get(args[0]));
        ArrayList<Address> calls=new ArrayList<>();ArrayList<Long> expected=new ArrayList<>();
        // Verify all guards before any mutation of the temporary program.
        for(String line:patches) {
            String[] p=line.split("\t");Address a=toAddr(p[0]);byte[] before=hex(p[1]);
            byte[] actual=new byte[before.length];currentProgram.getMemory().getBytes(a,actual);
            if(!Arrays.equals(before,actual))throw new Exception("Guard mismatch at "+a);
        }
        for(String line:patches) {
            String[] p=line.split("\t");Address a=toAddr(p[0]);byte[] after=hex(p[2]);
            clearListing(a,a.add(after.length-1));
            currentProgram.getMemory().setBytes(a,after);
            if(after.length==4) {
                int high=(after[0]&255)|((after[1]&255)<<8);
                if((high&0xfc00)==0xe000) {
                    clearListing(a,a.add(3));calls.add(a);expected.add(decodedTarget(a.getOffset(),after));
                }
            }
        }
        for(String line:Files.readAllLines(Paths.get(args[1]))) {
            String[] p=line.split("\t");Address a=toAddr(p[0]);
            disassemble(a);if(getFunctionAt(a)==null)createFunction(a,p[1]);
        }
        try(PrintWriter out=new PrintWriter(args[2],"UTF-8")) {
            out.println("site\tdecoded_target\tghidra_flow\tfunction\tstatus");
            for(int n=0;n<calls.size();n++) {
                Address a=calls.get(n);disassemble(a);Instruction ins=getInstructionAt(a);
                if(ins==null||ins.getLength()!=4||!ins.getMnemonicString().equals("bsr"))throw new Exception("Not BSR32 at "+a);
                Address dest=toAddr(expected.get(n));boolean match=false;
                for(Address flow:ins.getFlows())if(flow.equals(dest))match=true;
                Function f=getFunctionAt(dest);
                if(!match||f==null)throw new Exception("Bad candidate target "+a+" -> "+dest);
                out.println(a+"\t"+dest+"\t"+Arrays.toString(ins.getFlows())+"\t"+f.getName()+"\tPASS");
            }
        }
        println("CANDIDATE_CALLS_PASS "+calls.size()+"; no image exported; discard temporary changes");
    }
}
