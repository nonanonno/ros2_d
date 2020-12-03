module rcld.publisher;

import rcld.node;
import rcl_bind;
import std.string;
import std.exception;

interface BasePublisher {
    void terminate(Node node);
}

class Publisher(T) : BasePublisher {
    this(Node node, in string topic_name) {
        pub_handle_ = rcl_get_zero_initialized_publisher();
        auto pub_options = rcl_publisher_get_default_options();
        auto typesupport = T.getTypesupport();
        enforce(rcl_publisher_init(&pub_handle_, &node.node_handle_,
                typesupport, topic_name.toStringz, &pub_options) == 0);
        node.publishers_ ~= this;
    }

    override void terminate(Node node) {
        if (!pub_handle_.impl) {
            return;
        }
        enforce(rcl_publisher_fini(&pub_handle_, &node.node_handle_) == 0);
        // workaround: The function rcl_publisher_fini does not assign null pointer to `impl`.
        pub_handle_.impl = null;
    }

    void publish(in T msg) {
        auto c_msg = T.createCMessage();
        assert(c_msg);
        T.convert(msg, *c_msg);
        enforce(rcl_publish(&pub_handle_, cast(const(void)*) c_msg, null) == 0);
        T.destroyCMessage(c_msg);
    }

    rcl_publisher_t pub_handle_;
}
