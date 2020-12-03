module rcld;

public import rcld.context, rcld.node, rcld.publisher;
import core.runtime;

void init(in CArgs args = Runtime.cArgs) {
    Global.instance.initDefaultContext(args);
}

void shutdown() {
    Global.instance.getDefaultContext().shutdown();
}
