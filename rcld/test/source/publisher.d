module publisher;

import std.stdio;
import rcld;
import rcld_test_msgs.msg;

unittest {
    import std.process : executeShell;
    import std.algorithm : canFind;
    import std.array : split;

    init();
    auto node = new Node("test", "");
    auto pub = new Publisher!TestA(node, "test_a");
    auto topics = executeShell("ros2 topic list");

    auto msg = TestA();
    msg.time = 10;
    pub.publish(msg);

    shutdown();

    assert(topics.output.split('\n').canFind("/test_a"));
}
