module rcld.context;

import rcld.c.rcl;
import core.runtime;
import std.exception;
import rcld.utils;

class Context {
    this(in CArgs args) {
        auto options = rcl_get_zero_initialized_init_options();
        allocator_ = rcutils_get_default_allocator();
        enforce(rcl_init_options_init(&options, allocator_) == 0);
        scope (exit) {
            rcl_init_options_fini(&options);
        }
        context_ = rcl_context_t();
        enforce(rcl_init(args.argc, args.argv, &options, &context_) == 0);
    }

    void shutdown() {
        if (context_ != rcl_context_t()) {
            rcl_shutdown(&context_);
        }
    }

    ~this() {
        shutdown();
    }

package:
    rcutils_allocator_t allocator_;
    rcl_context_t context_;
}

class Global {
    mixin singleton;
private:
    this() {
    }

public:
    Context getDefaultContext() {
        assert(context_);
        return context_;
    }

    void initDefaultContext(in CArgs args) {
        context_ = new Context(args);
    }

private:
    Context context_;
}
