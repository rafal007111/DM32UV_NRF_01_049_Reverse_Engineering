import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.*;
import ghidra.program.model.data.*;
import ghidra.program.model.symbol.*;
public class FixCPS extends GhidraScript {
    public void run() throws Exception {
        for(long a:new long[]{0x48f570,0x48f630}) {
            Function f=getFunctionAt(toAddr(a));
            f.setCallingConvention("__thiscall");
            f.setReturnType(IntegerDataType.dataType,SourceType.USER_DEFINED);
            f.replaceParameters(Function.FunctionUpdateType.DYNAMIC_STORAGE_ALL_PARAMS,false,SourceType.USER_DEFINED,
                new ParameterImpl("buffer",new PointerDataType(VoidDataType.dataType),currentProgram),
                new ParameterImpl("count",IntegerDataType.dataType,currentProgram),
                new ParameterImpl("delay",IntegerDataType.dataType,currentProgram),
                new ParameterImpl("mode",IntegerDataType.dataType,currentProgram));
        }
        Function wait=getFunctionAt(toAddr(0x48f960));
        wait.setCallingConvention("__thiscall");
        wait.replaceParameters(Function.FunctionUpdateType.DYNAMIC_STORAGE_ALL_PARAMS,false,SourceType.USER_DEFINED,
            new ParameterImpl("delay_seconds",DoubleDataType.dataType,currentProgram));
        for(long a:new long[]{0x48f950,0x48f920,0x48f940,0x423a60}) {
            Function f=getFunctionAt(toAddr(a)); f.setCallingConvention("__thiscall");
            f.replaceParameters(Function.FunctionUpdateType.DYNAMIC_STORAGE_ALL_PARAMS,false,SourceType.USER_DEFINED);
        }
    }
}
