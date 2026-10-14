// dm32re: decompile functions of the (read-only) DM32 program and write one JSON object per line:
// {"addr": "0301ec40", "name": "...", "temp": false, "c": "..."}
// Args: <output.jsonl> all | <hex addr>...   Run with -process -noanalysis -readOnly so nothing is saved.
// A function Ghidra does not have is created temporarily (temp=true), as in DecompAt.java.
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;

import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class Dm32DecompJson extends GhidraScript {
    private static String quote(String s) {
        StringBuilder b = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': break;
                case '\t': b.append("\\t"); break;
                default:
                    if (c < 0x20) b.append(String.format("\\u%04x", (int) c)); else b.append(c);
            }
        }
        return b.append('"').toString();
    }

    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        List<Function> todo = new ArrayList<>();
        List<Boolean> temp = new ArrayList<>();
        if (args.length > 1 && args[1].equals("all")) {
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            while (it.hasNext()) { todo.add(it.next()); temp.add(false); }
        } else {
            for (int i = 1; i < args.length; i++) {
                Address a = toAddr(Long.parseLong(args[i], 16));
                Function f = getFunctionAt(a);
                boolean t = false;
                if (f == null) { disassemble(a); f = createFunction(a, null); t = true; }
                if (f != null) { todo.add(f); temp.add(t); }
            }
        }
        DecompInterface ifc = new DecompInterface();
        ifc.openProgram(currentProgram);
        try (PrintWriter w = new PrintWriter(new OutputStreamWriter(new FileOutputStream(args[0]), StandardCharsets.UTF_8))) {
            for (int i = 0; i < todo.size() && !monitor.isCancelled(); i++) {
                Function f = todo.get(i);
                DecompileResults r = ifc.decompileFunction(f, 60, monitor);
                String c = (r != null && r.decompileCompleted() && r.getDecompiledFunction() != null)
                        ? r.getDecompiledFunction().getC() : "/* decompile failed: " + (r == null ? "null" : r.getErrorMessage()) + " */";
                w.println("{\"addr\": \"" + String.format("%08x", f.getEntryPoint().getOffset()) + "\", \"name\": "
                        + quote(f.getName()) + ", \"temp\": " + temp.get(i) + ", \"c\": " + quote(c) + "}");
            }
        } finally {
            ifc.dispose();
        }
    }
}
