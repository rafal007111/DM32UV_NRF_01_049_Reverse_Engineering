import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.*;
import ghidra.program.model.listing.*;
import ghidra.program.model.symbol.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;

public class ExportDM32 extends GhidraScript {
    public void run() throws Exception {
        File root = new File(getScriptArgs()[0], currentProgram.getName());
        root.mkdirs();
        String[][] labels = {
            {"00423510", "candidate_firmware_open_handler"},
            {"004236b0", "candidate_firmware_upgrade_handler"},
            {"00423a40", "candidate_firmware_thread_callback"},
            {"00423a60", "candidate_firmware_upgrade_worker"},
            {"0048f570", "candidate_serial_write_wrapper"},
            {"0048f630", "candidate_serial_read_wrapper"}
        };
        if (currentProgram.getName().equals("DMR CPS.exe")) {
            for (String[] pair : labels) {
                Function f = getFunctionAt(toAddr(pair[0]));
                if (f != null) f.setName(pair[1], SourceType.USER_DEFINED);
            }
        }
        DecompInterface decomp = new DecompInterface();
        decomp.openProgram(currentProgram);
        int good = 0, failed = 0;
        try (PrintWriter code = writer(new File(root,"decompiled.c"));
             PrintWriter index = writer(new File(root,"functions.tsv"));
             PrintWriter calls = writer(new File(root,"calls.tsv"));
             PrintWriter assembly = writer(new File(root,"disassembly.asm"))) {
            code.println("/* Ghidra recovered pseudocode, not original source. Types/names may be inferred. */");
            index.println("address\tname\tbody_bytes\tstatus");
            calls.println("caller\tcallsite\ttarget\ttarget_symbol");
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            while (it.hasNext() && !monitor.isCancelled()) {
                Function f = it.next();
                DecompileResults result = decomp.decompileFunction(f, 45, monitor);
                String status = result.decompileCompleted() && result.getDecompiledFunction()!=null ? "ok" : "failed";
                String recovered = status.equals("ok") ? result.getDecompiledFunction().getC() : "";
                if (recovered.contains("WARNING:")) status="warning";
                index.println(f.getEntryPoint()+"\t"+f.getName()+"\t"+f.getBody().getNumAddresses()+"\t"+status);
                code.println("\n/* Address: "+f.getEntryPoint()+"; name: "+f.getName()+" */");
                if (!status.equals("failed")) { code.println(recovered); good++; }
                else { code.println("/* Failed: "+result.getErrorMessage()+" */"); failed++; }
                InstructionIterator instructions = currentProgram.getListing().getInstructions(f.getBody(),true);
                assembly.println("\n; "+f.getName()+" @ "+f.getEntryPoint());
                while (instructions.hasNext()) {
                    Instruction ins = instructions.next();
                    assembly.println(ins.getAddress()+"  "+ins.toString());
                    for (Reference ref : ins.getReferencesFrom()) {
                        if (ref.getReferenceType().isCall()) {
                            Symbol s = currentProgram.getSymbolTable().getPrimarySymbol(ref.getToAddress());
                            calls.println(f.getEntryPoint()+"\t"+ins.getAddress()+"\t"+ref.getToAddress()+"\t"+(s==null?"":s.getName()));
                        }
                    }
                }
            }
        }
        try (PrintWriter strings = writer(new File(root,"strings.tsv"))) {
            strings.println("address\tvalue\txrefs");
            DataIterator data = currentProgram.getListing().getDefinedData(true);
            while(data.hasNext()) {
                Data d = data.next(); Object value=d.getValue();
                if(value instanceof String) {
                    StringBuilder refs = new StringBuilder();
                    ReferenceIterator ri = currentProgram.getReferenceManager().getReferencesTo(d.getAddress());
                    while(ri.hasNext()) refs.append(ri.next().getFromAddress()).append(',');
                    strings.println(d.getAddress()+"\t"+value.toString().replace("\n","\\n").replace("\r","\\r").replace("\t","\\t")+"\t"+refs);
                }
            }
        }
        decomp.dispose();
        println("EXPORT_COMPLETE "+currentProgram.getName()+" ok="+good+" failed="+failed);
    }
    private PrintWriter writer(File f) throws IOException {
        return new PrintWriter(new OutputStreamWriter(new FileOutputStream(f), StandardCharsets.UTF_8));
    }
}
