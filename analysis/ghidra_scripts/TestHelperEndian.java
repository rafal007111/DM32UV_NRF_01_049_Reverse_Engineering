import ghidra.app.script.GhidraScript;
import ghidra.app.emulator.EmulatorHelper;
import ghidra.program.model.address.Address;
import java.io.PrintWriter;
public class TestHelperEndian extends GhidraScript {
    public void run() throws Exception {
        Address probe=toAddr(0x10ee0);
        clearListing(probe,probe.add(3));
        currentProgram.getMemory().setBytes(probe,new byte[]{0x56,0x79,0x57,0x79});
        disassemble(probe);
        long[] inputs={0,0x12345678L,0x00fff000L,0x80ff017eL,0xffffffffL,0x03001802L};
        try(PrintWriter out=new PrintWriter(getScriptArgs()[0],"UTF-8")) {
            out.println("instruction\tinput\tresult\texpected\tstatus");
            for(int kind=0;kind<2;kind++)for(long input:inputs) {
                EmulatorHelper emu=new EmulatorHelper(currentProgram);
                try {
                    emu.writeRegister("r5",input);
                    emu.writeRegister(currentProgram.getLanguage().getProgramCounter(),probe.add(2*kind).getOffset());
                    if(!emu.step(monitor))throw new Exception(emu.getLastError());
                    long got=emu.readRegister("r5").longValue()&0xffffffffL;
                    long expected=kind==0 ? Integer.toUnsignedLong(Integer.reverseBytes((int)input)) :
                        ((input&0x00ff00ffL)<<8)|((input&0xff00ff00L)>>>8);
                    if(got!=expected)throw new Exception("Incorrect in-place endian instruction");
                    out.printf("%s\t%08x\t%08x\t%08x\tPASS%n",kind==0?"revb r5,r5":"revh r5,r5",input,got,expected);
                } finally { emu.dispose(); }
            }
        }
        println("HELPER_ENDIAN_EMULATION_PASS 12; analysis only, no physical CPU/flash operations");
    }
}
