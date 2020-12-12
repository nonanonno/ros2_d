module rcld.subscription;

import rcld.node;
import rcl_bind;
import std.string;
import std.exception;

interface BaseSubscription {
    void terminate(Node node);
    rcl_subscription_t* handle() nothrow;
    void* createMessage() nothrow;
    void returnMessage(ref void* msg) nothrow;
    void callbackFunc(void* msg);
}

class Subscription(T) : BaseSubscription {
    alias CMessageType = T.CMessageType;

    this(Node node, in string topic_name) {
        sub_handle_ = rcl_get_zero_initialized_subscription();
        auto sub_options = rcl_subscription_get_default_options();
        auto typesupport = T.getTypesupport();
        enforce(rcl_subscription_init(&sub_handle_, &node.node_handle_,
                typesupport, topic_name.toStringz, &sub_options) == 0);
        node.subscriptions_ ~= this;
    }

    override void terminate(Node node) {
        if (!sub_handle_.impl) {
            return;
        }
        enforce(rcl_subscription_fini(&sub_handle_, &node.node_handle_) == 0);
        sub_handle_.impl = null;
    }

    override rcl_subscription_t* handle() nothrow {
        return &sub_handle_;
    }

    override void* createMessage() nothrow {
        return cast(void*) T.createCMessage();
    }

    override void returnMessage(ref void* msg) nothrow {
        T.destroyCMessage(*cast(CMessageType**)&msg);
    }

    override void callbackFunc(in void* in_msg) {
        auto c_msg = cast(CMessageType*) in_msg;
        auto msg = T();
        T.convert(*c_msg, msg);
        if (callback_) {
            callback_(msg);
        }
    }

    rcl_subscription_t sub_handle_;
    void delegate(in T msg) callback_;
}
