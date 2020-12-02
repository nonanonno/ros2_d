module rcld.utils;

mixin template singleton() {

    private static bool instantiated_;
    private __gshared typeof(this) instance_;

    static typeof(this) instance() {
        if (!instantiated_) {
            synchronized (typeof(this).classinfo) {
                if (!instance_) {
                    instance_ = new typeof(this)();
                }
                instantiated_ = true;
            }
        }
        return instance_;
    }
}
