module rcld.node;

import rcld.c.rcl;
import rcld.context;
import std.exception;
import std.string;

class Node {
    this(in string node_name, in string node_namespace) {
        node_handle_ = rcl_get_zero_initialized_node();
        auto node_options = rcl_node_get_default_options();
        scope (exit) {
            rcl_node_options_fini(&node_options);
        }

        auto cxt = Global.instance().getDefaultContext();

        enforce(rcl_node_init(&node_handle_, node_name.toStringz,
                node_namespace.toStringz, &cxt.context_, &node_options) == 0);
    }

    ~this() {
        terminate();
    }

    void terminate() {
        if (rcl_node_is_valid(&node_handle_)) {
            rcl_node_fini(&node_handle_);
        }
    }

package:
    rcl_node_t node_handle_;
}

unittest {
    import rcld : init, shutdown;
    import std.process : executeShell;
    import std.algorithm : canFind;

    init();
    auto node = new Node("hoge", "fuga");

    auto nodes = executeShell("ros2 node list");

    node.terminate();
    shutdown();

    assert(nodes.output.split('\n').canFind("/fuga/hoge"));
}
