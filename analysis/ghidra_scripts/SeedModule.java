import ghidra.app.script.GhidraScript;
import java.nio.file.*;
public class SeedModule extends GhidraScript {
    public void run() throws Exception {
        for(String line:Files.readAllLines(Paths.get(getScriptArgs()[0]))) {
            String[] pair=line.split("\t");
            disassemble(toAddr(pair[0]));
            createFunction(toAddr(pair[0]),pair[1]);
        }
    }
}
