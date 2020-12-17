module rcld.executor;

import rcl_bind;
import rcld.context;
import rcld.node;
import rcld.subscription;
import std.stdio;
import std.exception;
import std.algorithm;
import core.time;

class Executor {
    this(Context context = null) {
        wait_set_handle_ = rcl_get_zero_initialized_wait_set();
        auto cxt = context ? context : Global.instance().getDefaultContext();
        enforce(rcl_wait_set_init(&wait_set_handle_, 0, 0, 0, 0, 0, 0,
                &cxt.context_, rcutils_get_default_allocator()) == 0);
    }

    void terminate() {
        if (wait_set_handle_.impl) {
            rcl_wait_set_fini(&wait_set_handle_);
        }
    }

    ~this() {
        terminate();
    }

    void addNode(Node node) {
        assert(node);
        enforce(!nodes_.canFind(node));
        nodes_ ~= node;
    }

    void removeNode(Node node) {
        assert(node);
        enforce(nodes_.canFind(node));
        nodes_ = nodes_.remove!(x => nodes_.canFind(x));
    }

    void spinOnce(Duration timeout = -1.hnsecs) {
        enforce(rcl_wait_set_clear(&wait_set_handle_) == 0);

        auto sub_num = reduce!((a, b) => a + cast(int) b.subscriptions_.length)(0, nodes_);
        BaseSubscription[] subscriptions;

        enforce(rcl_wait_set_resize(&wait_set_handle_, sub_num, 0, 0, 0, 0, 0) == 0);

        foreach (node; nodes_) {
            foreach (sub; node.subscriptions_) {
                subscriptions ~= sub;
                enforce(rcl_wait_set_add_subscription(&wait_set_handle_, sub.handle, null) == 0);
            }
        }
        enforce(rcl_wait(&wait_set_handle_, timeout.total!"nsecs") == 0);

        foreach (i; 0 .. sub_num) {
            if (wait_set_handle_.subscriptions[i]) {
                auto sub = subscriptions[i];
                auto msg = sub.createMessage();
                auto message_info = rmw_message_info_t();
                message_info.from_intra_process = false;

                enforce(rcl_take(sub.handle, msg, &message_info, null) == 0);

                sub.callbackFunc(msg);

                sub.returnMessage(msg);
            }
        }
    }

    rcl_wait_set_t wait_set_handle_;
    Node[] nodes_;
}
