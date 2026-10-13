// Export the existing program database without analysis or edits.
import ghidra.app.script.GhidraScript;
import ghidra.app.util.exporter.GzfExporter;
import ghidra.program.model.listing.*;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.util.HexFormat;

public class ExportNrfArchive extends GhidraScript {
    public void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length != 2) throw new IllegalArgumentException("<archive.gzf or inspect> <inventory.tsv>");
        StringBuilder out = new StringBuilder();
        out.append("language\t").append(currentProgram.getLanguageID()).append("\n");
        out.append("image_base\t").append(currentProgram.getImageBase()).append("\n");
        out.append("functions\t").append(currentProgram.getFunctionManager().getFunctionCount()).append("\n");
        out.append("data_types\t").append(currentProgram.getDataTypeManager().getDataTypeCount(true)).append("\n");
        for (MemoryBlock block : currentProgram.getMemory().getBlocks()) {
            out.append("block\t").append(block.getName()).append("\t").append(block.getStart()).append("\t").append(block.getSize());
            if (block.isInitialized()) {
                byte[] bytes = new byte[(int)block.getSize()];
                currentProgram.getMemory().getBytes(block.getStart(), bytes);
                out.append("\t").append(HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes)));
            }
            out.append("\n");
        }
        FunctionIterator functions = currentProgram.getFunctionManager().getFunctions(true);
        while (functions.hasNext()) {
            Function f = functions.next();
            out.append("function\t").append(f.getEntryPoint()).append("\t").append(f.getName()).append("\t")
                .append(f.getSymbol().getSource()).append("\t").append(f.getBody()).append("\t")
                .append(f.getSignature()).append("\n");
        }
        SymbolIterator symbols = currentProgram.getSymbolTable().getAllSymbols(true);
        while (symbols.hasNext()) {
            Symbol s = symbols.next();
            if (s.getSource() == SourceType.USER_DEFINED)
                out.append("user_symbol\t").append(s.getAddress()).append("\t").append(s.getName(true)).append("\n");
        }
        for (int kind = 0; kind <= 4; kind++) {
            var addresses = currentProgram.getListing().getCommentAddressIterator(kind, currentProgram.getMemory(), true);
            while (addresses.hasNext()) {
                var address = addresses.next();
                out.append("comment\t").append(kind).append("\t").append(address).append("\t")
                    .append(currentProgram.getListing().getComment(kind, address).replace("\n", "\\n").replace("\r", "\\r")).append("\n");
            }
        }
        Files.writeString(new File(args[1]).toPath(), out, StandardCharsets.UTF_8);
        if (!args[0].equals("inspect")) {
            File archive = new File(args[0]);
            if (archive.exists()) throw new IllegalArgumentException("Refusing to overwrite archive");
            if (!new GzfExporter().export(archive, currentProgram.getDomainFile(), monitor))
                throw new IllegalStateException("GZF export failed");
            println("EXPORTED " + archive.getName() + " bytes=" + archive.length());
        }
        println("INVENTORY functions=" + currentProgram.getFunctionManager().getFunctionCount());
    }
}
