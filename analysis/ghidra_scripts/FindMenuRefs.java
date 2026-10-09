import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.address.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
public class FindMenuRefs extends GhidraScript {
    public void run() throws Exception {
        File dir=new File(getScriptArgs()[0]);dir.mkdirs();
        long[] roots={0x030b90a8L,0x030b9700L,0x030bd62cL,0x030bd638L,0x030be18cL,0x030be198L};
        Set<Function> functions=new LinkedHashSet<>();
        try(PrintWriter out=writer(new File(dir,"menu_reference_paths.tsv"))){
            out.println("root\tfrom\tfunction\ttype");
            for(long root:roots){
                ArrayDeque<Address> queue=new ArrayDeque<>();Set<Address> visited=new HashSet<>();
                queue.add(toAddr(root));
                for(int depth=0;depth<3;depth++){
                    int count=queue.size();
                    for(int n=0;n<count;n++){
                        Address target=queue.removeFirst();if(!visited.add(target))continue;
                        ReferenceIterator refs=currentProgram.getReferenceManager().getReferencesTo(target);
                        while(refs.hasNext()){
                            Reference ref=refs.next();Address from=ref.getFromAddress();
                            Function f=getFunctionContaining(from);
                            out.println(toAddr(root)+"\t"+from+"\t"+(f==null?"":f.getEntryPoint())+"\t"+ref.getReferenceType());
                            if(f!=null)functions.add(f);else queue.add(from);
                        }
                    }
                }
            }
        }
        DecompInterface dc=new DecompInterface();dc.openProgram(currentProgram);
        try(PrintWriter out=writer(new File(dir,"menu_table_users.c"))){
            for(Function f:functions){
                out.println("\n/* Address: "+f.getEntryPoint()+"; "+f.getName()+" */");
                DecompileResults r=dc.decompileFunction(f,60,monitor);
                if(r.decompileCompleted())out.println(r.getDecompiledFunction().getC());
            }
        }
        dc.dispose();println("MENU_USERS "+functions.size());
    }
    private PrintWriter writer(File f)throws Exception{return new PrintWriter(new OutputStreamWriter(new FileOutputStream(f),StandardCharsets.UTF_8));}
}
