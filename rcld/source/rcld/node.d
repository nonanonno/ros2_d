module rcld.node;

import rcl_bind;
import rcld.context;
import std.exception;
import std.string;
import rcld.publisher;
import rcld.subscription;

class Node {
    this(in string node_name, in string node_namespace, Context context = null) {
        node_handle_ = rcl_get_zero_initialized_node();
        auto node_options = rcl_node_get_default_options();
        scope (exit) {
            rcl_node_options_fini(&node_options);
        }

        auto cxt = context ? context : Global.instance().getDefaultContext();

        enforce(rcl_node_init(&node_handle_, node_name.toStringz,
                node_namespace.toStringz, &cxt.context_, &node_options) == 0);
    }

    ~this() {
        terminate();
    }

    void terminate() {
        foreach (pub; publishers_) {
            pub.terminate(this);
        }
        foreach (sub; subscriptions_) {
            sub.terminate(this);
        }
        publishers_ = [];
        subscriptions_ = [];
        if (rcl_node_is_valid(&node_handle_)) {
            rcl_node_fini(&node_handle_);
        }
    }

package:
    rcl_node_t node_handle_;
    BasePublisher[] publishers_;
    BaseSubscription[] subscriptions_;
}

unittest {
    import rcld : init, shutdown;
    import std.process : executeShell;
    import std.algorithm : canFind;

    auto cxt = new Context();
    auto node = new Node("test_node", "rcld", cxt);

    auto nodes = executeShell("ros2 node list");

    node.terminate();
    cxt.shutdown();

    assert(nodes.output.split('\n').canFind("/rcld/test_node"));
}
